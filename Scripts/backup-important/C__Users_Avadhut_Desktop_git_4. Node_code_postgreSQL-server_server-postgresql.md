# Server.js - CommonJS with PostgreSQL

This is the CommonJS version of the server using PostgreSQL instead of MySQL.

## Key Changes from MySQL to PostgreSQL:

1. **Database Package**: Changed from `mysql2` to `pg` (node-postgres)
2. **Connection Pool**: Different syntax for PostgreSQL
3. **SQL Syntax**:
   - `AUTO_INCREMENT` → `SERIAL` or `GENERATED ALWAYS AS IDENTITY`
   - `?` placeholders → `$1, $2, $3` (numbered parameters)
     - MySQL uses `?` as positional placeholders filled in order
     - PostgreSQL uses `$1, $2, $3...` where numbers refer to array positions
     - PostgreSQL's approach allows reusing the same parameter multiple times in a query
     - Example: `"SELECT * FROM users WHERE name = $1 OR email = $1"` (same value used twice)
   - `result.insertId` → `result.rows[0].id` (using RETURNING clause)
   - `result.affectedRows` → `result.rowCount`
   - `[rows]` destructuring → `result.rows`
   - Error codes: `ER_DUP_ENTRY` → `23505` (unique violation)
4. **ON UPDATE CURRENT_TIMESTAMP**: PostgreSQL doesn't support this directly, need to use triggers or handle in application

## Installation

```bash
npm install express pg dotenv cors multer express-rate-limit
```

## Code

