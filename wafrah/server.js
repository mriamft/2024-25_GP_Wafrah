const express = require('express');
const mysql = require('mysql2');  // Updated to mysql2
const app = express();

// Database connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Wafrah_GP_1',
    database: 'Wafrah',
    authPlugins: {
      mysql_native_password: () => () => Buffer.from('Wafrah_GP_1')
    }
  });
  
db.connect((err) => {
  if (err) throw err;
  console.log('MySQL Connected...');
});

// Middleware to parse JSON
app.use(express.json());

// Route to add a new user
app.post('/adduser', (req, res) => {
  const { userName, phoneNumber, password } = req.body;
  let sql = 'INSERT INTO user (userName, phoneNumber, password) VALUES (?, ?, ?)';
  db.query(sql, [userName, phoneNumber, password], (err, result) => {
    if (err) throw err;
    res.send('User added');
  });
});

// Route to get all users
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

  // Handle the login request
app.post('/login', (req, res) => {
  const { phoneNumber, password } = req.body;

  // Check if phone number exists and if the password matches
  const sql = 'SELECT * FROM user WHERE phoneNumber = ?';
  db.query(sql, [phoneNumber], (err, result) => {
    if (err) throw err;
    if (result.length > 0) {
      // Compare the hashed password
      if (result[0].password === password) {
        res.json({ success: true });
      } else {
        res.json({ success: false });
      }
    } else {
      res.json({ success: false });
    }
  });
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
