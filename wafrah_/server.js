const express = require('express');
const mysql = require('mysql2'); // Using mysql2
const bcrypt = require('bcrypt'); // Add bcrypt for password hashing
const app = express();

const saltRounds = 10; // Used for bcrypt hashing

// Database connection pool to AWS RDS MySQL
const pool = mysql.createPool({
  host: 'wafrahdb.cf6kyks0q11n.eu-north-1.rds.amazonaws.com', // AWS RDS endpoint
  user: 'admin', // Master username
  password: 'Wafrah_GP_1', // Master password for RDS instance
  database: 'Wafrah', // Database name
  port: 3306, // MySQL default port
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test connection to the database pool
pool.getConnection((err, connection) => {
  if (err) {
    console.error('MySQL connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to AWS RDS MySQL');
  connection.release(); // release the connection back to the pool
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
    pool.query(sql, [userName, phoneNumber, hashedPassword], (err, result) => {
      if (err) throw err;
      res.send('User added successfully');
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Route to handle user login with hashed password comparison
app.post('/login', (req, res) => {
  const { phoneNumber, password } = req.body;

  if (!phoneNumber || !password) {
    res.status(400).json({ success: false, message: 'Missing phone number or password' });
    return;
  }

  // Check if phone number exists and if the password matches
  const sql = 'SELECT userID, firstName, password FROM user WHERE phoneNumber = ?'; // Select userID and firstName as well
  pool.query(sql, [phoneNumber], async (err, result) => {
    if (err) {
      console.error('Error during login: ', err);
      res.status(500).send('Server error');
      return;
    }

    if (result.length > 0) {
      const user = result[0];

      // Compare the entered password with the hashed password in the database
      const match = await bcrypt.compare(password, user.password);

      if (match) {
        // Return the userID and firstName upon successful login
        res.json({
          success: true,
          message: 'Login successful',
          userID: user.userID,        // Sending userID
          firstName: user.firstName   // Sending firstName
        });
      } else {
        res.json({ success: false, message: 'Incorrect phone number or password' });
      }
    } else {
      res.json({ success: false, message: 'Phone number not found' });
    }
  });
});

// Server listening on port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
