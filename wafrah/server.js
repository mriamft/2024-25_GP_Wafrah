// Import necessary libraries 
const express = require('express'); // To create the server
const mysql = require('mysql2'); // To connect and interact with the MySQL database
const bcrypt = require('bcryptjs'); // To hash the password 
const twilio = require('twilio'); // Twilio SDK to manage OTP functionality
const app = express();
require('dotenv').config(); // Load environment variables from .env file

const saltRounds = 10; // Used for bcrypt hashing

// Sets up and initializes the Twilio client using credentialsin the .env file
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const verifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID;
const client = twilio(accountSid, authToken);

// Database connection to AWS RDS MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
});

// Connect to the database
db.connect((err) => {

  if (err) {
    console.error('MySQL connection failed: ' + err.stack);
    return;
  }

  console.log('Connected to AWS RDS MySQL as id ' + db.threadId);
});

app.use(express.json());

// Sending the OTP
app.post('/send-otp', async (req, res) => {
  const { phoneNumber } = req.body;

  try {
    await client.verify.services(verifyServiceSid)
      .verifications
      .create({ to: phoneNumber, channel: 'sms' });
    res.status(200).send('OTP sent successfully');
  } catch (error) {
    console.error('Error sending OTP: ', error);
    res.status(500).send('Failed to send OTP');
  }

});

// Verifying the OTP that is sent before
app.post('/verify-otp', async (req, res) => {
  const { phoneNumber, otp } = req.body;

  try {
    const verificationCheck = await client.verify.services(verifyServiceSid)
      .verificationChecks
      .create({ to: phoneNumber, code: otp });

    if (verificationCheck.status === 'approved') {
      res.status(200).send('OTP verified');
    } else {
      res.status(400).send('Invalid OTP');
    }

  } catch (error) {
    console.error('Error verifying OTP: ', error);
    res.status(500).send('Failed to verify OTP');
  }

});

// Add a new user to the database
app.post('/adduser', async (req, res) => {
  const { userName, phoneNumber, password } = req.body;

  try {
    // Hash the password using bcrypt before storing it in the database
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    console.log('Hashed Password:', hashedPassword);

    // Insert the new user into the user table
    let sql = 'INSERT INTO user (userName, phoneNumber, password) VALUES (?, ?, ?)';
    db.query(sql, [userName, phoneNumber, hashedPassword], (err, result) => {

      if (err) {
        console.error('Error inserting user:', err);
        res.status(500).send('Error inserting user');
        return;
      }

      // Retrieve the userID of the new user if the user is successfully added
      let userIdQuery = 'SELECT userID FROM user WHERE phoneNumber = ?';
      db.query(userIdQuery, [phoneNumber], (err, userResult) => {

        if (err) {
          console.error('Error fetching userID:', err);
          res.status(500).send('Error fetching userID');
          return;
        }

        const userID = userResult[0].userID;
        res.json({ success: true, userID: userID, userName: userName });

      });
    });
  } catch (err) {
    console.error('Error during sign-up:', err);
    res.status(500).send('Server error during sign-up');
  }
});

// Handle login request
app.post('/login', (req, res) => {
  const { phoneNumber, password } = req.body;

  // Check if the phone number exists in the database
  const sql = 'SELECT * FROM user WHERE phoneNumber = ?';
  db.query(sql, [phoneNumber], async (err, result) => {

    if (err) {
      console.error('Database error during login:', err);
      res.status(500).send('Server error');
      return;
    }

    if (result.length > 0) { // The phone number is exsists
      const user = result[0];

      // Compare the entered password with the hashed password in the database
      const match = await bcrypt.compare(password, user.password);

      if (match) {
        // Passwords match, return success with user details
        res.json({ success: true, userID: user.userID, userName: user.userName });
      } else {
        // Passwords do not match
        res.json({ success: false, message: 'Incorrect phone number or password' });
      }
    } else {
      // Phone number does not exist
      res.json({ success: false, message: 'Incorrect phone number or password' });
    }
  });
});

// Update user's password (for "Forgot Password" feature)
app.post('/forget-password', async (req, res) => {
  const { phoneNumber, newPassword } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);
    // Update the users' password with a specfied phone number after hashing
    let sql = 'UPDATE user SET password = ? WHERE phoneNumber = ?';
    db.query(sql, [hashedPassword, phoneNumber], (err, result) => {

      if (err) throw err;
      res.send('Password updated successfully');
    });
  } catch (err) {
    console.error('Error during password reset:', err);
    res.status(500).send('Server error during password reset');
  }
});

// Update user's password (for "Reset Password" feature)
app.post('/reset-password', async (req, res) => {
  const { phoneNumber, currentPassword, newPassword } = req.body;

  try {
    console.log(`Reset Password called for phone number: ${phoneNumber}`);

    // Retrieve the user's current hashed password based on phone number
    let sql = 'SELECT password FROM user WHERE phoneNumber = ?';
    db.query(sql, [phoneNumber], async (err, results) => {

      if (err) {
        console.error('Database query error:', err);
        return res.status(500).send('Server error during password reset');
      }

      // User is not found
      if (results.length === 0) { 
        console.log('User not found for phoneNumber:', phoneNumber);
        return res.status(404).send('User not found');
      }

      const storedHashedPassword = results[0].password; // the stored hashed password
      const passwordMatch = await bcrypt.compare(currentPassword, storedHashedPassword); // Compare the provided current password with the stored hashed password

      if (!passwordMatch) {
        console.log('Current password mismatch for phoneNumber:', phoneNumber);
        return res.status(400).send('Current password is incorrect');
      }

      const hashedPassword = await bcrypt.hash(newPassword, saltRounds); // Hash the new password
      // Update the users' password with a specfied phone number
      let updateSql = 'UPDATE user SET password = ? WHERE phoneNumber = ?';
      db.query(updateSql, [hashedPassword, phoneNumber], (err, result) => {

        if (err) {
          console.error('Error during password update:', err);
          return res.status(500).send('Server error during password reset');
        }

        if (result.affectedRows === 0) {
          console.log('Password update failed for phoneNumber:', phoneNumber);
          return res.status(400).send('Failed to update password');
        }

        console.log('Password updated successfully for phoneNumber:', phoneNumber);
        res.send('Password updated successfully');
      });
    });
  } catch (err) {
    console.error('Error during password reset:', err);
    res.status(500).send('Server error during password reset');
  }
});

// Check if a phone number already exists in the database
app.post('/checkPhoneNumber', (req, res) => {
  const { phoneNumber } = req.body;
  const sql = 'SELECT * FROM user WHERE phoneNumber = ?';
  
  db.query(sql, [phoneNumber], (err, result) => {

    if (err) {
      console.error('Database error during phone number check:', err);
      res.status(500).send('Server error');
      return;
    }

    if (result.length > 0) {
      res.json({ exists: true });
    } else {
      res.json({ exists: false });
    }

  });
});

// Server listening on port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// Delete user account
app.delete('/delete-user', (req, res) => {
  const { phoneNumber } = req.body;

  // Check if phoneNumber is provided
  if (!phoneNumber) {
    return res.status(400).send('Phone number is required');
  }

  const sql = 'DELETE FROM user WHERE phoneNumber = ?';

  db.query(sql, [phoneNumber], (err, result) => {
    if (err) {
      console.error('Database error during user deletion:', err);
      res.status(500).send('Server error during user deletion');
      return;
    }

    if (result.affectedRows > 0) {
      res.send('User deleted successfully');
    } else {
      res.status(404).send('User not found');
    }
  });
});