```javascript
// See libraries-documentation.md for detailed information about all packages
const express = require("express");
const { Pool } = require("pg");
const dotenv = require("dotenv");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const rateLimit = require("express-rate-limit");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Create uploads directory if it doesn't exist
const uploadDir = "./uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));

// Rate Limiting Configuration
// General rate limiter - 100 requests per 15 minutes
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: {
    success: false,
    error: "Too many requests, please try again later.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limiter for file uploads - 10 uploads per hour
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
  message: {
    success: false,
    error: "Upload limit reached. Maximum 10 uploads per hour.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply general rate limiter to all routes
app.use("/api/", generalLimiter);

// Multer Configuration for File Uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(
      null,
      file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname)
    );
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|pdf|doc|docx/;
  const extname = allowedTypes.test(
    path.extname(file.originalname).toLowerCase()
  );
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error("Invalid file type. Allowed: JPEG, PNG, GIF, PDF, DOC, DOCX"));
  }
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter,
});

// Database connection pool
const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "myapp_db",
  port: process.env.DB_PORT || 5432,
  max: 10, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test database connection
async function testConnection() {
  try {
    const result = await pool.query("SELECT NOW()");
    console.log("✅ Database connected successfully");
    console.log("Database time:", result.rows[0].now);
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
}

// Initialize database tables
// This function sets up all the necessary database tables and triggers for the application
// It's called once when the server starts to ensure the database schema is ready
async function initDatabase() {
  try {
    // ========== CREATE USERS TABLE ==========
    // Creates a table to store user information
    // SERIAL: Auto-incrementing integer (PostgreSQL equivalent of AUTO_INCREMENT)
    // PRIMARY KEY: Ensures each user has a unique identifier
    // VARCHAR(100): Variable-length string with max 100 characters
    // UNIQUE: Ensures no two users can have the same email address
    // NOT NULL: These fields are required and cannot be empty
    // TIMESTAMP DEFAULT CURRENT_TIMESTAMP: Automatically sets the timestamp when a row is created
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users(
        id SERIAL PRIMARY KEY,                    // Auto-incrementing unique ID for each user
        name VARCHAR(100) NOT NULL,               // User's full name (required)
        email VARCHAR(100) UNIQUE NOT NULL,       // User's email (required, must be unique)
        avatar VARCHAR(255),                      // Path to user's profile picture (optional)
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  // When the user account was created
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP   // When the user record was last updated
      )
    `);

    // ========== CREATE TRIGGER FUNCTION ==========
    // PostgreSQL doesn't support ON UPDATE CURRENT_TIMESTAMP like MySQL does
    // So we need to create a custom function that will automatically update the updated_at column
    // This function is written in PL/pgSQL (PostgreSQL's procedural language)
    // RETURNS TRIGGER: This function returns a trigger object
    // NEW: Represents the new row being inserted/updated
    // CURRENT_TIMESTAMP: Gets the current date and time
    // This function will be called automatically by triggers before UPDATE operations
    await pool.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;  // Set the updated_at field to current time
        RETURN NEW;                          // Return the modified row
      END;
      $$ language 'plpgsql';                 // Specify the language as PL/pgSQL
    `);

    // ========== CREATE TRIGGER FOR USERS TABLE ==========
    // A trigger is a database object that automatically executes a function when a certain event occurs
    // DROP TRIGGER IF EXISTS: Removes the trigger if it already exists (prevents errors on re-runs)
    // BEFORE UPDATE: The trigger fires BEFORE an UPDATE operation happens
    // FOR EACH ROW: The trigger executes once for each row being updated
    // EXECUTE FUNCTION: Calls our custom function to update the timestamp
    // This ensures that every time a user record is updated, the updated_at field is automatically refreshed
    //
    // ========== WHY "BEFORE UPDATE" INSTEAD OF "AFTER UPDATE"? ==========
    // We use BEFORE UPDATE because:
    // 1. We need to MODIFY the row data (set updated_at) BEFORE it's saved to the database
    // 2. In BEFORE triggers, we can access and modify the NEW row (the row being updated)
    // 3. If we used AFTER UPDATE, the row would already be saved, and we'd need another UPDATE query
    //    which would be inefficient and could cause infinite loops
    // 
    // Example: If we used AFTER UPDATE:
    //   - Row gets updated with new data
    //   - Trigger fires AFTER the update is complete
    //   - We'd need to run: UPDATE users SET updated_at = NOW() WHERE id = X
    //   - This would trigger the trigger again! (infinite loop risk)
    //
    // With BEFORE UPDATE:
    //   - Trigger fires BEFORE the row is saved
    //   - We modify NEW.updated_at = CURRENT_TIMESTAMP
    //   - The row is saved with the updated timestamp in ONE operation
    //
    // ========== WHY "FOR EACH ROW" INSTEAD OF "FOR EACH STATEMENT"? ==========
    // We use FOR EACH ROW because:
    // 1. We need to update the timestamp for EACH individual row that gets updated
    // 2. FOR EACH ROW: Trigger fires once per row affected by the UPDATE statement
    // 3. FOR EACH STATEMENT: Trigger fires only ONCE per UPDATE statement, regardless of how many rows
    //
    // Example scenarios:
    // 
    // Scenario 1: UPDATE users SET name = 'John' WHERE id = 1;
    //   - FOR EACH ROW: Trigger fires 1 time (1 row updated)
    //   - FOR EACH STATEMENT: Trigger fires 1 time (1 statement)
    //   - Result: Same in this case, but FOR EACH ROW gives us access to the specific row
    //
    // Scenario 2: UPDATE users SET status = 'active' WHERE age > 18;
    //   - FOR EACH ROW: Trigger fires for EACH row that matches (e.g., 50 times if 50 rows match)
    //   - FOR EACH STATEMENT: Trigger fires only 1 time (1 statement, but 50 rows affected)
    //   - Result: FOR EACH ROW ensures each row gets its updated_at timestamp updated correctly
    //
    // Why FOR EACH ROW is better for our use case:
    //   - We can access NEW.updated_at and modify it for each specific row
    //   - Each row gets its own timestamp updated correctly
    //   - Works correctly even when updating multiple rows in one statement
    //
    // When to use FOR EACH STATEMENT:
    //   - When you want to do something ONCE per UPDATE statement (like logging)
    //   - When you don't need to modify individual row data
    //   - Example: Log that "an update happened" without caring about which specific rows
    await pool.query(`
      DROP TRIGGER IF EXISTS update_users_updated_at ON users;
      CREATE TRIGGER update_users_updated_at
      BEFORE UPDATE ON users                  // Fire before any UPDATE on users table
      FOR EACH ROW                            // Execute for each row being updated
      EXECUTE FUNCTION update_updated_at_column();  // Call our custom function
    `);

    // ========== CREATE DOCUMENTS TABLE ==========
    // Creates a table to store document/file information uploaded by users
    // INTEGER: Stores whole numbers (for user_id and filesize)
    // TEXT: Stores large text data (unlimited length)
    // FOREIGN KEY: Creates a relationship with the users table
    // REFERENCES users(id): The user_id must exist in the users table
    // ON DELETE CASCADE: If a user is deleted, all their documents are automatically deleted too
    // This maintains data integrity and prevents orphaned records
    await pool.query(`
      CREATE TABLE IF NOT EXISTS documents (
        id SERIAL PRIMARY KEY,                              // Unique ID for each document
        user_id INTEGER,                                    // Links document to a user
        title VARCHAR(200) NOT NULL,                        // Document title (required)
        filename VARCHAR(255) NOT NULL,                     // Original filename (required)
        filepath VARCHAR(500) NOT NULL,                     // Full path where file is stored (required)
        filesize INTEGER,                                   // File size in bytes (optional)
        mimetype VARCHAR(100),                              // File type (e.g., 'image/png', 'application/pdf')
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     // When document was uploaded
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE  // Link to users, delete docs if user deleted
      )
    `);

    // ========== CREATE PRODUCTS TABLE ==========
    // Creates a table to store product information for an e-commerce or inventory system
    // DECIMAL(10,2): Stores decimal numbers with 10 total digits, 2 after decimal point (e.g., 99999999.99)
    // DEFAULT 0: If no stock value is provided, it defaults to 0
    // TEXT: Used for description to allow longer text content
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products(
        id SERIAL PRIMARY KEY,                              // Unique ID for each product
        name VARCHAR(200) NOT NULL,                         // Product name (required)
        description TEXT,                                   // Detailed product description (optional, can be long)
        price DECIMAL(10,2) NOT NULL,                       // Product price (required, max 99,999,999.99)
        stock INTEGER DEFAULT 0,                            // Available quantity (defaults to 0 if not specified)
        image VARCHAR(255),                                 // Path to product image (optional)
        category VARCHAR(100),                              // Product category (e.g., 'electronics', 'clothing')
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     // When product was added
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP      // When product was last modified
      )
    `);

    // ========== CREATE TRIGGER FOR PRODUCTS TABLE ==========
    // Same trigger mechanism as users table (see detailed explanation above about BEFORE UPDATE and FOR EACH ROW)
    // Automatically updates the updated_at timestamp whenever a product record is modified
    // This is useful for tracking when products were last updated (price changes, stock updates, etc.)
    // BEFORE UPDATE: Allows us to modify the row data before it's saved
    // FOR EACH ROW: Ensures each updated row gets its timestamp updated correctly
    await pool.query(`
      DROP TRIGGER IF EXISTS update_products_updated_at ON products;
      CREATE TRIGGER update_products_updated_at
      BEFORE UPDATE ON products              // Fire before any UPDATE on products table
      FOR EACH ROW                           // Execute for each row being updated
      EXECUTE FUNCTION update_updated_at_column();  // Call our custom function to update timestamp
    `);

    // Success message - all tables and triggers have been created successfully
    console.log("✅ Database tables initialized");
  } catch (error) {
    // Error handling - if any table creation fails, log the error
    // This prevents the server from crashing and allows you to see what went wrong
    console.log("❌ Database initialization failed:", error.message);
  }
}

