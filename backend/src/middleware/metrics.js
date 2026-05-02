/**
 * Prometheus metrics middleware for Cakes n Bakes 365
 *
 * Exposes application-level metrics:
 *   - http_request_duration_seconds  (histogram)
 *   - http_requests_total            (counter)
 *   - Default Node.js process metrics (GC, event loop lag, heap, etc.)
 *
 * Usage:
 *   const { metricsMiddleware, metricsEndpoint } = require("./middleware/metrics");
 *   app.use(metricsMiddleware);
 *   app.get("/metrics", metricsEndpoint);
 */

const client = require("prom-client");

// Collect default Node.js / process metrics (CPU, memory, GC, event loop)
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ prefix: "cnb_" });

// ── Custom metrics ──────────────────────────────────────────────────

/**
 * Histogram: request duration in seconds.
 * Buckets chosen to give good resolution for a bakery ordering API:
 *   10ms → 50ms → 100ms → 250ms → 500ms → 1s → 2s → 5s → 10s
 */
const httpRequestDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10]
});

/**
 * Counter: total number of HTTP requests.
 */
const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"]
});

// ── Helpers ─────────────────────────────────────────────────────────

/**
 * Normalise an Express path so Prometheus cardinality stays low.
 *   /api/menu          → /api/menu
 *   /api/orders/42     → /api/orders/:id
 *   /api/cart/items/7  → /api/cart/items/:id
 *   /metrics           → /metrics
 */
function normaliseRoute(req) {
  if (req.route && req.baseUrl !== undefined) {
    return (req.baseUrl + req.route.path).replace(/\/+$/, "") || "/";
  }
  // Fallback: collapse numeric path segments
  return req.path.replace(/\/\d+/g, "/:id");
}

// ── Middleware ───────────────────────────────────────────────────────

/**
 * Express middleware that records duration and counts for every request.
 * Attach BEFORE your route handlers.
 */
function metricsMiddleware(req, res, next) {
  // Skip recording the /metrics endpoint itself
  if (req.path === "/metrics") {
    return next();
  }

  const end = httpRequestDuration.startTimer();

  res.on("finish", () => {
    const route = normaliseRoute(req);
    const labels = {
      method: req.method,
      route,
      status_code: res.statusCode
    };
    end(labels);
    httpRequestsTotal.inc(labels);
  });

  next();
}

/**
 * Handler for GET /metrics — returns Prometheus text format.
 */
async function metricsEndpoint(req, res) {
  try {
    res.set("Content-Type", client.register.contentType);
    res.end(await client.register.metrics());
  } catch (err) {
    res.status(500).end(err.message);
  }
}

module.exports = {
  metricsMiddleware,
  metricsEndpoint,
  httpRequestDuration,
  httpRequestsTotal,
  register: client.register
};
