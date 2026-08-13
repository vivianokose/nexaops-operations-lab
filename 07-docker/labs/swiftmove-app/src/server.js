// SwiftMove Logistics - delivery tracking app
// A small Express web server that connects to MySQL and shows deliveries.

const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection details come from environment variables.
// In Docker, these are passed in from the .env file via docker-compose.
// Never hardcode credentials in code.
const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3306,
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "",
  database: process.env.MYSQL_DATABASE || "swiftmove",
};

// A shared connection pool the whole app uses.
let pool;

// Create the deliveries table and seed it, if it is not already there.
async function initDb(p) {
  await p.query(`
    CREATE TABLE IF NOT EXISTS deliveries (
      id INT AUTO_INCREMENT PRIMARY KEY,
      tracking_code VARCHAR(20) NOT NULL,
      destination VARCHAR(100) NOT NULL,
      status VARCHAR(30) NOT NULL
    )
  `);

  const [rows] = await p.query("SELECT COUNT(*) AS count FROM deliveries");
  if (rows[0].count === 0) {
    await p.query(`
      INSERT INTO deliveries (tracking_code, destination, status) VALUES
      ('SM-1001', 'Port Harcourt', 'In transit'),
      ('SM-1002', 'Lagos', 'Delivered'),
      ('SM-1003', 'Abuja', 'Pending pickup')
    `);
  }
}

// Try to connect to the database, retrying patiently if it is not ready yet.
// This is the key production lesson: databases are slow to wake, so the app
// must not give up on the first failure. It waits and tries again.
async function connectWithRetry(maxAttempts = 10, delayMs = 3000) {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const p = await mysql.createPool(dbConfig);
      await p.query("SELECT 1"); // a tiny test query to confirm it really works
      await initDb(p);
      console.log(`Database ready and seeded (attempt ${attempt}).`);
      return p;
    } catch (err) {
      console.log(
        `Database not ready (attempt ${attempt}/${maxAttempts}): ${err.message}`
      );
      if (attempt === maxAttempts) {
        console.log("Giving up after all attempts.");
        throw err;
      }
      // wait before trying again
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
}

// Health endpoint. Docker hits this to check the app is alive.
app.get("/health", (req, res) => {
  res.json({ status: "healthy", service: "swiftmove-app" });
});

// The main page: list the deliveries from the database.
app.get("/", async (req, res) => {
  try {
    const [deliveries] = await pool.query(
      "SELECT tracking_code, destination, status FROM deliveries"
    );

    const rowsHtml = deliveries
      .map(
        (d) =>
          `<tr><td>${d.tracking_code}</td><td>${d.destination}</td><td>${d.status}</td></tr>`
      )
      .join("");

    res.send(`
      <html>
        <head><title>SwiftMove Logistics</title></head>
        <body style="font-family: sans-serif; max-width: 600px; margin: 40px auto;">
          <h1>SwiftMove Logistics</h1>
          <p>Live delivery tracking, served from a container talking to MySQL.</p>
          <table border="1" cellpadding="8" cellspacing="0">
            <tr><th>Tracking</th><th>Destination</th><th>Status</th></tr>
            ${rowsHtml}
          </table>
        </body>
      </html>
    `);
  } catch (err) {
    res
      .status(500)
      .send(`<h1>Database not reachable yet</h1><pre>${err.message}</pre>`);
  }
});

// Start the server, then connect to the database with retries.
app.listen(PORT, async () => {
  console.log(`SwiftMove app listening on port ${PORT}`);
  try {
    pool = await connectWithRetry();
  } catch (err) {
    console.log("Could not establish database connection:", err.message);
  }
});