// Pagination helper function
function getPaginationParams(req) {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  return { page, limit, offset };
}

// Routes
// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "Server is running",
    features: ["File Upload", "Rate Limiting", "Pagination", "Authentication"],
  });
});

// ==================== USER ROUTES WITH PAGINATION ====================
// Get all users with pagination
app.get("/api/users", async (req, res) => {
  try {
    const { page, limit, offset } = getPaginationParams(req);

    // Get total count
    const countResult = await pool.query("SELECT COUNT(*) as total FROM users");
    const total = parseInt(countResult.rows[0].total);

    // Get paginated data
    // NOTE: PostgreSQL uses $1, $2, $3... (numbered parameters) instead of ? (positional parameters) like MySQL
    // Why $1, $2 instead of ?:
    // 1. PostgreSQL uses numbered placeholders ($1, $2, $3...) where the number refers to the position in the parameters array
    // 2. MySQL uses ? (question marks) as positional placeholders that are filled in order
    // 3. PostgreSQL's approach allows you to reuse the same parameter multiple times in a query
    //    Example: "SELECT * FROM users WHERE name = $1 OR email = $1" (same value used twice)
    // 4. The parameters array [limit, offset] maps to $1=limit, $2=offset
    // 5. This is a fundamental difference between PostgreSQL (pg library) and MySQL (mysql2 library)
    const result = await pool.query(
      "SELECT id, name, email, avatar, created_at FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2",
      [limit, offset]  // $1 = limit, $2 = offset
    );

    res.json({
      success: true,
      data: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page < Math.ceil(total / limit),
        hasPrev: page > 1,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create user with avatar upload
app.post(
  "/api/users",
  uploadLimiter,
  upload.single("avatar"),
  async (req, res) => {
    try {
      const { name, email } = req.body;

      if (!name || !email) {
        return res.status(400).json({
          success: false,
          error: "Name and email are required",
        });
      }

      const avatar = req.file ? `/uploads/${req.file.filename}` : null;
      const result = await pool.query(
        "INSERT INTO users (name, email, avatar) VALUES ($1, $2, $3) RETURNING id",
        [name, email, avatar]
      );

      res.status(201).json({
        success: true,
        data: {
          id: result.rows[0].id,
          name,
          email,
          avatar,
          message: avatar
            ? "User created with avatar"
            : "User created without avatar",
        },
      });
    } catch (error) {
      if (error.code === "23505") {
        // PostgreSQL unique violation error code
        return res.status(409).json({
          success: false,
          error: "Email already exists",
        });
      }
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// update user avatar
app.put(
  "/api/users/:id/avatar",
  uploadLimiter,
  upload.single("avatar"),
  async (req, res) => {
    try {
      const userId = req.params.id;

      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: "No file uploaded",
        });
      }

      // Get old avatar to delete
      const userResult = await pool.query(
        "SELECT avatar FROM users WHERE id = $1",
        [userId]
      );
      if (userResult.rows.length > 0 && userResult.rows[0].avatar) {
        const oldAvatarPath = `.${userResult.rows[0].avatar}`;
        if (fs.existsSync(oldAvatarPath)) {
          fs.unlinkSync(oldAvatarPath);
        }
      }

      const avatar = `/uploads/${req.file.filename}`;
      const result = await pool.query(
        "UPDATE users SET avatar = $1 WHERE id = $2",
        [avatar, userId]
      );
      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          error: "User not found",
        });
      }

      res.json({
        success: true,
        message: "Avatar updated successfully",
        avatar,
      });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// ==================== DOCUMENT ROUTES WITH FILE UPLOAD ====================
// Upload document for a user
app.post(
  "/api/documents",
  uploadLimiter,
  upload.single("document"),
  async (req, res) => {
    try {
      const { user_id, title } = req.body;

      if (!user_id || !title || !req.file) {
        return res.status(400).json({
          success: false,
          error: "user_id, title, and document file are required",
        });
      }

      const result = await pool.query(
        "INSERT INTO documents (user_id, title, filename, filepath, filesize, mimetype) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
        [
          user_id,
          title,
          req.file.filename,
          `/uploads/${req.file.filename}`,
          req.file.size,
          req.file.mimetype,
        ]
      );

      res.status(201).json({
        success: true,
        data: {
          id: result.rows[0].id,
          user_id,
          title,
          filename: req.file.filename,
          filepath: `/uploads/${req.file.filename}`,
          filesize: req.file.size,
          mimetype: req.file.mimetype,
        },
        message: "Document uploaded successfully",
      });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// Get all documents with pagination
app.get("/api/documents", async (req, res) => {
  try {
    const { page, limit, offset } = getPaginationParams(req);
    const { user_id } = req.query;

    let query = "SELECT * FROM documents";
    let countQuery = "SELECT COUNT(*) as total FROM documents";
    const params = [];
    let paramCount = 0;

    if (user_id) {
      paramCount++;
      query += ` WHERE user_id = $${paramCount}`;
      countQuery += ` WHERE user_id = $${paramCount}`;
      params.push(user_id);
    }

    paramCount++;
    query += ` ORDER BY created_at DESC LIMIT $${paramCount}`;
    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(limit, offset);

    const countResult = await pool.query(countQuery, user_id ? [user_id] : []);
    const total = parseInt(countResult.rows[0].total);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page < Math.ceil(total / limit),
        hasPrev: page > 1,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Delete document
app.delete("/api/documents/:id", async (req, res) => {
  try {
    const documentId = req.params.id;
    const result = await pool.query(
      "SELECT filepath FROM documents WHERE id = $1",
      [documentId]
    );

    if (result.rows.length === 0) {
      return res
        .status(404)
        .json({ success: false, error: "Document not found" });
    }

    const filepath = `.${result.rows[0].filepath}`;
    if (fs.existsSync(filepath)) {
      fs.unlinkSync(filepath);
    }

    await pool.query("DELETE FROM documents WHERE id = $1", [documentId]);

    res.json({ success: true, message: "Document deleted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== PRODUCT ROUTES WITH PAGINATION ====================
// Get all products with pagination and filtering
app.get("/api/products", async (req, res) => {
  try {
    const { page, limit, offset } = getPaginationParams(req);
    const { category, minPrice, maxPrice, search } = req.query;

    let query = "SELECT * FROM products WHERE 1=1";
    let countQuery = "SELECT COUNT(*) as total FROM products WHERE 1=1";
    const params = [];
    const countParams = [];
    let paramCount = 0;
    let countParamCount = 0;

    if (category) {
      paramCount++;
      countParamCount++;
      query += ` AND category = $${paramCount}`;
      countQuery += ` AND category = $${countParamCount}`;
      params.push(category);
      countParams.push(category);
    }

    if (minPrice) {
      paramCount++;
      countParamCount++;
      query += ` AND price >= $${paramCount}`;
      countQuery += ` AND price >= $${countParamCount}`;
      params.push(parseFloat(minPrice));
      countParams.push(parseFloat(minPrice));
    }

    if (maxPrice) {
      paramCount++;
      countParamCount++;
      query += ` AND price <= $${paramCount}`;
      countQuery += ` AND price <= $${countParamCount}`;
      params.push(parseFloat(maxPrice));
      countParams.push(parseFloat(maxPrice));
    }

    if (search) {
      paramCount++;
      countParamCount++;
      const searchTerm = `%${search}%`;
      query += ` AND (name LIKE $${paramCount} OR description LIKE $${paramCount + 1})`;
      countQuery += ` AND (name LIKE $${countParamCount} OR description LIKE $${countParamCount + 1})`;
      params.push(searchTerm, searchTerm);
      countParams.push(searchTerm, searchTerm);
      paramCount++;
      countParamCount++;
    }

    paramCount++;
    query += ` ORDER BY created_at DESC LIMIT $${paramCount}`;
    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(limit, offset);

    const countResult = await pool.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].total);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page < Math.ceil(total / limit),
        hasPrev: page > 1,
      },
      filters: { category, minPrice, maxPrice, search },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// create product with image upload
app.post(
  "/api/products",
  uploadLimiter,
  upload.single("image"),
  async (req, res) => {
    try {
      const { name, description, price, stock, category } = req.body;

      if (!name || !price) {
        return res.status(400).json({
          success: false,
          error: "Name and price are required",
        });
      }

      const image = req.file ? `/uploads/${req.file.filename}` : null;
      const result = await pool.query(
        "INSERT INTO products (name, description, price, stock, image, category) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
        [
          name,
          description,
          parseFloat(price),
          parseInt(stock) || 0,
          image,
          category,
        ]
      );

      res.status(201).json({
        success: true,
        data: {
          id: result.rows[0].id,
          name,
          description,
          price,
          stock,
          image,
          category,
        },
      });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// update product with image upload
app.put(
  "/api/products/:id",
  uploadLimiter,
  upload.single("image"),
  async (req, res) => {
    try {
      const productId = req.params.id;
      const { name, description, price, stock, category } = req.body;

      if (!name || !price) {
        return res.status(400).json({
          success: false,
          error: "Name and price are required",
        });
      }

      const productResult = await pool.query(
        "SELECT image FROM products WHERE id = $1",
        [productId]
      );
      if (productResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Product not found",
        });
      }

      if (productResult.rows[0].image) {
        const imagePath = `.${productResult.rows[0].image}`;
        if (fs.existsSync(imagePath)) {
          fs.unlinkSync(imagePath);
        }
      }

      const image = req.file ? `/uploads/${req.file.filename}` : productResult.rows[0].image;

      const result = await pool.query(
        "UPDATE products SET name = $1, description = $2, price = $3, stock = $4, image = $5, category = $6 WHERE id = $7 RETURNING id",
        [
          name,
          description,
          parseFloat(price),
          parseInt(stock) || 0,
          image,
          category,
          productId,
        ]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          error: "Product not found",
        });
      }

      res.json({
        success: true,
        data: {
          id: result.rows[0].id,
          name,
          description,
          price,
          stock,
          image,
          category,
        },
        message: "Product updated successfully",
      });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, error: "Route not found" });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);

  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        error: "File too large. Maximum size is 5MB.",
      });
    }
    return res.status(400).json({
      success: false,
      error: err.message,
    });
  }

  res.status(500).json({
    success: false,
    error: err.message || "Something went wrong!",
  });
});

// Start server
async function startServer() {
  await testConnection();
  await initDatabase();

  app.listen(PORT, () => {
    console.log(`🚀 Server is running on http://localhost:${PORT}`);
    console.log(`\n📚 API Features Demonstration:`);
    console.log(`\n🔒 RATE LIMITING:`);
    console.log(`   - General API: 100 requests per 15 minutes`);
    console.log(`   - File Uploads: 10 uploads per hour`);
    console.log(`\n📄 PAGINATION:`);
    console.log(`   - Add ?page=1&limit=10 to list endpoints`);
    console.log(`   - Includes metadata: total, totalPages, hasNext, hasPrev`);
    console.log(`\n📤 FILE UPLOAD:`);
    console.log(`   - Max file size: 5MB`);
    console.log(`   - Allowed types: JPEG, PNG, GIF, PDF, DOC, DOCX`);
    console.log(`   - Files stored in ./uploads directory`);
    console.log(`\n🔗 API Endpoints:`);
    console.log(`   GET    /api/health`);
    console.log(`   GET    /api/users?page=1&limit=10`);
    console.log(`   POST   /api/users (with avatar file)`);
    console.log(`   PUT    /api/users/:id/avatar (with avatar file)`);
    console.log(`   GET    /api/documents?page=1&limit=10&user_id=1`);
    console.log(`   POST   /api/documents (with document file)`);
    console.log(`   DELETE /api/documents/:id`);
    console.log(`   GET    /api/products?page=1&limit=10&category=electronics`);
    console.log(`   POST   /api/products (with image file)`);
    console.log(`   PUT    /api/products/:id (with image file)`);
  });
}

startServer();
```

## Environment Variables (.env)

```env
PORT=3000
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=myapp_db
DB_PORT=5432
```

## Package.json

```json
{
  "name": "server-postgresql",
  "version": "1.0.0",
  "description": "Express server with PostgreSQL",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^17.2.3",
    "express": "^5.2.1",
    "express-rate-limit": "^8.2.1",
    "multer": "^2.0.2",
    "pg": "^8.11.3"
  }
}
```
postgres
## PostgreSQL Setup Notes

1. **Install PostgreSQL** on your system
2. **Create a database**: `CREATE DATABASE myapp_db;`
3. **Update .env** with your PostgreSQL credentials
4. The code includes triggers to automatically update `updated_at` timestamps

## Key PostgreSQL Differences

- Uses `SERIAL` for auto-incrementing IDs
- Uses `$1, $2, $3` for parameterized queries instead of `?`
- Returns data in `result.rows` array
- Uses `RETURNING` clause to get inserted/updated row data
- Uses `result.rowCount` instead of `result.affectedRows`
- Error code `23505` for unique constraint violations
- Uses triggers for `ON UPDATE CURRENT_TIMESTAMP` functionality

