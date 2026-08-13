// Tiny health check script for Docker's HEALTHCHECK.
// It asks the app's /health endpoint and reports healthy (exit 0) or not (exit 1).

const http = require("http");

const request = http.get("http://localhost:3000/health", (res) => {
  // 200 means the app answered OK -> healthy.
  process.exit(res.statusCode === 200 ? 0 : 1);
});

// If the app cannot be reached at all -> unhealthy.
request.on("error", () => process.exit(1));
