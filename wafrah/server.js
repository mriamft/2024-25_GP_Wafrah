const express = require('express');
const mysql = require('mysql2'); // Using mysql2
const bcrypt = require('bcrypt'); // Add bcrypt for password hashing
const app = express();

const saltRounds = 10; // Used for bcrypt hashing

// Database connection to AWS RDS MySQL
const db = mysql.createConnection({
  host: 'wafrahdb.cf6kyks0q11n.eu-north-1.rds.amazonaws.com', // Replace with your AWS RDS endpoint
  user: 'admin', // Your master username
  password: 'Wafrah_GP_1', // Your master password for the RDS instance
  database: 'Wafrah', // The name of the database
  port: 3306, // MySQL default port
});

// Connect to the database
db.connect((err) => {
  if (err) {
    console.error('MySQL connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to AWS RDS MySQL as id ' + db.threadId);
});

// Middleware to parse JSON
app.use(express.json());

// Route to add a new user with hashed password
app.post('/adduser', async (req, res) => {
  const { userName, phoneNumber, password } = req.body;

  try {
    // Hash the password before storing it
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // SQL query to insert new user
    let sql = 'INSERT INTO user (userName, phoneNumber, password) VALUES (?, ?, ?)';
    db.query(sql, [userName, phoneNumber, hashedPassword], (err, result) => {
      if (err) throw err;
      res.send('User added successfully');
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Route to get all users (just for testing or admin use)
app.get('/users', (req, res) => {
  let sql = 'SELECT * FROM user';
  db.query(sql, (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

// Check if a phone number exists
app.post('/checkPhoneNumber', (req, res) => {
  const { phoneNumber } = req.body;
  const sql = 'SELECT * FROM user WHERE phoneNumber = ?';
  db.query(sql, [phoneNumber], (err, result) => {
    if (err) throw err;
    if (result.length > 0) {
      res.json({ exists: true });
    } else {
      res.json({ exists: false });
    }
  });
});

// Handle the login request with hashed password comparison
app.post('/login', (req, res) => {
  const { phoneNumber, password } = req.body;

  // Check if phone number exists and if the password matches
  const sql = 'SELECT * FROM user WHERE phoneNumber = ?';
  db.query(sql, [phoneNumber], async (err, result) => {
    if (err) throw err;

    if (result.length > 0) {
      const user = result[0];

      // Compare the entered password with the hashed password in the database
      const match = await bcrypt.compare(password, user.password);

      if (match) {
        res.json({ success: true });
      } else {
        res.json({ success: false, message: 'Incorrect phone number or password' });
      }
    } else {
      res.json({ success: false, message: 'Incorrect phone number or password' });
    }
  });
});

// Server listening on port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
