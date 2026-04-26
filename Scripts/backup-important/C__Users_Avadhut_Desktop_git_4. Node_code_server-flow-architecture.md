# Express.js Server Flow & Architecture

## Overview
This document explains the execution flow and architecture pattern used in `server.js`. Understanding this flow is crucial for maintaining and extending the application.

---

## Execution Flow Order

### 1. **Setup & Configuration** (Lines 1-21)
- Import dependencies
- Load environment variables (`dotenv.config()`)
- Create Express app instance
- Create uploads directory if it doesn't exist

**Why first?** Basic setup must happen before anything else can use these resources.

---

### 2. **Middleware Registration** (Lines 23-89)
```javascript
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));
// Rate limiters
// Multer configuration
```

**Why before routes?**
- Middlewares must be registered **before** routes
- Express processes middlewares in the order they are registered
- Every request will pass through these middlewares first
- Routes can use these configured middlewares (like `upload`, `uploadLimiter`)

**Key Point:** Middlewares are registered but **not executed** until a request comes in.

---

### 3. **Database Connection Pool Creation** (Lines 91-100)
```javascript
const pool = mysql.createPool({...});
```

**Why here?**
- Pool is **created** but **not connected** yet
- Routes need to reference `pool` object, so it must be defined before routes
- The actual connection happens later in `startServer()`

**Key Point:** This is just creating the pool configuration, not establishing connections.

---

### 4. **Helper Functions** (Lines 103-163)
- `testConnection()` - Tests DB connectivity
- `initDatabase()` - Creates tables if they don't exist
- `getPaginationParams()` - Utility for pagination

**Why here?**
- Functions are defined but not called yet
- Routes can use these helper functions
- They will be executed later in `startServer()`

---

### 5. **Route Definitions** (Lines 165-622)
All API endpoints are registered:
- `/api/health`
- `/api/users`
- `/api/documents`
- `/api/products`

**Why after middlewares?**
- Routes can use configured middlewares (e.g., `upload.single()`, `uploadLimiter`)
- Routes can access the `pool` object
- Routes are registered but **not executed** until server starts

**Key Point:** Routes are just definitions at this point - they won't handle requests until `app.listen()` is called.

---

### 6. **Error Handlers** (Lines 624-650)
```javascript
// 404 handler - must be after all routes
app.use((req, res) => {
  res.status(404).json({ success: false, error: "Route not found" });
});

// General error handler - must be last
app.use((err, req, res, next) => {
  // Error handling logic
});
```

**Why after routes?**
- **404 Handler:** Express matches routes in order. If no route matches, it falls through to the 404 handler. This must be **after** all routes.
- **Error Handler:** Express error handlers catch errors from routes. They must be registered **last** to catch all errors.

**Key Point:** Error handlers are the "catch-all" - they must come after everything else.

---

### 7. **Server Startup Function** (Lines 652-683)
```javascript
async function startServer() {
  await testConnection();      // 1. Test DB connection
  await initDatabase();         // 2. Initialize tables
  app.listen(PORT, () => {      // 3. Start server
    // Server is now running
  });
}

startServer(); // Execute the startup
```

**Why this order?**
1. **Test Connection:** Verify database is accessible before proceeding
2. **Initialize Database:** Create tables if they don't exist
3. **Start Server:** Only start accepting requests after DB is ready

**Key Point:** This ensures the database is ready before the server accepts any requests.

---

## Visual Flow Diagram

```
┌─────────────────────────────────────────┐
│  1. Setup & Configuration               │
│     - Imports, dotenv, app creation     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  2. Middleware Registration              │
│     - CORS, JSON parser, rate limiters   │
│     - Multer configuration               │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  3. Database Pool Creation               │
│     - Pool created (not connected)       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  4. Helper Functions                     │
│     - testConnection(), initDatabase()   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  5. Route Definitions                    │
│     - All API endpoints registered      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  6. Error Handlers                      │
│     - 404 handler                       │
│     - General error handler             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  7. Server Startup (startServer())      │
│     ├─→ Test DB Connection              │
│     ├─→ Initialize DB Tables            │
│     └─→ Start Express Server             │
│         (app.listen())                   │
└─────────────────────────────────────────┘
```

---

## Request Flow (After Server Starts)

When a request comes in:

```
1. Request arrives
   ↓
2. Passes through middlewares (in order):
   - CORS
   - JSON parser
   - Rate limiter
   - Route-specific middleware (if any)
   ↓
3. Matches route handler
   - Executes route logic
   - Uses database pool
   ↓
4. If route not found → 404 handler
   ↓
5. If error occurs → Error handler
   ↓
6. Response sent to client
```

---

## Key Principles

### 1. **Registration vs Execution**
- **Registration:** Code that defines/registers things (middlewares, routes, error handlers)
- **Execution:** Code that actually runs (database connections, server startup)

### 2. **Order Matters**
- Middlewares → Routes → Error Handlers (Express requirement)
- Database setup → Server startup (ensures DB is ready)

### 3. **Dependency Chain**
- Routes depend on: middlewares, database pool, helper functions
- Error handlers depend on: routes (to catch their errors)
- Server startup depends on: everything being registered

---

## Why This Pattern?

### ✅ **Benefits:**
1. **Clear separation** of concerns
2. **Predictable execution** order
3. **Error handling** works correctly
4. **Database ready** before accepting requests
5. **Follows Express.js best practices**

### ⚠️ **Common Mistakes to Avoid:**
1. ❌ Putting error handlers before routes
2. ❌ Starting server before database is ready
3. ❌ Using database pool before it's created
4. ❌ Registering routes before middlewares they need

---

## Summary

The flow follows this logical pattern:
1. **Setup** everything needed
2. **Register** middlewares, routes, and error handlers
3. **Initialize** database
4. **Start** the server

This ensures that when the server starts accepting requests, everything is properly configured and ready to handle them.

