// Load environment variables
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

// Import all route files
const categoriesRoutes = require("./routes/categories");
const menuRoutes = require("./routes/menu");
const cartRoutes = require("./routes/cart");
const orderRoutes = require("./routes/orders");
const whatsappRoutes = require("./routes/whatsapp");
const adminRoutes = require("./routes/admin");
const { notFound, errorHandler } = require("./middleware/error");

const app = express();

// Setup CORS - allow frontend to talk to backend
const allowedOrigins = (process.env.CLIENT_ORIGIN || "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(
  cors({
    origin: allowedOrigins.length ? allowedOrigins : true,
    credentials: true
  })
);

// Security and parsing middleware
app.use(helmet());
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: false }));
app.use(morgan("dev"));

// Health check endpoint - used by smoke tests and monitoring
app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

// Register all API routes
app.use("/api/categories", categoriesRoutes);
app.use("/api/menu", menuRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/whatsapp", whatsappRoutes);
app.use("/api/admin", adminRoutes);

// Error handling
app.use(notFound);
app.use(errorHandler);

// Start the server
const port = process.env.PORT || 4000;

app.listen(port, () => {
  console.log("========================================");
  console.log("  Cakes n Bakes 365 API Server");
  console.log(`  Running on port ${port}`);
  console.log("========================================");
});
