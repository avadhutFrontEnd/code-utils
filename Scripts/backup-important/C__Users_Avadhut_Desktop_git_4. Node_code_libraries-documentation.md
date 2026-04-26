# Node.js Libraries Documentation

This document provides detailed information about all the libraries and modules used in `server.js`.

---

## Table of Contents

### Foundation
- **0. Foundation: Understanding HTTP Request and Response Structure**
  - 0.1. HTTP Request Structure
  - 0.2. HTTP Response Structure
  - 0.3. Understanding Content-Type
  - 0.4. Understanding Authorization
  - 0.5. Request Object in Express (`req`)
  - 0.6. Response Object in Express (`res`)
  - 0.7. Quick Reference: Request vs Response
  - 0.8. How Libraries Use This Structure
  - 0.9. Understanding package.json

### External Libraries
- **1. Express**
  - 1.1. App.use() - Understanding Express Middleware
  - 1.2. Middleware: Global vs Path, app.use vs app.METHOD, Types
    - 1.2.1. Adding Middleware: Global and Path-Level
    - 1.2.2. app.use() vs app.get() / app.post() / … app.delete()
    - 1.2.3. app.use(path, Middleware, Router) and Mounting Routers
    - 1.2.4. Types of Middleware (Application, Router, Custom, Error, Built-in, Third-party)
  - 1.2.5. Middleware Execution Order and next()
  - 1.2.6. Middleware Signature, Recommended Order, Async, and Param
  - 1.2.7. Quick Reference
- **2. MySQL2 (Promise-based)**
  - 2.0. Connection Methods: Pool vs Single Connection
  - 2.1. Step 1: Create Connection Pool (`createPool`)
  - 2.2. Step 2: Get Connection from Pool (`getConnection`)
  - 2.3. Step 3: Execute Queries (`query` or `execute`)
  - 2.4. Day-to-Day Query Patterns
  - 2.5. Error Handling Pattern
  - 2.6. Transactions (Using getConnection)
  - 2.7. Complete Real-World Example (Your Pattern)
  - 2.8. Quick Reference: Methods You'll Use Daily
- **3. PostgreSQL (pg)**
  - 3.0. Connection Methods: Pool vs Client
  - 3.1. Key Differences from MySQL2
  - 3.2. Parameterized Queries (PostgreSQL Style)
  - 3.3. Quick Reference
- **4. MongoDB (Mongoose & mongodb driver)**
  - 4.0. Connection Methods (Mongoose connect / MongoClient)
  - 4.1. Mongoose vs mongodb Driver
  - 4.2. Mongoose Connection Options
  - 4.3. Quick Reference
- **5. Dotenv**
- **6. CORS**
- **7. Multer**
  - 7.1. Understanding File Upload Request Structure
  - 7.2. Understanding Callback Parameters: `(req, file, cb)`
  - 7.3. Multer Methods
  - 7.4. Multer Configuration Options
  - 7.5. Request Object Structure After Multer
  - 7.6. How File Storage Works: Disk vs Database
  - 7.7. File Upload Security: Critical Best Practices
    - 7.7.1. Security Best Practices
    - 7.7.2. Secure Implementation Example
    - 7.7.3. Security Checklist
    - 7.7.4. Common Attack Vectors and Prevention
    - 7.7.5. Quick Security Fixes for Your Current Code
  - 7.8. Complete Real-World Example
- **12. Express Rate Limit**
- **18. Morgan**
  - 18.1. What Morgan Does (HTTP Request Logger)
  - 18.2. Installation and Basic Usage
  - 18.3. Predefined Formats (dev, combined, common, short, tiny)
  - 18.4. Custom Format and Options
  - 18.5. When to Use Morgan (Dev vs Production)
  - 18.6. Quick Reference
- **19. Config (node-config)**
  - 19.1. What Config Does (Configuration by Environment)
  - 19.2. Installation and Folder Structure
  - 19.3. File Loading Order and NODE_ENV
  - 19.4. Using config.get() and Nested Keys
  - 19.5. Config vs Dotenv (When to Use Which)
    - custom-environment-variables.json: Explanation and Example
    - 19.5.1. Config with Dotenv: Complete Examples
  - 19.6. Quick Reference
- **20. Debug**
  - 20.1. What Debug Does (Namespace-Based Logging)
  - 20.2. Installation and Basic Usage
  - 20.3. DEBUG Environment Variable and Namespaces
  - 20.4. Enabling and Disabling (Unix, CMD, PowerShell)
  - 20.5. When to Use Debug vs console.log vs Morgan
  - 20.6. Quick Reference

### Built-in Node.js Modules
- **8. Path (Node.js Built-in)**
- **9. FS (Node.js Built-in)**
- **10. OS (Node.js Built-in)**
- **11. HTTP (Node.js Built-in)**

### Express Built-in Middleware
- **13. Express.json() and Body Parser Relationship**
- **14. Express.urlencoded() - Understanding URL-Encoded Form Data**
- **15. Express.static() - Serving Static Files**
- **16. Body Parser (Deprecated)**

### Testing with Postman
- **17. Testing with Postman**
  - 17.1. Why Headers and Settings Matter
  - 17.2. Content-Type: Sending JSON, Form Data, and Files
  - 17.3. Authorization: Bearer Token, Basic Auth, API Key
  - 17.4. Request Body Types in Postman (raw, form-data, urlencoded)
  - 17.5. Query Parameters vs Request Body
  - 17.6. Common Headers Quick Reference
  - 17.7. Environment Variables and Workflow
  - 17.8. Scenario Checklist and Examples
  - 17.9. HTTP Status Codes and Reading the Response
  - 17.10. Path Parameters vs Query Parameters
  - 17.11. Accept Header and Response Format
  - 17.12. Cookie-Based Authentication
  - 17.13. Pre-request Scripts and Tests Tab
  - 17.14. SSL Certificate Verification (Local / Dev)
  - 17.15. PATCH vs PUT vs DELETE
  - 17.16. Multiple Files Upload and Form-Data Details
  - 17.17. Collection vs Environment Variables
  - 17.18. Troubleshooting: Common Mistakes and Fixes
  - 17.19. Response Time and Response Headers
  - 17.20. Saving Token from Response (Tests Tab After Login)
  - 17.21. URL and Method Details (Trailing Slash, GET Body, 413)
  - 17.22. PATCH and DELETE Scenarios
  - 17.23. Collection Runner and Quick Tips

---

**Note:** Sections are organized by category for easier navigation. The numbering (0-17) follows the order of appearance in the document.

---

## 0. Foundation: Understanding HTTP Request and Response Structure

Before diving into specific libraries, it's essential to understand the fundamental structure of HTTP requests and responses. This knowledge is the foundation for understanding how Express, multer, and other middleware work.

---

### 0.1. HTTP Request Structure

An HTTP request consists of several parts that work together to send data from client to server.

#### 1. Request Line (Start Line)

**Format:**
```
METHOD /path?query=value HTTP/1.1
```

**Example:**
```
GET /api/users?id=123 HTTP/1.1
POST /api/upload HTTP/1.1
PUT /api/users/123 HTTP/1.1
DELETE /api/users/123 HTTP/1.1
```

**Components:**
- **Method:** GET, POST, PUT, DELETE, PATCH, etc.
- **Path:** URL path (e.g., `/api/users`)
- **Query String:** Optional parameters after `?` (e.g., `?id=123&name=John`)
- **HTTP Version:** Usually `HTTP/1.1` or `HTTP/2`

#### 2. Request Headers

Headers provide metadata about the request. They are key-value pairs.

#### Standard Headers

**Content-Type** - Specifies the format of the request body:
```
Content-Type: application/json
Content-Type: application/x-www-form-urlencoded
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary
Content-Type: text/plain
Content-Type: application/xml
```

**Content-Length** - Size of request body in bytes:
```
Content-Length: 1234
```

**Authorization** - Authentication credentials:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

**Host** - Server domain and port:
```
Host: localhost:3000
Host: api.example.com
```

**User-Agent** - Client application information:
```
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
```

**Accept** - What response formats the client accepts:
```
Accept: application/json
Accept: text/html, application/json
Accept: */*
```

**Accept-Language** - Preferred languages:
```
Accept-Language: en-US, en;q=0.9
```

**Cookie** - Stored cookies:
```
Cookie: sessionId=abc123; theme=dark
```

**Referer** - Previous page URL:
```
Referer: https://example.com/page
```

**Origin** - Request origin (for CORS):
```
Origin: http://localhost:3000
```

#### Custom Headers

You can create custom headers (usually prefixed with `X-`):
```
X-API-Key: your-api-key-here
X-Request-ID: unique-request-id
X-Custom-Header: custom-value
X-Client-Version: 1.0.0
```

#### 3. Request Body

The body contains the actual data being sent. **Not all requests have a body** (GET requests typically don't).

#### Body Formats

**JSON (`application/json`):**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "age": 30
}
```

**URL-Encoded (`application/x-www-form-urlencoded`):**
```
username=john_doe&email=john%40example.com&age=30
```

**Form Data (`multipart/form-data`):**
```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

[binary file data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

**Plain Text (`text/plain`):**
```
This is plain text content
```

**XML (`application/xml`):**
```xml
<user>
  <username>john_doe</username>
  <email>john@example.com</email>
</user>
```

#### Complete Request Example

**GET Request (No Body):**
```http
GET /api/users?id=123 HTTP/1.1
Host: localhost:3000
Accept: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
User-Agent: Mozilla/5.0
```

**POST Request (With JSON Body):**
```http
POST /api/users HTTP/1.1
Host: localhost:3000
Content-Type: application/json
Content-Length: 45
Authorization: Bearer token123
Accept: application/json

{
  "username": "john_doe",
  "email": "john@example.com"
}
```

**POST Request (With File Upload):**
```http
POST /api/upload HTTP/1.1
Host: localhost:3000
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Length: 12345
Authorization: Bearer token123

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

[binary file data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

---

### 0.2. HTTP Response Structure

An HTTP response contains the server's reply to the client's request.

#### 1. Status Line

**Format:**
```
HTTP/1.1 STATUS_CODE STATUS_MESSAGE
```

**Common Status Codes:**
- **200 OK** - Request successful
- **201 Created** - Resource created successfully
- **400 Bad Request** - Invalid request
- **401 Unauthorized** - Authentication required
- **403 Forbidden** - Access denied
- **404 Not Found** - Resource not found
- **429 Too Many Requests** - Rate limit exceeded
- **500 Internal Server Error** - Server error

**Example:**
```
HTTP/1.1 200 OK
HTTP/1.1 201 Created
HTTP/1.1 400 Bad Request
HTTP/1.1 404 Not Found
HTTP/1.1 500 Internal Server Error
```

#### 2. Response Headers

Similar to request headers, but sent by the server.

#### Standard Response Headers

**Content-Type** - Format of response body:
```
Content-Type: application/json
Content-Type: text/html
Content-Type: image/jpeg
Content-Type: application/pdf
```

**Content-Length** - Size of response body:
```
Content-Length: 1234
```

**Set-Cookie** - Set cookies in browser:
```
Set-Cookie: sessionId=abc123; Path=/; HttpOnly
Set-Cookie: theme=dark; Path=/; Max-Age=3600
```

**Location** - Redirect URL:
```
Location: https://example.com/new-page
```

**Cache-Control** - Caching instructions:
```
Cache-Control: no-cache
Cache-Control: max-age=3600
Cache-Control: public, max-age=31536000
```

**Access-Control-Allow-Origin** - CORS header:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Origin: http://localhost:3000
```

**Access-Control-Allow-Methods** - Allowed HTTP methods (CORS):
```
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
```

**Access-Control-Allow-Headers** - Allowed headers (CORS):
```
Access-Control-Allow-Headers: Content-Type, Authorization
```

**RateLimit-Limit** - Rate limiting info:
```
RateLimit-Limit: 100
RateLimit-Remaining: 95
RateLimit-Reset: 1704067200
```

**WWW-Authenticate** - Authentication challenge:
```
WWW-Authenticate: Bearer realm="api"
```

#### Custom Response Headers

```
X-Request-ID: unique-request-id
X-Response-Time: 123ms
X-Custom-Header: custom-value
```

#### 3. Response Body

The actual data returned to the client.

#### Common Response Formats

**JSON Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

**HTML Response:**
```html
<!DOCTYPE html>
<html>
<head>
  <title>Page Title</title>
</head>
<body>
  <h1>Hello World</h1>
</body>
</html>
```

**Plain Text Response:**
```
Success: User created
```

**Error Response (JSON):**
```json
{
  "success": false,
  "error": "Invalid request",
  "message": "Username is required"
}
```

#### Complete Response Example

**Success Response (JSON):**
```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 89
Access-Control-Allow-Origin: *
X-Request-ID: abc-123-def

{
  "success": true,
  "data": {
    "id": 123,
    "username": "john_doe"
  }
}
```

**Error Response:**
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
Content-Length: 67

{
  "success": false,
  "error": "Validation failed",
  "message": "Email is required"
}
```

**File Response:**
```http
HTTP/1.1 200 OK
Content-Type: image/jpeg
Content-Length: 123456
Cache-Control: public, max-age=31536000

[binary image data]
```

---

### 0.3. Understanding Content-Type

Content-Type is crucial for determining how to parse request/response data.

#### Request Content-Types

| Content-Type | Use Case | Example |
|-------------|----------|---------|
| `application/json` | JSON data | `{"name": "John"}` |
| `application/x-www-form-urlencoded` | HTML forms | `name=John&age=30` |
| `multipart/form-data` | File uploads | Form with files |
| `text/plain` | Plain text | `Hello World` |
| `application/xml` | XML data | `<user><name>John</name></user>` |

#### Response Content-Types

| Content-Type | Use Case | Example |
|-------------|----------|---------|
| `application/json` | API responses | `{"data": {...}}` |
| `text/html` | Web pages | `<html>...</html>` |
| `image/jpeg` | Images | Binary image data |
| `application/pdf` | PDF files | Binary PDF data |
| `text/css` | Stylesheets | CSS code |
| `application/javascript` | JavaScript | JS code |

---

### 0.4. Understanding Authorization

Authorization headers authenticate requests.

#### Bearer Token (JWT)
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Usage:**
```javascript
// Frontend
fetch('/api/data', {
  headers: {
    'Authorization': 'Bearer ' + token
  }
});

// Backend (Express)
const token = req.headers.authorization?.split(' ')[1];
```

#### Basic Authentication
```
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

**Format:** Base64 encoded `username:password`
```javascript
// Create Basic Auth header
const credentials = Buffer.from('username:password').toString('base64');
// Result: dXNlcm5hbWU6cGFzc3dvcmQ=
```

#### API Key
```
Authorization: ApiKey your-api-key-here
X-API-Key: your-api-key-here
```

---

### 0.5. Request Object in Express (`req`)

When Express receives a request, it creates a `req` object containing:

### Request Properties

**Headers:**
```javascript
req.headers              // All headers
req.headers.authorization
req.headers['content-type']
req.get('authorization')  // Get specific header
```

**Body:**
```javascript
req.body                 // Parsed body (after middleware)
req.body.username        // Access body fields
```

**Query Parameters:**
```javascript
req.query                // Query string parameters
req.query.id             // ?id=123
req.query.page           // ?page=1&limit=10
```

**Route Parameters:**
```javascript
req.params               // Route parameters
req.params.id            // /users/:id
```

**Files:**
```javascript
req.file                 // Single file (multer)
req.files                // Multiple files (multer)
```

**Method and URL:**
```javascript
req.method               // GET, POST, PUT, DELETE
req.url                  // /api/users?id=123
req.path                 // /api/users
req.originalUrl          // Full original URL
```

**IP and Host:**
```javascript
req.ip                   // Client IP address
req.hostname             // Hostname
req.protocol             // http or https
```

---

### 0.6. Response Object in Express (`res`)

The `res` object is used to send responses:

### Response Methods

**Send JSON:**
```javascript
res.json({ success: true, data: {...} });
```

**Send Status + JSON:**
```javascript
res.status(201).json({ success: true });
```

**Send Text:**
```javascript
res.send('Hello World');
```

**Set Headers:**
```javascript
res.set('X-Custom-Header', 'value');
res.setHeader('Content-Type', 'application/json');
```

**Set Status:**
```javascript
res.status(404);
res.status(200).json({ data: {...} });
```

**Redirect:**
```javascript
res.redirect('/new-page');
res.redirect(301, '/permanent-redirect');
```

**Send File:**
```javascript
res.sendFile('/path/to/file.pdf');
```

---

### 0.7. Quick Reference: Request vs Response

| Component | Request | Response |
|-----------|---------|----------|
| **Start Line** | `METHOD /path HTTP/1.1` | `HTTP/1.1 STATUS_CODE STATUS_MESSAGE` |
| **Headers** | Request metadata | Response metadata |
| **Body** | Data sent to server | Data sent to client |
| **Content-Type** | Format of request body | Format of response body |
| **Authorization** | Client credentials | Usually not present |
| **Set-Cookie** | Cookie header (sent) | Set-Cookie header (received) |
| **Status Code** | Not applicable | 200, 404, 500, etc. |

---

### 0.8. How Libraries Use This Structure

### Express
- **Parses headers** to determine content type
- **Extracts body** based on Content-Type
- **Provides `req` and `res`** objects with all this data

### Multer
- **Reads `Content-Type: multipart/form-data`** header
- **Parses multipart body** with boundaries
- **Extracts files and form fields**

### CORS
- **Reads `Origin` header** from request
- **Adds CORS headers** to response (`Access-Control-Allow-Origin`)

### express.json()
- **Checks `Content-Type: application/json`** header
- **Parses JSON body** into `req.body`

### express.urlencoded()
- **Checks `Content-Type: application/x-www-form-urlencoded`** header
- **Parses URL-encoded body** into `req.body`

---

### 0.9. Understanding package.json

**File:** `package.json`  
**Type:** Configuration File  
**Purpose:** Project metadata and configuration file for Node.js projects

#### What is package.json?

`package.json` is a JSON file that contains metadata about your Node.js project. It defines:
- Project name, version, and description
- Dependencies (packages your project needs)
- Scripts (commands you can run)
- Entry point (main file of your application)
- Module system (CommonJS or ES Modules)
- And much more

#### Why package.json is Important

- ✅ **Dependency Management:** Lists all packages your project needs
- ✅ **Project Configuration:** Defines project settings and metadata
- ✅ **Scripts:** Defines custom commands (start, test, build, etc.)
- ✅ **Entry Point:** Specifies which file Node.js should run
- ✅ **Module System:** Determines if you use CommonJS or ES Modules
- ✅ **Version Control:** Tracks project version and dependencies

#### Basic package.json Structure

```json
{
  "name": "my-node-app",
  "version": "1.0.0",
  "description": "My Node.js application",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
```

#### The "main" Field - Entry Point Configuration

**Purpose:** Specifies the main entry point of your application

**Default Behavior:**
- If `package.json` doesn't have a `"main"` field, Node.js looks for:
  1. `index.js`
  2. `index.node`
  3. `index.json`
- If none found, an error occurs

**Changing the Entry Point:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "server.js"  // Changed from default "index.js"
}
```

**Real-World Examples:**

**Example 1: Default Entry Point (index.js)**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "index.js"  // Explicitly set to index.js
}
```

**Example 2: Custom Entry Point**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "server.js"  // Custom entry point
}
```

**Example 3: Entry Point in Subdirectory**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "src/index.js"  // Entry point in src folder
}
```

**How It Works:**
```javascript
// When someone does: require('my-app')
// Node.js looks for the file specified in "main" field

// If main is "index.js":
const myApp = require('my-app');
// Node.js loads: node_modules/my-app/index.js

// If main is "server.js":
const myApp = require('my-app');
// Node.js loads: node_modules/my-app/server.js
```

#### JavaScript Module Systems: CommonJS vs ES Modules

Node.js supports two different module systems for importing/exporting code.

##### CommonJS (Traditional Node.js Style)

**What it is:** The original module system in Node.js (used by default)

**Syntax:**
```javascript
// Exporting (module.exports)
module.exports = {
  name: 'John',
  age: 30
};

// Or
exports.name = 'John';
exports.age = 30;

// Importing (require)
const user = require('./user.js');
const express = require('express');
```

**package.json Configuration:**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "index.js"
  // No "type" field = CommonJS (default)
}
```

**File Extension:** `.js` (default)

**Real-World Example:**
```javascript
// user.js (CommonJS)
module.exports = {
  getName: () => 'John Doe',
  getAge: () => 30
};

// index.js (CommonJS)
const user = require('./user.js');
console.log(user.getName()); // "John Doe"
```

##### ES Modules (ES2015/ES6 Modules) - Modern JavaScript

**What it is:** Modern JavaScript module system (standard in browsers, now supported in Node.js)

**Syntax:**
```javascript
// Exporting (export)
export const name = 'John';
export const age = 30;

// Or default export
export default {
  name: 'John',
  age: 30
};

// Importing (import)
import express from 'express';
import { name, age } from './user.js';
```

**package.json Configuration:**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "type": "module",  // Enable ES Modules
  "main": "index.js"
}
```

**File Extension:** `.js` (with `"type": "module"`) or `.mjs`

**Real-World Example:**
```javascript
// user.js (ES Module)
export const getName = () => 'John Doe';
export const getAge = () => 30;

// index.js (ES Module)
import { getName, getAge } from './user.js';
console.log(getName()); // "John Doe"
```

#### Comparison: CommonJS vs ES Modules

| Feature | CommonJS | ES Modules |
|---------|----------|------------|
| **Syntax** | `require()` / `module.exports` | `import` / `export` |
| **package.json** | No `"type"` field (default) | `"type": "module"` |
| **File Extension** | `.js` | `.js` (with type: "module") or `.mjs` |
| **When Available** | Since Node.js v0.1.0 | Since Node.js v12.0.0 |
| **Loading** | Synchronous (blocking) | Asynchronous (non-blocking) |
| **Browser Support** | ❌ No (needs bundler) | ✅ Yes (native) |
| **Tree Shaking** | ❌ No | ✅ Yes |
| **Default** | ✅ Yes (Node.js default) | ❌ No (must enable) |

#### Complete package.json Examples

**Example 1: CommonJS Project (Default)**
```json
{
  "name": "my-express-app",
  "version": "1.0.0",
  "description": "Express application using CommonJS",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
```

**Example 2: ES Modules Project**
```json
{
  "name": "my-express-app",
  "version": "1.0.0",
  "description": "Express application using ES Modules",
  "type": "module",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0"
  }
}
```

**Example 3: Mixed Project (CommonJS with Custom Entry)**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### Key package.json Fields Explained

**Essential Fields:**
```json
{
  "name": "my-app",              // Package name (required)
  "version": "1.0.0",            // Version (required)
  "description": "My app",       // Description
  "main": "index.js",            // Entry point (important!)
  "type": "module",              // Module system: "module" or omitted (CommonJS)
  "scripts": {                   // Custom commands
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {              // Production dependencies
    "express": "^4.18.2"
  },
  "devDependencies": {          // Development dependencies
    "nodemon": "^2.0.20"
  },
  "keywords": ["node", "express"], // Keywords for npm
  "author": "Your Name",         // Author
  "license": "ISC"              // License
}
```

#### Real-World Scenarios

**Scenario 1: Changing Entry Point from index.js to server.js**

**Before:**
```json
{
  "name": "my-app",
  "version": "1.0.0"
  // No "main" field - defaults to index.js
}
```

**After:**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "server.js"  // Changed entry point
}
```

**Result:** When someone runs `node .` or `require('my-app')`, Node.js will look for `server.js` instead of `index.js`.

**Scenario 2: Using ES Modules Instead of CommonJS**

**Before (CommonJS):**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "main": "index.js"
  // No "type" field = CommonJS
}
```

```javascript
// index.js (CommonJS)
const express = require('express');
module.exports = express();
```

**After (ES Modules):**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "type": "module",  // Enable ES Modules
  "main": "index.js"
}
```

```javascript
// index.js (ES Module)
import express from 'express';
export default express();
```

**Scenario 3: Project Structure with Custom Entry Point**

**Directory Structure:**
```
my-project/
  ├── package.json
  ├── src/
  │   └── server.js    (main entry point)
  ├── config/
  │   └── database.js
  └── routes/
      └── api.js
```

**package.json:**
```json
{
  "name": "my-project",
  "version": "1.0.0",
  "main": "src/server.js",  // Custom entry point
  "scripts": {
    "start": "node src/server.js"
  }
}
```

#### Important Notes

- ✅ **"main" field is optional** - If omitted, Node.js defaults to `index.js`
- ✅ **"type" field determines module system** - Omit for CommonJS, add `"type": "module"` for ES Modules
- ✅ **You can't mix both** in the same project (without special configuration)
- ✅ **CommonJS is default** - No need to specify anything for CommonJS
- ✅ **ES Modules require explicit enablement** - Must add `"type": "module"` to package.json
- ⚠️ **File extensions matter** - ES Modules can use `.mjs` extension without `"type": "module"`
- ⚠️ **Breaking change** - Changing `"type": "module"` affects ALL `.js` files in your project
- ⚠️ **Most Node.js projects use CommonJS** - It's the standard and most compatible

#### Quick Reference

**CommonJS (Default):**
```json
{
  "main": "index.js"
  // No "type" field
}
```
```javascript
// Use require() and module.exports
const express = require('express');
module.exports = app;
```

**ES Modules:**
```json
{
  "type": "module",
  "main": "index.js"
}
```
```javascript
// Use import and export
import express from 'express';
export default app;
```

**Change Entry Point:**
```json
{
  "main": "server.js"  // Change from default index.js
}
```

---

## 1. Express

**Package:** `express`  
**Type:** External NPM Package  
**Purpose:** Web application framework for Node.js

### Description
Express is a minimal and flexible Node.js web application framework that provides a robust set of features for building web and mobile applications. It simplifies the process of writing server-side code by providing utilities for HTTP requests, responses, routing, and middleware.

### Key Features
- **Routing:** Define routes for different HTTP methods (GET, POST, PUT, DELETE, etc.)
- **Middleware:** Chain of functions that execute during request/response cycle
- **Template Engines:** Support for various template engines (EJS, Pug, Handlebars)
- **Static Files:** Serve static files (HTML, CSS, JavaScript, images)
- **Request/Response Objects:** Enhanced objects with additional methods and properties

### Common Usage
```javascript
const app = express();
app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});
app.listen(3000);
```

### Installation
```bash
npm install express
```

---

### 1.1. App.use() - Understanding Express Middleware

### What is `app.use()`?

**Purpose:** Register middleware functions that execute for every HTTP request (or specific routes)

`app.use()` is one of the most fundamental methods in Express. It's used to mount middleware functions that process requests before they reach your route handlers.

### Key Concepts

**Middleware:** Functions that have access to:
- `req` (request object)
- `res` (response object)
- `next` (function to pass control to next middleware)

**Execution Flow:**
```
Request → Middleware 1 → Middleware 2 → Middleware 3 → Route Handler → Response
```

### Syntax

```javascript
// Basic syntax
app.use(middlewareFunction);

// With path (only applies to specific routes)
app.use('/path', middlewareFunction);

// Multiple middleware
app.use(middleware1, middleware2, middleware3);
```

### Real-World Scenarios

#### Scenario 1: Global Middleware (All Routes)

**Applies to ALL requests:**
```javascript
// This middleware runs for EVERY request
app.use(express.json());           // Parse JSON for all routes
app.use(cors());                   // Enable CORS for all routes
app.use(express.urlencoded({ extended: true })); // Parse forms for all routes
```

**Example:**
```javascript
app.use(express.json());  // Runs for ALL routes

app.get('/users', (req, res) => {
  // express.json() already ran, req.body is available
  res.json({ users: [] });
});

app.post('/login', (req, res) => {
  // express.json() already ran, req.body is available
  console.log(req.body);  // Parsed JSON object
});
```

#### Scenario 2: Path-Specific Middleware

**Applies only to routes starting with the path:**
```javascript
// Only applies to routes starting with '/api'
app.use('/api', someMiddleware);

// These routes will use the middleware:
// GET /api/users     ✅ Uses middleware
// POST /api/login    ✅ Uses middleware
// GET /api/data      ✅ Uses middleware

// These routes will NOT use the middleware:
// GET /users         ❌ No middleware
// GET /home          ❌ No middleware
```

**Example:**
```javascript
// Rate limiter only for API routes
app.use('/api', rateLimiter);

app.get('/api/users', (req, res) => {
  // Rate limiter applies here
  res.json({ users: [] });
});

app.get('/home', (req, res) => {
  // Rate limiter does NOT apply here
  res.send('Home page');
});
```

#### Scenario 3: Multiple Middleware Functions

**Chain multiple middleware:**
```javascript
// Multiple middleware functions
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// Or combine them
app.use(
  express.json(),
  express.urlencoded({ extended: true }),
  cors()
);
```

**Execution order matters:**
```javascript
// Middleware executes in order
app.use(middleware1);  // Runs first
app.use(middleware2);  // Runs second
app.use(middleware3);  // Runs third

// Then routes
app.get('/users', handler);  // All middleware ran before this
```

#### Scenario 4: Your Current Code

**From your server.js:**
```javascript
// Middleware - applies to ALL routes
app.use(cors());                              // Enable CORS globally
app.use(express.json());                      // Parse JSON globally
app.use(express.urlencoded({ extended: true })); // Parse forms globally
app.use("/uploads", express.static("uploads")); // Serve static files at /uploads

// Path-specific middleware
app.use("/api/", generalLimiter);  // Rate limit only for /api routes
```

**What this means:**
- ✅ **CORS, JSON, URL-encoded** apply to ALL routes
- ✅ **Static files** served at `/uploads` path
- ✅ **Rate limiting** applies only to routes starting with `/api`

### Understanding Path Matching

**Path matching rules:**
```javascript
app.use('/api', middleware);

// ✅ Matches (starts with /api):
// /api
// /api/users
// /api/users/123
// /api/login

// ❌ Doesn't match:
// /apiusers
// /user/api
// /home
```

**Root path:**
```javascript
app.use('/', middleware);  // Matches ALL routes (same as app.use(middleware))
app.use(middleware);       // Also matches ALL routes
```

### Middleware Execution Order

**Critical:** Middleware executes in the order it's defined!

```javascript
// Order matters!
app.use(middleware1);  // 1st - Runs first
app.use(middleware2);  // 2nd - Runs second
app.use(middleware3);  // 3rd - Runs third

app.get('/users', handler);  // Route handler runs last
```

**Example showing order:**
```javascript
app.use((req, res, next) => {
  console.log('Middleware 1');
  next();  // Pass to next middleware
});

app.use((req, res, next) => {
  console.log('Middleware 2');
  next();
});

app.get('/test', (req, res) => {
  console.log('Route handler');
  res.send('Done');
});

// Request to /test outputs:
// Middleware 1
// Middleware 2
// Route handler
```

### Common Middleware Patterns

#### Pattern 1: Global Configuration
```javascript
// Apply to all routes
app.use(express.json());
app.use(cors());
app.use(express.static('public'));
```

#### Pattern 2: Route-Specific
```javascript
// Apply only to specific routes
app.use('/api', rateLimiter);
app.use('/admin', adminAuth);
app.use('/uploads', express.static('uploads'));
```

#### Pattern 3: Conditional Middleware
```javascript
// Apply conditionally
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));  // Logging only in development
}
```

#### Pattern 4: Error Handling
```javascript
// Error handling middleware (must be last)
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Something went wrong' });
});
```

### Complete Example: Understanding Your Server

**Your server.js structure:**
```javascript
// 1. Global middleware (runs for ALL requests)
app.use(cors());                              // Enable CORS
app.use(express.json());                      // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse form data
app.use("/uploads", express.static("uploads")); // Serve static files

// 2. Route-specific middleware
app.use("/api/", generalLimiter);  // Rate limit only /api routes

// 3. Route handlers (would go here)
app.get('/api/users', (req, res) => {
  // All global middleware ran
  // Rate limiter ran (because path starts with /api)
  res.json({ users: [] });
});

app.get('/home', (req, res) => {
  // All global middleware ran
  // Rate limiter did NOT run (path doesn't start with /api)
  res.send('Home page');
});
```

### Request Flow Example

**When a request comes to `/api/users`:**

```
1. Request arrives: GET /api/users
   ↓
2. cors() middleware runs
   ↓
3. express.json() middleware runs
   ↓
4. express.urlencoded() middleware runs
   ↓
5. express.static() checks - doesn't match /uploads, continues
   ↓
6. generalLimiter middleware runs (matches /api)
   ↓
7. Route handler executes: app.get('/api/users', ...)
   ↓
8. Response sent
```

**When a request comes to `/uploads/image.jpg`:**

```
1. Request arrives: GET /uploads/image.jpg
   ↓
2. cors() middleware runs
   ↓
3. express.json() middleware runs
   ↓
4. express.urlencoded() middleware runs
   ↓
5. express.static() matches /uploads - serves image.jpg
   ↓
6. Response sent (stops here, doesn't reach route handlers)
```

### Key Points to Remember

1. **`app.use()` registers middleware** that runs before route handlers
2. **Order matters** - middleware executes in the order defined
3. **Path matching** - `/api` matches all routes starting with `/api`
4. **Global vs Specific** - Without path, applies to all; with path, applies to matching routes
5. **Middleware can modify** `req` and `res` objects
6. **Call `next()`** to pass control to next middleware/route
7. **Static files** can stop the request chain (if file is found)

### Common Mistakes

❌ **Wrong - Middleware after routes:**
```javascript
app.get('/users', handler);
app.use(express.json());  // ❌ Too late! Routes already defined
```

✅ **Correct - Middleware before routes:**
```javascript
app.use(express.json());  // ✅ Define middleware first
app.get('/users', handler);
```

❌ **Wrong - Wrong path format:**
```javascript
app.use('./api', middleware);  // ❌ Should be '/api'
```

✅ **Correct - Proper path format:**
```javascript
app.use('/api', middleware);  // ✅ Correct
```

---

### 1.2. Middleware: Global vs Path, app.use vs app.METHOD, Types

This section goes deeper into **where** and **how** middleware is added (global vs path), the difference between **app.use()** and **app.get() / app.post() / … app.delete()**, mounting routers, and the **types** of middleware in Express.

---

#### 1.2.1. Adding Middleware: Global and Path-Level

**Global middleware** — Runs for **every** request, regardless of path or method. Use when the middleware must run for all routes (e.g. CORS, body parsers, request ID).

```javascript
// No path = applies to ALL routes
app.use(express.json());
app.use(cors());
app.use((req, res, next) => {
  req.requestId = generateId();
  next();
});

// Every request (GET /, GET /api/users, POST /api/login, etc.) goes through these
```

**Path-level middleware** — Runs only for requests whose path **starts with** the given path. Use when the middleware is only needed for a subset of routes (e.g. API auth, rate limit for /api).

```javascript
// Only requests starting with /api go through this
app.use('/api', apiAuthMiddleware);

// Only requests starting with /admin go through this
app.use('/admin', adminAuthMiddleware);

// Only requests starting with /uploads (e.g. /uploads/photo.jpg) go through this
app.use('/uploads', express.static('uploads'));
```

**Path matching rules:**

- `app.use('/api', mw)` matches `/api`, `/api/users`, `/api/users/1`, `/api/v1/orders`, etc. It does **not** match `/apix` or `/api-users`.
- Path is a **prefix** match. For exact path match, define a route: `app.get('/api', handler)`.
- You can use a **router** as middleware: `app.use('/api', apiRouter)` — see 1.2.3.

**Multiple middleware on the same path:**

```javascript
app.use('/api', cors(), express.json(), rateLimiter, apiRouter);
// Order: cors → express.json → rateLimiter → apiRouter (for requests to /api*)
```

---

#### 1.2.2. app.use() vs app.get() / app.post() / … app.delete()

| Aspect | app.use([path], middleware...) | app.get(path, handler...) / app.post(...) / app.put(...) / app.delete(...) |
|--------|-------------------------------|-----------------------------------------------------------------------------|
| **HTTP method** | **All methods** (GET, POST, PUT, DELETE, PATCH, etc.) that match the path. | **Only the method** you specify (e.g. `app.get` only for GET). |
| **Path** | Optional. No path = all paths. With path = prefix match (e.g. `/api` matches `/api/*`). | Required. Exact or parameterized path (e.g. `/api/users`, `/api/users/:id`). |
| **Typical use** | Mount middleware (parsers, auth, routers) that run **before** a final response. | Define **route handlers** that send the response (or pass to next). |
| **Multiple handlers** | Yes: `app.use(mw1, mw2, mw3)`. | Yes: `app.get('/x', mw1, mw2, handler)` — mw1, mw2 run in order, then handler. |

**app.use() — all methods:**

```javascript
app.use('/api', (req, res, next) => {
  console.log('Runs for GET, POST, PUT, DELETE, PATCH, ... to /api*');
  next();
});
```

**app.METHOD() — one method per route:**

```javascript
app.get('/api/users', getUsers);       // Only GET /api/users
app.post('/api/users', createUser);    // Only POST /api/users
app.put('/api/users/:id', updateUser); // Only PUT /api/users/:id
app.delete('/api/users/:id', deleteUser); // Only DELETE /api/users/:id
app.patch('/api/users/:id', patchUser);   // Only PATCH /api/users/:id
```

**Using both: middleware + route handler on the same path**

You can attach multiple functions to a **route**; they run in order. The last one usually sends the response.

```javascript
// Middleware then handler for GET /api/users
app.get('/api/users', authMiddleware, (req, res) => {
  res.json({ users: [] });
});

// Same idea: multiple middleware + handler
app.post('/api/orders', validateBody, authMiddleware, createOrderHandler);
```

**Summary:**

- **app.use()** — “For this path (or all paths), run these middleware for **every** HTTP method.”
- **app.get()**, **app.post()**, etc. — “For this method + path, run these handlers (middleware + final handler).”

---

#### 1.2.3. app.use(path, Middleware, Router) and Mounting Routers

You can mount a **router** (or several middleware + router) at a path. The router is just middleware that dispatches to its own routes.

**Mounting a router:**

```javascript
const express = require('express');
const app = express();
const apiRouter = require('./routes/api');  // Router with its own .get(), .post(), etc.

// All routes defined on apiRouter are under /api
app.use('/api', apiRouter);
// So apiRouter.get('/users', ...) is actually GET /api/users
//     apiRouter.post('/orders', ...) is actually POST /api/orders
```

**app.use(path, middleware, router)** — Run one or more middleware for that path, then the router:

```javascript
// For any request to /api*, run authMiddleware first, then apiRouter
app.use('/api', authMiddleware, apiRouter);

// Multiple middleware then router
app.use('/api', cors(), express.json(), rateLimiter, authMiddleware, apiRouter);
```

**Router as middleware:**  
A **Router** instance is middleware. When you do `app.use('/api', apiRouter)`:

1. Request comes in for e.g. GET /api/users.
2. Express matches path `/api` and runs `apiRouter` (and any middleware before it).
3. The router strips the prefix and matches its own routes (e.g. `/users`).
4. The matching route handler on the router runs.

**Example: router file (routes/api.js):**

```javascript
const express = require('express');
const router = express.Router();  // Router, not app

router.get('/users', (req, res) => res.json({ users: [] }));
router.post('/users', (req, res) => res.status(201).json({ id: 1 }));
router.get('/users/:id', (req, res) => res.json({ user: {} }));

module.exports = router;
```

**Main app:**

```javascript
const apiRouter = require('./routes/api');
app.use(express.json());
app.use('/api', apiRouter);  // GET /api/users, POST /api/users, GET /api/users/:id
```

**Path in router is relative to mount path:**  
- Mount: `app.use('/api', apiRouter)`.  
- Router route: `router.get('/users', ...)`.  
- Full path: `/api` + `/users` = **GET /api/users**.

---

#### 1.2.4. Types of Middleware (Application, Router, Custom, Error, Built-in, Third-party)

**1. Application-level middleware**  
Bound to the **app** instance with `app.use()` or `app.METHOD()`. Runs for every request (or every request matching a path/method).

```javascript
app.use(express.json());
app.use('/api', apiAuth);
app.get('/health', (req, res) => res.send('OK'));
```

**2. Router-level middleware**  
Bound to a **Router** instance with `router.use()` or `router.METHOD()`. Runs only when the router is hit (e.g. when mounted at `/api`).

```javascript
const router = express.Router();
router.use(authForApi);           // All routes on this router
router.get('/users', getUsers);
router.post('/users', createUser);
app.use('/api', router);
```

**3. Custom middleware (user-defined)**  
Functions **you write** that follow the middleware signature: `(req, res, next) => { ... }`. They are not from Express (built-in) or npm (third-party); they are your own logic (auth, logging, request ID, validation, etc.).

```javascript
// Custom middleware: add request ID to every request
function requestIdMiddleware(req, res, next) {
  req.requestId = crypto.randomUUID();
  next();
}

// Custom middleware: check auth for /api routes
function authMiddleware(req, res, next) {
  const token = req.headers.authorization;
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  req.user = decodeToken(token);  // your logic
  next();
}

// Custom middleware: log request time
function logTimeMiddleware(req, res, next) {
  req.startTime = Date.now();
  res.on('finish', () => {
    console.log(`${req.method} ${req.url} ${Date.now() - req.startTime}ms`);
  });
  next();
}

// Use your custom middleware (global or path-level)
app.use(requestIdMiddleware);
app.use('/api', authMiddleware);
app.use(logTimeMiddleware);
```

**Rules for custom middleware:**  
- Signature: `(req, res, next)` — three arguments. Express uses this to recognize middleware.  
- Call **next()** to pass control to the next middleware or route; otherwise the request hangs.  
- Call **next(err)** to pass an error to error-handling middleware.  
- Optionally send a response (e.g. `res.status(401).json(...)`) and **do not** call `next()` if you want to end the chain (e.g. reject unauthorized).

**4. Error-handling middleware**  
Has **four** arguments: `(err, req, res, next)`. Express treats it as error middleware and runs it when something calls `next(err)` or throws in a route/middleware.

```javascript
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Something went wrong' });
});
```

- Must be defined **after** routes and other middleware so errors from them can be passed here.
- If you call `next()` with no argument, Express continues to the next non-error middleware; if you call `next(err)`, Express jumps to the next error middleware.

**5. Built-in middleware**  
Provided by Express (no extra install):

| Middleware | Purpose |
|------------|--------|
| **express.json()** | Parses JSON body → `req.body`. |
| **express.urlencoded({ extended: true })** | Parses form body → `req.body`. |
| **express.static(root)** | Serves static files from a directory. |
| **express.Router()** | Creates a router (mini app) to mount with `app.use(path, router)`. |

**6. Third-party middleware**  
From npm: **cors**, **morgan**, **helmet**, **express-rate-limit**, **multer**, etc. You mount them with `app.use()` (global or path-level).

```javascript
const cors = require('cors');
const morgan = require('morgan');
app.use(cors());
app.use(morgan('dev'));
```

---

#### 1.2.5. Middleware Execution Order and next()

**Order:**  
Middleware runs in the **order** it is defined. Request flows: first global middleware, then path-matched middleware, then route handlers (or router’s middleware and routes). If any middleware sends a response (e.g. `res.send()`) and does not call `next()`, the chain **stops** — later middleware and route handlers for that request are not run.

**next():**  
- **next()** — Pass control to the **next** middleware or route handler.  
- **next(err)** — Pass an error to Express; Express skips to the **next error-handling** middleware (4-arg function).  
- If you never call `next()` and never send a response, the request will **hang** (client waits forever).

**Example flow:**

```javascript
app.use((req, res, next) => {
  console.log('1. Global');
  next();
});
app.use('/api', (req, res, next) => {
  console.log('2. /api middleware');
  next();
});
app.get('/api/users', (req, res) => {
  console.log('3. GET /api/users handler');
  res.json({ users: [] });
});
// Request GET /api/users → logs: 1. Global, 2. /api middleware, 3. GET /api/users handler
```

**Stopping the chain:**  
If a middleware (or route) sends a response and does not call `next()`, the chain stops. Example: `express.static()` serves a file and sends the response, so route handlers below are not run for that request.

---

#### 1.2.6. Middleware Signature, Recommended Order, Async, and Param

**How Express recognizes middleware (signature / arity):**  
Express treats a function as **middleware** or **error-handling middleware** based on the **number of arguments** (arity):

- **3 arguments** — `(req, res, next)` → **Normal middleware**. Runs in the normal chain. Call `next()` to continue or `next(err)` to jump to error middleware.
- **4 arguments** — `(err, req, res, next)` → **Error-handling middleware**. Express runs it only when an error is passed via `next(err)` or when a previous handler throws. Must be defined **after** routes and other middleware.

So the **name** of the parameters does not matter to Express; only the **length** of the function signature does. By convention we use `(req, res, next)` and `(err, req, res, next)`.

---

**Recommended loading order (best practice):**  
Define middleware and routes in this order so parsing, auth, and errors behave correctly:

1. **Body parsers and global config** — `express.json()`, `express.urlencoded()`, `cors()`, etc., so `req.body` and headers are ready.
2. **Custom middleware** (auth, logging, request ID) — so they run for all (or path-matched) requests before routes.
3. **Routes** — `app.get()`, `app.post()`, `app.use('/api', router)`, etc.
4. **Static files** (optional) — `express.static()` for assets; often before "catch-all" so specific routes are tried first.
5. **404 handler** (optional) — route that runs when no route matched; e.g. `app.use((req, res) => res.status(404).send('Not found'))`.
6. **Error-handling middleware** — `app.use((err, req, res, next) => { ... })` **last**, so any `next(err)` from above is caught.

Example:

```javascript
app.use(express.json());
app.use(cors());
app.use(requestIdMiddleware);
app.use('/api', authMiddleware);
app.get('/api/users', getUsers);
app.use(express.static('public'));
app.use((req, res) => res.status(404).json({ error: 'Not found' }));
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});
```

---

**Async middleware:**  
If you use **async/await** inside middleware (or a route handler), Express does **not** catch rejected promises. You must catch errors and call **next(err)** yourself; otherwise the request may hang and the client will not get a response.

```javascript
// ❌ Wrong: unhandled rejection if getUserId() throws or rejects
app.use('/api', async (req, res, next) => {
  req.user = await getUserId(req);
  next();
});

// ✅ Right: catch and pass to error handler
app.use('/api', async (req, res, next) => {
  try {
    req.user = await getUserId(req);
    next();
  } catch (err) {
    next(err);
  }
});
```

Alternatively, wrap async middleware in a helper that forwards rejections to `next` (e.g. a small "asyncHandler" wrapper). The important point: **any async middleware must eventually call next(err) on failure**.

---

**Param middleware (router.param()):**  
**Param middleware** runs when a route has a **parameter** (e.g. `:id`) and is useful to load or validate a resource once before any route that uses that param.

```javascript
const router = express.Router();

// Runs when any route on this router has :id in its path
router.param('id', (req, res, next, id) => {
  // Load user by id, attach to req, or call next(err) if not found
  User.findById(id)
    .then((user) => {
      if (!user) return next(new Error('Not found'));
      req.user = user;
      next();
    })
    .catch(next);
});

router.get('/users/:id', (req, res) => {
  // req.user is already set by param middleware
  res.json(req.user);
});
```

- **Signature:** `(req, res, next, paramValue)` — the fourth argument is the value of the param (e.g. `id` for `:id`).
- Only applies to the **router** on which it is defined (and that router’s routes). It runs **before** the route handler for any route that includes that parameter.

---

**res.locals and app.locals:**  
- **res.locals** — An object for request-scoped data. You can set properties (e.g. `res.locals.user = req.user`) in middleware; they are available in later middleware and in route handlers, and often in templates (e.g. `res.render('view', { ...res.locals })`). Useful to pass data from middleware to the next handler or view without mutating `req`.
- **app.locals** — Application-scoped data (e.g. app name, config) available as `req.app.locals` in every request. Set once at startup.

---

#### 1.2.7. Quick Reference

| Goal | Code |
|------|------|
| Global middleware (all routes) | `app.use(middleware)` |
| Path-level middleware | `app.use('/api', middleware)` |
| Multiple middleware on path | `app.use('/api', mw1, mw2, router)` |
| Route: one method + path | `app.get('/path', handler)` or `app.post('/path', mw, handler)` |
| Mount router at path | `app.use('/api', apiRouter)` |
| Error-handling middleware | `app.use((err, req, res, next) => { ... })` |
| Router-level middleware | `router.use(middleware)` or `router.get('/path', handler)` |
| Custom middleware | `(req, res, next) => { ...; next(); }` — 3 args; call next() or next(err). |
| Param middleware | `router.param('id', (req, res, next, id) => { ... })` — runs when route has :id. |
| Recommended order | Parsers → custom → routes → static → 404 → error handler. |
| Async middleware | Wrap in try/catch and call next(err) on failure; Express does not catch async rejections. |

**Rules to remember:**  
1. Middleware before routes (order matters).  
2. `app.use()` = all methods for that path (or all paths); `app.get()` / `app.post()` etc. = one method + path.  
3. Path in `app.use('/api', router)` is a **prefix**; router paths are **relative** to that prefix.  
4. Call `next()` (or `next(err)` for errors) unless you send a response and want to end the chain.  
5. **Signature:** 3 args `(req, res, next)` = normal middleware; 4 args `(err, req, res, next)` = error middleware (Express uses function arity).

---

## 2. MySQL2 (Promise-based)

**Package:** `mysql2/promise`  
**Type:** External NPM Package  
**Purpose:** MySQL database client with Promise support

### Description
MySQL2 is a fast MySQL client for Node.js with support for promises and async/await. The `/promise` import provides a Promise-based API instead of callback-based, making it easier to work with modern async JavaScript.

---

### 2.0. Connection Methods: Pool vs Single Connection

MySQL2 provides two main ways to connect to the database. Understanding the difference is crucial for choosing the right approach.

### Method 1: Connection Pool (`createPool`) - What You're Using

**What it is:**
- A pool of reusable database connections
- Connections are created once and reused for multiple queries
- Automatically manages connection lifecycle

**How it works:**
```
Application Start
    ↓
Create Pool (10 connections ready)
    ↓
Query 1 → Uses Connection 1 → Returns to Pool
Query 2 → Uses Connection 2 → Returns to Pool
Query 3 → Reuses Connection 1 → Returns to Pool
    ↓
All connections stay alive and ready
```

**Your Current Code:**
```javascript
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: 10,  // 10 connections in pool
});

// Use pool directly
await pool.query('SELECT * FROM users');
```

### Method 2: Single Connection (`createConnection`)

**What it is:**
- One database connection
- Created when needed, closed when done
- Must manually manage connection lifecycle

**How it works:**
```
Query 1 → Create Connection → Execute → Close Connection
Query 2 → Create Connection → Execute → Close Connection
Query 3 → Create Connection → Execute → Close Connection
```

**Example:**
```javascript
// Create a single connection
const connection = await mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Use connection
await connection.query('SELECT * FROM users');

// Must manually close
await connection.end();
```

---

### Comparison: Pool vs Single Connection

#### Performance Comparison

| Aspect | Connection Pool | Single Connection |
|--------|----------------|-------------------|
| **Connection Creation** | Once at startup | Every query |
| **Query Speed** | ⚡ Fast (reuses connections) | 🐢 Slower (creates new each time) |
| **Resource Usage** | Higher (keeps connections alive) | Lower (closes after use) |
| **Concurrent Queries** | ✅ Handles multiple simultaneously | ❌ One at a time |
| **Best For** | Production, high traffic | Development, simple scripts |

#### Detailed Comparison

##### 1. Connection Management

**Pool:**
```javascript
// Create once at startup
const pool = mysql.createPool({...});

// Use anywhere - connections managed automatically
await pool.query('SELECT * FROM users');
await pool.query('SELECT * FROM products');
// No need to close - pool manages it
```

**Single Connection:**
```javascript
// Must create for each operation
const connection = await mysql.createConnection({...});
await connection.query('SELECT * FROM users');
await connection.end();  // Must close manually

// Next query needs new connection
const connection2 = await mysql.createConnection({...});
await connection2.query('SELECT * FROM products');
await connection2.end();
```

##### 2. Concurrent Requests

**Pool (Handles Multiple Simultaneously):**
```javascript
// All these can run at the same time
Promise.all([
  pool.query('SELECT * FROM users'),
  pool.query('SELECT * FROM products'),
  pool.query('SELECT * FROM orders'),
]);
// ✅ Uses different connections from pool
```

**Single Connection (One at a Time):**
```javascript
// Must wait for each to complete
const conn1 = await mysql.createConnection({...});
await conn1.query('SELECT * FROM users');
await conn1.end();

const conn2 = await mysql.createConnection({...});
await conn2.query('SELECT * FROM products');
await conn2.end();
// ❌ Sequential, slower
```

##### 3. Resource Usage

**Pool:**
- Keeps connections alive (uses memory)
- Better for frequent queries
- Higher initial resource usage

**Single Connection:**
- Creates/destroys connections (CPU overhead)
- Better for occasional queries
- Lower memory usage

##### 4. Error Handling

**Pool:**
```javascript
// Pool automatically handles connection errors
// If one connection fails, others still work
try {
  await pool.query('SELECT * FROM users');
} catch (error) {
  // Pool continues to work with other connections
}
```

**Single Connection:**
```javascript
// If connection fails, must recreate
try {
  const connection = await mysql.createConnection({...});
  await connection.query('SELECT * FROM users');
  await connection.end();
} catch (error) {
  // Connection is dead, must create new one
  const newConnection = await mysql.createConnection({...});
}
```

---

### When to Use Each Method

#### Use Connection Pool (`createPool`) When:

✅ **Production applications** - Your current use case  
✅ **High traffic** - Many concurrent requests  
✅ **Frequent queries** - Multiple queries per second  
✅ **Web servers** - Express.js, API servers  
✅ **Long-running applications** - Services that stay alive  
✅ **Multiple users** - Applications with concurrent users  

**Example - Your Server:**
```javascript
// ✅ Perfect use case - Express server with multiple routes
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionLimit: 10,
});

app.get('/api/users', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users');
  res.json(rows);
});

app.get('/api/products', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM products');
  res.json(rows);
});
// Both can run simultaneously using different pool connections
```

#### Use Single Connection (`createConnection`) When:

✅ **Simple scripts** - One-time operations  
✅ **CLI tools** - Command-line utilities  
✅ **Development/testing** - Quick database checks  
✅ **Infrequent queries** - Occasional database access  
✅ **Single-user applications** - Desktop apps  
✅ **Migration scripts** - Database setup scripts  

**Example - Simple Script:**
```javascript
// ✅ Good for one-time script
const connection = await mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'mydb',
});

await connection.query('INSERT INTO logs (message) VALUES (?)', ['Script started']);
await connection.end();
// Script ends, connection closed
```

---

### Code Examples: Pool vs Single Connection

#### Example 1: Handling Multiple Requests

**With Pool (Your Current Approach):**
```javascript
const pool = mysql.createPool({...});

// Route 1 - Can run simultaneously
app.get('/users', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users');
  res.json(rows);
});

// Route 2 - Can run simultaneously with Route 1
app.get('/products', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM products');
  res.json(rows);
});

// ✅ Both routes can handle requests at the same time
// ✅ Uses different connections from pool
```

**With Single Connection (Not Recommended for Servers):**
```javascript
// ❌ Problem: Can only handle one request at a time
let connection;

app.get('/users', async (req, res) => {
  connection = await mysql.createConnection({...});
  const [rows] = await connection.query('SELECT * FROM users');
  await connection.end();
  res.json(rows);
});

app.get('/products', async (req, res) => {
  // Must wait if /users is still running
  connection = await mysql.createConnection({...});
  const [rows] = await connection.query('SELECT * FROM products');
  await connection.end();
  res.json(rows);
});
```

#### Example 2: Performance Test

**Pool (Fast):**
```javascript
const pool = mysql.createPool({...});

// Time: ~100ms for 10 queries (parallel)
const start = Date.now();
await Promise.all([
  pool.query('SELECT * FROM users'),
  pool.query('SELECT * FROM products'),
  pool.query('SELECT * FROM orders'),
  // ... 7 more queries
]);
console.log(`Time: ${Date.now() - start}ms`); // ~100ms
```

**Single Connection (Slow):**
```javascript
// Time: ~1000ms for 10 queries (sequential)
const start = Date.now();
for (let i = 0; i < 10; i++) {
  const conn = await mysql.createConnection({...});
  await conn.query('SELECT * FROM users');
  await conn.end();
}
console.log(`Time: ${Date.now() - start}ms`); // ~1000ms
```

---

### Pool Configuration Explained

#### Why `connectionLimit: 10`?

```javascript
const pool = mysql.createPool({
  connectionLimit: 10,  // Maximum 10 connections
});
```

**What this means:**
- Pool creates up to 10 connections
- If all 10 are busy, new requests wait in queue
- When a connection finishes, it's reused

**Scenarios:**

**Scenario 1: Low Traffic (1-5 concurrent requests)**
```
Request 1 → Connection 1
Request 2 → Connection 2
Request 3 → Connection 3
// Connections 4-10 unused (ready for future requests)
```

**Scenario 2: High Traffic (15 concurrent requests)**
```
Request 1-10 → Connections 1-10 (active)
Request 11-15 → Waiting in queue
// When Connection 1 finishes, Request 11 uses it
```

#### Pool Options You Should Know

```javascript
const pool = mysql.createPool({
  connectionLimit: 10,        // Max connections in pool
  queueLimit: 0,             // Max queued requests (0 = unlimited)
  waitForConnections: true,   // Wait if pool is full
  acquireTimeout: 10000,      // Timeout to get connection
  reconnect: true,           // Auto-reconnect on failure
});
```

---

### Common Mistakes

#### ❌ Mistake 1: Creating Pool for Each Request

```javascript
// ❌ WRONG - Creates new pool every time
app.get('/users', async (req, res) => {
  const pool = mysql.createPool({...});
  const [rows] = await pool.query('SELECT * FROM users');
  res.json(rows);
});
```

**Problem:** Creates new pool for each request (defeats the purpose)

**✅ Correct:**
```javascript
// ✅ RIGHT - Create pool once at startup
const pool = mysql.createPool({...});

app.get('/users', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users');
  res.json(rows);
});
```

#### ❌ Mistake 2: Using Single Connection in Production

```javascript
// ❌ WRONG - For production server
let connection;

app.get('/users', async (req, res) => {
  connection = await mysql.createConnection({...});
  const [rows] = await connection.query('SELECT * FROM users');
  await connection.end();
  res.json(rows);
});
```

**Problem:** Can't handle concurrent requests efficiently

**✅ Correct:**
```javascript
// ✅ RIGHT - Use pool for production
const pool = mysql.createPool({...});

app.get('/users', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users');
  res.json(rows);
});
```

#### ❌ Mistake 3: Not Closing Single Connections

```javascript
// ❌ WRONG - Connection stays open
const connection = await mysql.createConnection({...});
await connection.query('SELECT * FROM users');
// Forgot to close - connection stays alive!
```

**✅ Correct:**
```javascript
// ✅ RIGHT - Always close single connections
const connection = await mysql.createConnection({...});
try {
  await connection.query('SELECT * FROM users');
} finally {
  await connection.end();  // Always close
}
```

---

### Summary: Pool vs Single Connection

| Feature | Pool (`createPool`) | Single Connection (`createConnection`) |
|---------|-------------------|----------------------------------------|
| **Best For** | Production, servers | Scripts, development |
| **Performance** | ⚡ Fast (reuses connections) | 🐢 Slower (creates each time) |
| **Concurrent Requests** | ✅ Yes (multiple at once) | ❌ No (one at a time) |
| **Connection Management** | ✅ Automatic | ❌ Manual (must close) |
| **Resource Usage** | Higher (keeps connections) | Lower (closes after use) |
| **Error Recovery** | ✅ Automatic | ❌ Manual |
| **Your Use Case** | ✅ Perfect for Express server | ❌ Not suitable |

**Recommendation:** For your Express server, **continue using `createPool()`** - it's the right choice! 🎯

---

### 2.1. Step 1: Create Connection Pool (`createPool`)

### Basic Setup

**Import:**
```javascript
const mysql = require("mysql2/promise");
```

**Create Pool:**
```javascript
const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "myapp_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});
```

### Pool Configuration Options (Day-to-Day Use)

**Essential Options:**
```javascript
const pool = mysql.createPool({
  // Connection details
  host: "localhost",              // Database host
  user: "root",                   // Database user
  password: "your_password",      // Database password
  database: "myapp_db",           // Database name
  port: 3306,                     // MySQL port (default: 3306)
  
  // Pool management
  waitForConnections: true,       // Wait for available connection if pool is full
  connectionLimit: 10,           // Maximum connections in pool (default: 10)
  queueLimit: 0,                  // Max queued requests (0 = unlimited)
  
  // Connection settings
  connectTimeout: 10000,          // Connection timeout in ms (default: 10000)
  acquireTimeout: 10000,           // Timeout to get connection from pool
  timeout: 60000,                 // Query timeout in ms (default: 60000)
  
  // Reconnection
  reconnect: true,                // Auto-reconnect on connection loss
});
```

**Using Environment Variables (Recommended):**
```javascript
const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "myapp_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});
```

**Your `.env` file:**
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=myapp_db
```

---

### 2.2. Step 2: Get Connection from Pool (`getConnection`)

### When to Use `getConnection()`

Use `getConnection()` when you need:
- **Transaction support** (multiple queries that must succeed/fail together)
- **Manual connection management**
- **Testing connection**

### Basic Usage

```javascript
// Get a connection from the pool
const connection = await pool.getConnection();

try {
  // Use the connection
  const [rows] = await connection.query('SELECT * FROM users');
  
  // Always release the connection back to the pool
  connection.release();
} catch (error) {
  // Release connection even on error
  connection.release();
  throw error;
}
```

### Your Code Pattern (Testing Connection)

```javascript
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log("✅ Database connected successfully");
    connection.release();  // Release connection back to pool
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
}
```

### Connection Methods and Properties

**Methods:**
```javascript
const connection = await pool.getConnection();

// Execute query
const [rows] = await connection.query('SELECT * FROM users');
const [rows] = await connection.execute('SELECT * FROM users WHERE id = ?', [1]);

// Start transaction
await connection.beginTransaction();

// Commit transaction
await connection.commit();

// Rollback transaction
await connection.rollback();

// Release connection (IMPORTANT!)
connection.release();
```

**Properties:**
```javascript
connection.threadId        // Connection thread ID
connection.state          // Connection state
```

---

### 2.3. Step 3: Execute Queries (`query` or `execute`)

### Two Ways to Query

#### Method 1: `pool.query()` - Direct Query (Your Current Usage)

**Simple queries without parameters:**
```javascript
// Direct query on pool (no need to get connection)
const [rows] = await pool.query('SELECT * FROM users');
```

**With parameters (using placeholders):**
```javascript
// Using ? placeholders (automatic escaping)
const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [1]);
const [rows] = await pool.query('SELECT * FROM users WHERE email = ? AND status = ?', ['user@example.com', 'active']);
```

**Your Code Pattern:**
```javascript
// Creating tables
await pool.query(`CREATE TABLE IF NOT EXISTS users(
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)`);
```

#### Method 2: `pool.execute()` - Prepared Statements (More Secure)

**Prepared statements (recommended for user input):**
```javascript
// More secure - uses prepared statements
const [rows] = await pool.execute('SELECT * FROM users WHERE id = ?', [1]);
const [rows] = await pool.execute('INSERT INTO users (name, email) VALUES (?, ?)', ['John', 'john@example.com']);
```

**Difference:**
- `query()` - Simple query execution
- `execute()` - Prepared statement (better for security, slightly slower)

### Understanding Query Results

**Query returns array with two elements:**
```javascript
const [rows, fields] = await pool.query('SELECT * FROM users');

// rows - Array of result rows
console.log(rows);
// [
//   { id: 1, name: 'John', email: 'john@example.com' },
//   { id: 2, name: 'Jane', email: 'jane@example.com' }
// ]

// fields - Metadata about columns (usually not needed)
console.log(fields);
```

**Common Patterns:**
```javascript
// Get all rows
const [rows] = await pool.query('SELECT * FROM users');
const users = rows;

// Get single row
const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [1]);
const user = rows[0];  // First row or undefined

// Get count
const [rows] = await pool.query('SELECT COUNT(*) as count FROM users');
const count = rows[0].count;

// Check if exists
const [rows] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
const exists = rows.length > 0;
```

---

### 2.4. Day-to-Day Query Patterns

### SELECT Queries

**Get all records:**
```javascript
const [rows] = await pool.query('SELECT * FROM users');
```

**Get with conditions:**
```javascript
const [rows] = await pool.query(
  'SELECT * FROM users WHERE status = ? AND role = ?',
  ['active', 'user']
);
```

**Get single record:**
```javascript
const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
const user = rows[0];  // Single user or undefined
```

**Get with pagination:**
```javascript
const page = 1;
const limit = 10;
const offset = (page - 1) * limit;

const [rows] = await pool.query(
  'SELECT * FROM users LIMIT ? OFFSET ?',
  [limit, offset]
);
```

**Get with JOIN:**
```javascript
const [rows] = await pool.query(`
  SELECT u.*, d.title 
  FROM users u 
  LEFT JOIN documents d ON u.id = d.user_id 
  WHERE u.id = ?
`, [userId]);
```

### INSERT Queries

**Insert single record:**
```javascript
const [result] = await pool.query(
  'INSERT INTO users (name, email) VALUES (?, ?)',
  ['John Doe', 'john@example.com']
);

const newUserId = result.insertId;  // Get the inserted ID
```

**Insert multiple records:**
```javascript
const users = [
  ['John', 'john@example.com'],
  ['Jane', 'jane@example.com']
];

const [result] = await pool.query(
  'INSERT INTO users (name, email) VALUES ?',
  [users]
);
```

### UPDATE Queries

**Update single record:**
```javascript
const [result] = await pool.query(
  'UPDATE users SET name = ?, email = ? WHERE id = ?',
  ['John Updated', 'newemail@example.com', userId]
);

const affectedRows = result.affectedRows;  // Number of rows updated
```

**Update with conditions:**
```javascript
const [result] = await pool.query(
  'UPDATE users SET status = ? WHERE status = ? AND created_at < ?',
  ['inactive', 'active', oldDate]
);
```

### DELETE Queries

**Delete single record:**
```javascript
const [result] = await pool.query(
  'DELETE FROM users WHERE id = ?',
  [userId]
);

const affectedRows = result.affectedRows;  // Number of rows deleted
```

**Delete with conditions:**
```javascript
const [result] = await pool.query(
  'DELETE FROM users WHERE status = ? AND created_at < ?',
  ['inactive', oldDate]
);
```

### Result Object Properties

**After INSERT:**
```javascript
const [result] = await pool.query('INSERT INTO users (name) VALUES (?)', ['John']);
console.log(result.insertId);      // New record ID
console.log(result.affectedRows);   // 1
```

**After UPDATE/DELETE:**
```javascript
const [result] = await pool.query('UPDATE users SET name = ? WHERE id = ?', ['John', 1]);
console.log(result.affectedRows);   // Number of rows affected
console.log(result.changedRows);    // Number of rows actually changed
```

**After SELECT:**
```javascript
const [rows] = await pool.query('SELECT * FROM users');
console.log(rows.length);          // Number of rows returned
console.log(rows[0]);              // First row object
```

---

### 2.5. Error Handling Pattern

### Try-Catch Pattern (Your Style)

```javascript
async function getUserById(userId) {
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
    return rows[0];
  } catch (error) {
    console.error('Database error:', error.message);
    throw error;  // Re-throw to handle in route
  }
}
```

### Common Error Types

```javascript
try {
  await pool.query('SELECT * FROM users');
} catch (error) {
  if (error.code === 'ER_DUP_ENTRY') {
    // Duplicate entry error
    console.error('Duplicate entry');
  } else if (error.code === 'ER_NO_SUCH_TABLE') {
    // Table doesn't exist
    console.error('Table not found');
  } else if (error.code === 'ECONNREFUSED') {
    // Connection refused
    console.error('Cannot connect to database');
  } else {
    // Other errors
    console.error('Database error:', error.message);
  }
}
```

---

### 2.6. Transactions (Using getConnection)

**When you need multiple queries to succeed or fail together:**

```javascript
async function transferMoney(fromUserId, toUserId, amount) {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();
    
    // Deduct from sender
    await connection.query(
      'UPDATE accounts SET balance = balance - ? WHERE user_id = ?',
      [amount, fromUserId]
    );
    
    // Add to receiver
    await connection.query(
      'UPDATE accounts SET balance = balance + ? WHERE user_id = ?',
      [amount, toUserId]
    );
    
    // If both succeed, commit
    await connection.commit();
    return { success: true };
    
  } catch (error) {
    // If any fails, rollback
    await connection.rollback();
    throw error;
  } finally {
    // Always release connection
    connection.release();
  }
}
```

---

### 2.7. Complete Real-World Example (Your Pattern)

```javascript
const mysql = require("mysql2/promise");
require("dotenv").config();

// Step 1: Create pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "myapp_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Step 2: Test connection (using getConnection)
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log("✅ Database connected successfully");
    connection.release();
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
}

// Step 3: Initialize tables (using pool.query)
async function initDatabase() {
  try {
    await pool.query(`CREATE TABLE IF NOT EXISTS users(
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )`);
    console.log("✅ Database tables initialized");
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
  }
}

// Step 4: Use in routes (using pool.query)
app.get('/api/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM users');
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    const [result] = await pool.query(
      'INSERT INTO users (name, email) VALUES (?, ?)',
      [name, email]
    );
    res.json({ success: true, id: result.insertId });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Initialize
testConnection();
initDatabase();
```

---

### 2.8. Quick Reference: Methods You'll Use Daily

| Method | When to Use | Example |
|--------|-------------|---------|
| `createPool()` | Once at app startup | `mysql.createPool({...})` |
| `pool.getConnection()` | For transactions or testing | `await pool.getConnection()` |
| `pool.query()` | Most queries (your current usage) | `await pool.query('SELECT * FROM users')` |
| `pool.execute()` | Queries with user input (more secure) | `await pool.execute('SELECT * FROM users WHERE id = ?', [1])` |
| `connection.release()` | After using getConnection | `connection.release()` |
| `connection.beginTransaction()` | Start transaction | `await connection.beginTransaction()` |
| `connection.commit()` | Commit transaction | `await connection.commit()` |
| `connection.rollback()` | Rollback transaction | `await connection.rollback()` |

### Installation
```bash
npm install mysql2
```

---

## 3. PostgreSQL (pg)

**Package:** `pg`  
**Type:** External NPM Package  
**Purpose:** PostgreSQL database client for Node.js

### Description
`pg` (node-postgres) is the most popular PostgreSQL client for Node.js. It supports connection pooling, promises/async-await, parameterized queries (`$1`, `$2`), and is used in your `postgreSQL-server` project.

---

### 3.0. Connection Methods: Pool vs Client

PostgreSQL with `pg` offers two main ways to connect, similar to MySQL2.

### Method 1: Connection Pool (`new Pool`) - Recommended (What You Use)

**What it is:**
- A pool of reusable database connections
- Create once at startup, reuse for all queries
- Automatically manages connection lifecycle

**How it works:**
```
Application Start
    ↓
new Pool() → Pool with max clients (e.g. 10)
    ↓
pool.query() → Uses a client from pool → Returns client to pool
pool.connect() → Get a client for transactions → client.release()
```

**Your Current Code (postgreSQL-server):**
```javascript
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "myapp_db",
  port: process.env.DB_PORT || 5432,
  max: 10,                        // Maximum clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Use pool directly for queries
const result = await pool.query("SELECT * FROM users");
// result.rows = array of rows

// Optional: get a client for transactions
const client = await pool.connect();
try {
  await client.query("BEGIN");
  await client.query("INSERT INTO users ...");
  await client.query("COMMIT");
} finally {
  client.release();
}
```

### Method 2: Single Client (`new Client`)

**What it is:**
- One database connection
- You must connect, use, and end it yourself
- Good for scripts, not for long-running servers

**Example:**
```javascript
const { Client } = require("pg");

const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
});

await client.connect();
const result = await client.query("SELECT * FROM users");
await client.end();  // Must close when done
```

---

### 3.1. Key Differences from MySQL2

| Aspect | MySQL2 | PostgreSQL (pg) |
|--------|--------|-----------------|
| **Import** | `require('mysql2/promise')` | `const { Pool } = require('pg')` |
| **Create pool** | `mysql.createPool({...})` | `new Pool({...})` |
| **Placeholders** | `?` (e.g. `WHERE id = ?`) | `$1`, `$2` (e.g. `WHERE id = $1`) |
| **Result rows** | `[rows] = await pool.query(...)` | `result.rows` from `await pool.query(...)` |
| **Get connection** | `pool.getConnection()` | `pool.connect()` → returns client |
| **Release connection** | `connection.release()` | `client.release()` |

### 3.2. Parameterized Queries (PostgreSQL Style)

Always use `$1`, `$2`, etc. to avoid SQL injection:

```javascript
// SELECT with parameters
const result = await pool.query(
  "SELECT * FROM users WHERE id = $1 AND email = $2",
  [userId, email]
);

// INSERT with RETURNING (get inserted row)
const result = await pool.query(
  "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
  [name, email]
);
const newId = result.rows[0].id;

// UPDATE / DELETE
await pool.query("UPDATE users SET name = $1 WHERE id = $2", [name, id]);
await pool.query("DELETE FROM users WHERE id = $1", [id]);
```

### 3.3. Quick Reference

| Method | When to Use | Example |
|--------|-------------|---------|
| `new Pool(config)` | Once at app startup | `const pool = new Pool({...})` |
| `pool.query(text, [params])` | Most queries | `await pool.query('SELECT * FROM users WHERE id = $1', [id])` |
| `pool.connect()` | Transactions or need a held client | `const client = await pool.connect()` |
| `client.release()` | After using a client from pool | `client.release()` |
| `client.query()` | When using a checked-out client | `await client.query('...')` |

### Installation
```bash
npm install pg
```

---

## 4. MongoDB (Mongoose & mongodb driver)

**Packages:** `mongoose` (ODM) or `mongodb` (native driver)  
**Type:** External NPM Package  
**Purpose:** Connect to MongoDB and work with documents

### Description
- **Mongoose:** ODM (Object Document Mapper) for MongoDB. You define schemas, get validation, middleware, and a promise-based API. Used in your `Mongodb-server` project.
- **mongodb (driver):** Official low-level driver. No schemas; you work with raw documents and the MongoDB API.

---

### 4.0. Connection Methods

MongoDB is different from SQL: it typically uses a **single connection URL**; the driver (or Mongoose) manages a connection pool internally.

### Method 1: Mongoose (What You Use) - Single `connect()` Call

**What it is:**
- One `mongoose.connect(uri)` at startup
- Mongoose keeps a connection pool under the hood
- You use Models (e.g. `User.find()`) for all queries

**Your Current Code (Mongodb-server):**
```javascript
const mongoose = require("mongoose");

async function connectDatabase() {
  try {
    await mongoose.connect(
      process.env.MONGODB_URI || "mongodb://localhost:27017/myapp_db"
    );
    console.log("✅ Database connected successfully");
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
}

connectDatabase();

// Later: use models
// const user = await User.findOne({ email });
```

**Connection URI format:**
```
mongodb://localhost:27017/myapp_db
mongodb://username:password@host:27017/dbname?authSource=admin
mongodb+srv://user:pass@cluster.mongodb.net/dbname  (Atlas)
```

### Method 2: Native mongodb Driver - MongoClient

**What it is:**
- Use the `mongodb` package and `MongoClient.connect(uri)`
- You get a `client`; use `client.db('dbName')` to get a database, then collections
- No schemas; you work with plain JavaScript objects

**Example:**
```javascript
const { MongoClient } = require("mongodb");

const uri = process.env.MONGODB_URI || "mongodb://localhost:27017";
const client = new MongoClient(uri);

async function run() {
  await client.connect();
  const db = client.db("myapp_db");
  const users = db.collection("users");

  const doc = await users.findOne({ email: "test@example.com" });
  await users.insertOne({ name: "Jane", email: "jane@example.com" });

  await client.close();  // For scripts: close when done
}
```

For long-running apps (e.g. Express), you typically connect once and reuse the same `client` (or use Mongoose), similar to a pool in SQL.

---

### 4.1. Mongoose vs mongodb Driver

| Aspect | Mongoose | mongodb driver |
|--------|----------|----------------|
| **Connect** | `mongoose.connect(uri)` | `MongoClient.connect(uri)` |
| **Schema** | Yes (models, validation) | No (plain documents) |
| **Queries** | `User.find()`, `User.findById()` | `collection.find()`, `collection.findOne()` |
| **Best for** | Apps that want structure, validation, relations | Full control, simple scripts, no schema |

### 4.2. Mongoose Connection Options (Optional)

```javascript
await mongoose.connect(uri, {
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
});
```

### 4.3. Quick Reference

**Mongoose (your pattern):**
| Method | When to Use | Example |
|--------|-------------|---------|
| `mongoose.connect(uri)` | Once at app startup | `await mongoose.connect(process.env.MONGODB_URI)` |
| `mongoose.connection` | Check state, use `mongoose.connection.db` for raw DB | `mongoose.connection.db` |
| Model methods | All CRUD | `User.find()`, `User.create()`, `User.findByIdAndUpdate()` |

**mongodb driver:**
| Method | When to Use | Example |
|--------|-------------|---------|
| `MongoClient.connect(uri)` | Once (or per script run) | `const client = await MongoClient.connect(uri)` |
| `client.db(name)` | Get database | `const db = client.db('myapp_db')` |
| `db.collection(name)` | Get collection | `const users = db.collection('users')` |
| `collection.find()`, `.findOne()`, `.insertOne()`, etc. | CRUD | `await users.findOne({ email })` |

### Installation
```bash
# Mongoose (includes connection + ODM)
npm install mongoose

# Or only the official driver (no ODM)
npm install mongodb
```

---

## 5. Dotenv

**Package:** `dotenv`  
**Type:** External NPM Package  
**Purpose:** Load environment variables from `.env` file

### Description
Dotenv is a zero-dependency module that loads environment variables from a `.env` file into `process.env`. This is essential for keeping sensitive information (like API keys, database credentials, and configuration) out of your source code.

### Why `.config()` is Called
The `.config()` method is called to:
1. **Read the `.env` file** from the project root directory
2. **Parse the file** to extract key-value pairs (format: `KEY=value`)
3. **Add variables to `process.env`** so they're accessible throughout the application
4. **Execute immediately** when the application starts, before other code uses environment variables

### How It Works
1. Creates a `.env` file in your project root:
   ```
   PORT=3000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=secret123
   API_KEY=abc123xyz
   ```
2. Call `dotenv.config()` at the start of your application
3. Access variables via `process.env.PORT`, `process.env.DB_HOST`, etc.

### Benefits
- **Security:** Keeps secrets out of version control
- **Configuration Management:** Different environments (dev, staging, prod) can have different `.env` files
- **Easy Deployment:** Change configuration without modifying code
- **Best Practice:** Industry standard for managing environment variables

### Common Usage
```javascript
require('dotenv').config();
const port = process.env.PORT || 3000;
const dbHost = process.env.DB_HOST;
```

### Installation
```bash
npm install dotenv
```

### Important Notes
- Add `.env` to your `.gitignore` file to prevent committing secrets
- Never commit `.env` files to version control
- Use `.env.example` as a template (without actual values) for other developers

---

## 6. CORS

**Package:** `cors`  
**Type:** External NPM Package  
**Purpose:** Enable Cross-Origin Resource Sharing

### Description
CORS (Cross-Origin Resource Sharing) is a mechanism that allows web pages to make requests to a different domain than the one serving the web page. The `cors` package provides Express middleware to enable CORS with various options.

### Why It's Needed
Browsers enforce the Same-Origin Policy, which blocks requests from one origin (domain/port/protocol) to another. CORS headers tell the browser that it's safe to allow cross-origin requests.

### Common Scenarios
- Frontend on `http://localhost:3000` making requests to API on `http://localhost:5000`
- Frontend deployed on `https://myapp.com` calling API on `https://api.myapp.com`
- Development environment where frontend and backend run on different ports

### Common Usage
```javascript
// Enable CORS for all routes
app.use(cors());

// Configure CORS with options
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE']
}));
```

### Installation
```bash
npm install cors
```

---

## 7. Multer

**Package:** `multer`  
**Type:** External NPM Package  
**Purpose:** Handle multipart/form-data for file uploads

### Description
Multer is a middleware for handling `multipart/form-data`, which is primarily used for uploading files. It adds a `body` object and a `file` or `files` object to the request object. Unlike `express.json()` and `express.urlencoded()`, multer is specifically designed to handle file uploads.

---

### 7.1. Understanding File Upload Request Structure

### What is `multipart/form-data`?

When you upload a file, the browser sends data in a special format called `multipart/form-data`. This is different from:
- **JSON** (`application/json`) - Used by `express.json()`
- **URL-encoded** (`application/x-www-form-urlencoded`) - Used by `express.urlencoded()`

### Request Headers Structure

**When a file is uploaded, the request headers look like this:**

```http
POST /upload HTTP/1.1
Host: localhost:3000
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Length: 12345
```

**Key Headers:**
- **`Content-Type: multipart/form-data`** - Tells server this is a file upload
- **`boundary`** - A unique string that separates different parts of the data
- **`Content-Length`** - Total size of the request body

### Request Body Structure

**The body contains multiple "parts" separated by the boundary:**

```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="email"

john@example.com
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

[binary file data here...]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

**What this means:**
- Each field (text or file) is a separate "part"
- Each part has headers describing it
- Files contain binary data
- Boundary markers separate each part

### Why Multer is Needed

**Without Multer:**
```javascript
app.post('/upload', (req, res) => {
  console.log(req.body);  // ❌ undefined or empty
  console.log(req.file);  // ❌ undefined
  // Can't access uploaded file!
});
```

**With Multer:**
```javascript
const upload = multer({ dest: 'uploads/' });
app.post('/upload', upload.single('file'), (req, res) => {
  console.log(req.body);  // ✅ { username: 'john_doe', email: 'john@example.com' }
  console.log(req.file);  // ✅ File object with all file information
});
```

---

### 7.2. Understanding Callback Parameters: `(req, file, cb)`

### What are these parameters?

In multer configuration, you'll see callbacks like:
```javascript
filename: (req, file, cb) => {
  cb(null, 'custom-name.jpg');
}
```

### Parameter Breakdown

#### 1. `req` - Request Object
- **Type:** Express request object
- **Contains:** All request data (headers, body, params, query, etc.)
- **Use case:** Access other form fields, user info, request metadata

**Example:**
```javascript
filename: (req, file, cb) => {
  // Access other form fields
  const userId = req.body.userId;
  const category = req.body.category;
  
  // Create filename based on request data
  const filename = `${userId}-${category}-${Date.now()}.jpg`;
  cb(null, filename);
}
```

#### 2. `file` - File Object
- **Type:** Object containing file information
- **Properties:**
  - `fieldname` - Name of the form field (e.g., "file", "avatar")
  - `originalname` - Original filename from client
  - `encoding` - File encoding (usually "7bit")
  - `mimetype` - MIME type (e.g., "image/jpeg", "application/pdf")
  - `size` - File size in bytes
  - `buffer` - File data (if using memory storage)
  - `destination` - Directory where file is saved (disk storage)
  - `filename` - Saved filename (disk storage)
  - `path` - Full path to saved file (disk storage)

**Example:**
```javascript
filename: (req, file, cb) => {
  console.log('Field name:', file.fieldname);        // "file"
  console.log('Original name:', file.originalname); // "photo.jpg"
  console.log('MIME type:', file.mimetype);         // "image/jpeg"
  console.log('File size:', file.size);             // 123456 bytes
  
  // Create unique filename
  const ext = file.originalname.split('.').pop();
  const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}.${ext}`;
  cb(null, uniqueName);
}
```

#### 3. `cb` - Callback Function
- **Type:** Function
- **Purpose:** Tell multer what to do next
- **Signature:** `cb(error, value)`

**Usage:**
```javascript
// Success - pass null as first argument, value as second
cb(null, 'filename.jpg');  // ✅ Success - use this filename

// Error - pass error as first argument
cb(new Error('Invalid file type'));  // ❌ Error - reject file
```

**Complete Example:**
```javascript
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Determine destination based on file type
    if (file.mimetype.startsWith('image/')) {
      cb(null, './uploads/images');
    } else if (file.mimetype === 'application/pdf') {
      cb(null, './uploads/documents');
    } else {
      cb(new Error('Unsupported file type'));
    }
  },
  filename: (req, file, cb) => {
    // Access request data
    const userId = req.body.userId || 'anonymous';
    
    // Access file data
    const ext = file.originalname.split('.').pop();
    const timestamp = Date.now();
    
    // Create custom filename
    const filename = `${userId}-${timestamp}.${ext}`;
    cb(null, filename);  // Success - use this filename
  }
});
```

---

### 7.3. Multer Methods

Multer provides different methods to handle various upload scenarios:

### 1. `upload.single(fieldname)` - Single File

**Use case:** Upload one file from a specific field

**Frontend:**
```html
<form enctype="multipart/form-data" method="POST" action="/upload">
  <input type="file" name="avatar">
  <button type="submit">Upload</button>
</form>
```

**Backend:**
```javascript
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.single('avatar'), (req, res) => {
  console.log(req.file);  // Single file object
  // {
  //   fieldname: 'avatar',
  //   originalname: 'photo.jpg',
  //   mimetype: 'image/jpeg',
  //   size: 123456,
  //   destination: 'uploads/',
  //   filename: 'abc123',
  //   path: 'uploads/abc123'
  // }
  res.json({ file: req.file });
});
```

### 2. `upload.array(fieldname, maxCount)` - Multiple Files from Same Field

**Use case:** Upload multiple files from the same field (e.g., multiple photos)

**Frontend:**
```html
<form enctype="multipart/form-data" method="POST" action="/upload">
  <input type="file" name="photos" multiple>
  <button type="submit">Upload</button>
</form>
```

**Backend:**
```javascript
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.array('photos', 5), (req, res) => {
  console.log(req.files);  // Array of file objects
  // [
  //   { fieldname: 'photos', originalname: 'photo1.jpg', ... },
  //   { fieldname: 'photos', originalname: 'photo2.jpg', ... },
  //   { fieldname: 'photos', originalname: 'photo3.jpg', ... }
  // ]
  res.json({ files: req.files, count: req.files.length });
});
```

**Parameters:**
- `fieldname` - Name of the form field
- `maxCount` (optional) - Maximum number of files (default: unlimited)

### 3. `upload.fields(fieldsArray)` - Multiple Files from Different Fields

**Use case:** Upload files from different fields (e.g., avatar + document)

**Frontend:**
```html
<form enctype="multipart/form-data" method="POST" action="/upload">
  <input type="file" name="avatar">
  <input type="file" name="document">
  <button type="submit">Upload</button>
</form>
```

**Backend:**
```javascript
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.fields([
  { name: 'avatar', maxCount: 1 },
  { name: 'document', maxCount: 1 }
]), (req, res) => {
  console.log(req.files);  // Object with field names as keys
  // {
  //   avatar: [{ fieldname: 'avatar', originalname: 'photo.jpg', ... }],
  //   document: [{ fieldname: 'document', originalname: 'doc.pdf', ... }]
  // }
  res.json({ files: req.files });
});
```

### 4. `upload.any()` - Any Field, Any Number

**Use case:** Accept files from any field (use with caution - less secure)

**Backend:**
```javascript
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.any(), (req, res) => {
  console.log(req.files);  // Array of all uploaded files
  res.json({ files: req.files });
});
```

### 5. `upload.none()` - No Files, Only Text Fields

**Use case:** Accept only text fields, reject any files

**Backend:**
```javascript
const upload = multer();

app.post('/form', upload.none(), (req, res) => {
  console.log(req.body);  // Text fields only
  // Files will be rejected
  res.json({ data: req.body });
});
```

---

### 7.4. Multer Configuration Options

### Basic Configuration

```javascript
const multer = require('multer');

const upload = multer({
  dest: 'uploads/'  // Simple: just specify destination directory
});
```

### Advanced Configuration with Storage

#### Disk Storage (`multer.diskStorage`)

**Saves files to disk with custom naming:**

```javascript
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Determine where to save the file
    cb(null, './uploads');
  },
  filename: (req, file, cb) => {
    // Determine filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix);
  }
});

const upload = multer({ storage: storage });
```

**Complete Example:**
```javascript
const path = require('path');
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Create different folders based on file type
    if (file.mimetype.startsWith('image/')) {
      cb(null, './uploads/images');
    } else {
      cb(null, './uploads/documents');
    }
  },
  filename: (req, file, cb) => {
    // Preserve original extension
    const ext = path.extname(file.originalname);
    const name = path.basename(file.originalname, ext);
    const uniqueName = `${name}-${Date.now()}${ext}`;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage: storage });
```

#### Memory Storage (`multer.memoryStorage`)

**Keeps files in memory (as Buffer):**

```javascript
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.post('/upload', upload.single('file'), (req, res) => {
  // File is in memory, not saved to disk
  console.log(req.file.buffer);  // Buffer containing file data
  console.log(req.file.size);      // File size in bytes
  
  // You can process the buffer (e.g., upload to cloud storage)
  // req.file.buffer contains the file data
});
```

**Use cases:**
- Upload to cloud storage (AWS S3, Cloudinary)
- Process files without saving to disk
- Temporary file handling

### File Filtering

**Filter files by type, size, etc.:**

```javascript
const fileFilter = (req, file, cb) => {
  // Allow only images
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);  // Accept file
  } else {
    cb(new Error('Only image files are allowed!'), false);  // Reject file
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024  // 5MB max
  }
});
```

**Common File Type Checks:**
```javascript
const fileFilter = (req, file, cb) => {
  // Images only
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  }
  // PDFs only
  else if (file.mimetype === 'application/pdf') {
    cb(null, true);
  }
  // Specific extensions
  else if (['.jpg', '.jpeg', '.png'].includes(path.extname(file.originalname))) {
    cb(null, true);
  }
  // Reject everything else
  else {
    cb(new Error('Invalid file type'), false);
  }
};
```

### Limits Configuration

**Control file size and other limits:**

```javascript
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024,      // 5MB max file size
    files: 5,                        // Max 5 files
    fields: 10,                      // Max 10 text fields
    fieldNameSize: 100,              // Max field name length
    fieldSize: 1024 * 1024,         // Max field value size (1MB)
    headerPairs: 2000                // Max header pairs
  }
});
```

### Complete Configuration Example

```javascript
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads directory if it doesn't exist
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// File filter - only allow images
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (extname && mimetype) {
    cb(null, true);  // Accept
  } else {
    cb(new Error('Only image files are allowed!'), false);  // Reject
  }
};

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// Create multer instance
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024  // 5MB
  }
});

// Use in route
app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  res.json({
    success: true,
    file: {
      filename: req.file.filename,
      originalname: req.file.originalname,
      size: req.file.size,
      mimetype: req.file.mimetype,
      path: req.file.path
    }
  });
});
```

---

### 7.5. Request Object Structure After Multer

### After `upload.single()`

**`req.file` structure:**
```javascript
{
  fieldname: 'file',              // Form field name
  originalname: 'photo.jpg',      // Original filename
  encoding: '7bit',               // File encoding
  mimetype: 'image/jpeg',         // MIME type
  size: 123456,                   // File size in bytes
  destination: './uploads',       // Save directory (disk storage)
  filename: 'abc123',              // Saved filename (disk storage)
  path: './uploads/abc123',        // Full path (disk storage)
  buffer: Buffer                  // File data (memory storage only)
}
```

### After `upload.array()` or `upload.fields()`

**`req.files` structure:**
```javascript
// For upload.array()
[
  { fieldname: 'photos', originalname: 'photo1.jpg', ... },
  { fieldname: 'photos', originalname: 'photo2.jpg', ... }
]

// For upload.fields()
{
  avatar: [{ fieldname: 'avatar', originalname: 'photo.jpg', ... }],
  document: [{ fieldname: 'document', originalname: 'doc.pdf', ... }]
}
```

### `req.body` - Text Fields

**Text form fields are available in `req.body`:**
```javascript
// Form has: <input name="username" value="john">
// After multer:
console.log(req.body.username);  // "john"
```

---

### 7.6. How File Storage Works: Disk vs Database

### Understanding Your Code: Avatar Upload Flow

In your route (`/api/users`), you're saving only the **path** to the database, not the file itself. Here's how the complete flow works:

### Step-by-Step Flow

#### Step 1: Request Arrives with File

**Client sends:**
```javascript
const formData = new FormData();
formData.append('name', 'John Doe');
formData.append('email', 'john@example.com');
formData.append('avatar', fileInput.files[0]); // File object

fetch('/api/users', {
  method: 'POST',
  body: formData
});
```

**Request structure:**
```
POST /api/users HTTP/1.1
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="name"

John Doe
------WebKitFormBoundary
Content-Disposition: form-data; name="email"

john@example.com
------WebKitFormBoundary
Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
Content-Type: image/jpeg

[binary file data]
------WebKitFormBoundary--
```

#### Step 2: Multer Middleware Processes File (BEFORE Route Handler)

**Your multer configuration:**
```javascript
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);  // "./uploads" directory
  },  
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname));
    // Result: "avatar-1704067200000-123456789.jpg"
  },
});

const upload = multer({ storage: storage });
```

**What happens:**
1. Multer intercepts the request **before** your route handler runs
2. Extracts the file from `multipart/form-data`
3. Saves file to disk: `./uploads/avatar-1704067200000-123456789.jpg`
4. Creates `req.file` object with file information
5. Then passes control to your route handler

**File is now on disk:**
```
project/
  └── uploads/
      └── avatar-1704067200000-123456789.jpg  ✅ File saved here
```

#### Step 3: Route Handler Receives File Info

**Your route handler:**
```javascript
app.post("/api/users", upload.single("avatar"), async (req, res) => {
  // At this point, file is ALREADY saved to disk
  // req.file contains information about the saved file
});
```

**`req.file` object structure:**
```javascript
{
  fieldname: 'avatar',                    // Form field name
  originalname: 'photo.jpg',              // Original filename
  encoding: '7bit',
  mimetype: 'image/jpeg',
  size: 123456,                          // File size in bytes
  destination: './uploads',               // Where file was saved
  filename: 'avatar-1704067200000-123456789.jpg',  // Generated filename
  path: './uploads/avatar-1704067200000-123456789.jpg',  // Full path
  buffer: undefined                       // Not used with diskStorage
}
```

#### Step 4: Construct Path for Database

**Your code:**
```javascript
const avatar = req.file ? `/uploads/${req.file.filename}` : null;
```

**What this does:**
- If file was uploaded: Creates path `/uploads/avatar-1704067200000-123456789.jpg`
- If no file: Sets to `null`

**Why `/uploads/` and not `./uploads/`?**
- `/uploads/` is a **URL path** (for accessing via HTTP)
- `./uploads/` is a **file system path** (for saving to disk)
- You need URL path because `express.static()` serves files at `/uploads` route

#### Step 5: Save Path to Database (NOT the File)

**Your database insert:**
```javascript
const [result] = await pool.query(
  "INSERT INTO users (name, email, avatar) VALUES (?, ?, ?)",
  [name, email, avatar]  // avatar = "/uploads/avatar-1704067200000-123456789.jpg"
);
```

**Database stores:**
```sql
| id | name      | email              | avatar                                    |
|----|-----------|--------------------|-------------------------------------------|
| 1  | John Doe  | john@example.com   | /uploads/avatar-1704067200000-123456789.jpg |
```

**Important:** Database stores **only the path**, not the actual file!

#### Step 6: File is Accessible via Static Middleware

**Your static file serving:**
```javascript
app.use("/uploads", express.static("uploads"));
```

**What this does:**
- Maps URL path `/uploads` to file system directory `./uploads`
- When client requests `/uploads/avatar-1704067200000-123456789.jpg`
- Express serves file from `./uploads/avatar-1704067200000-123456789.jpg`

### Complete Flow Diagram

```
1. Client Uploads File
   ↓
2. Request arrives at Express
   ↓
3. Multer Middleware (upload.single("avatar"))
   ├─ Extracts file from multipart/form-data
   ├─ Saves file to: ./uploads/avatar-1704067200000-123456789.jpg
   └─ Creates req.file object
   ↓
4. Route Handler Executes
   ├─ Reads req.file.filename
   ├─ Constructs path: /uploads/avatar-1704067200000-123456789.jpg
   └─ Saves path to database
   ↓
5. Response Sent
   └─ Returns: { avatar: "/uploads/avatar-1704067200000-123456789.jpg" }
   ↓
6. Client Accesses File
   └─ GET /uploads/avatar-1704067200000-123456789.jpg
   └─ express.static() serves file from disk
```

### Why Store Path, Not File?

**❌ Storing File in Database:**
```javascript
// BAD - Don't do this
const fileBuffer = fs.readFileSync(req.file.path);
await pool.query("INSERT INTO users (avatar) VALUES (?)", [fileBuffer]);
// Problems:
// - Database becomes huge
// - Slow queries
// - Hard to serve files
// - Wastes database resources
```

**✅ Storing Path in Database (Your Approach):**
```javascript
// GOOD - Your current approach
const avatar = `/uploads/${req.file.filename}`;
await pool.query("INSERT INTO users (avatar) VALUES (?)", [avatar]);
// Benefits:
// - Database stays small
// - Fast queries
// - Easy to serve via express.static()
// - Efficient resource usage
```

### File Storage Locations

**On Disk (Physical Storage):**
```
./uploads/avatar-1704067200000-123456789.jpg
```
- Actual file bytes stored here
- Managed by multer
- Accessible via file system

**In Database (Path Reference):**
```sql
avatar: "/uploads/avatar-1704067200000-123456789.jpg"
```
- Only the path string stored
- Used to construct URLs
- References the file on disk

**Via HTTP (URL Access):**
```
http://localhost:3000/uploads/avatar-1704067200000-123456789.jpg
```
- URL constructed from database path
- Served by `express.static()`
- Client can access directly

### Your Complete Code Breakdown

```javascript
// 1. Multer saves file to disk BEFORE route handler runs
app.post("/api/users", upload.single("avatar"), async (req, res) => {
  
  // 2. File is already saved, req.file contains info
  // req.file.path = "./uploads/avatar-1704067200000-123456789.jpg"
  // req.file.filename = "avatar-1704067200000-123456789.jpg"
  
  // 3. Construct URL path (not file system path)
  const avatar = req.file 
    ? `/uploads/${req.file.filename}`  // URL path for HTTP access
    : null;
  
  // 4. Save only the path to database
  const [result] = await pool.query(
    "INSERT INTO users (name, email, avatar) VALUES (?, ?, ?)",
    [name, email, avatar]  // avatar = "/uploads/avatar-1704067200000-123456789.jpg"
  );
  
  // 5. Return path in response
  res.json({
    avatar: "/uploads/avatar-1704067200000-123456789.jpg"
  });
  
  // 6. Client can access file at:
  // http://localhost:3000/uploads/avatar-1704067200000-123456789.jpg
  // This is served by: app.use("/uploads", express.static("uploads"))
});
```

### Accessing the Stored File

**From Frontend:**
```html
<!-- Use the path from database -->
<img src="http://localhost:3000/uploads/avatar-1704067200000-123456789.jpg" alt="Avatar">
```

**From Backend (if needed):**
```javascript
// Read file from disk using the path
const filePath = path.join(__dirname, 'uploads', req.file.filename);
const fileBuffer = fs.readFileSync(filePath);
```

### Key Takeaways

1. **Multer saves file to disk** - Happens automatically in middleware
2. **Database stores only path** - Not the actual file bytes
3. **Path is URL path** - `/uploads/filename.jpg` (not `./uploads/filename.jpg`)
4. **express.static() serves files** - Makes files accessible via HTTP
5. **File stays on disk** - Database just references it

### Common Questions

**Q: Where is the actual file stored?**  
A: On disk in `./uploads/` directory (managed by multer)

**Q: What's in the database?**  
A: Only the path string: `/uploads/avatar-1704067200000-123456789.jpg`

**Q: How does the client access the file?**  
A: Via URL: `http://localhost:3000/uploads/avatar-1704067200000-123456789.jpg` (served by express.static)

**Q: Why not store file in database?**  
A: Databases are for structured data. Files should be on disk/file storage. Storing files in database makes it slow and bloated.

---

### 7.7. File Upload Security: Critical Best Practices

### ⚠️ Security Risks in File Uploads

File uploads are one of the **most common attack vectors**. Without proper security, attackers can:
- Upload malicious files (viruses, scripts)
- Execute code on your server
- Access sensitive files (path traversal)
- Overwhelm your server (DoS attacks)
- Store illegal content

### Current Security Issues in Your Code

**Your current implementation has some security, but is missing critical protections:**

```javascript
// ❌ CURRENT CODE - Has some security but missing important checks
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|pdf|doc|docx/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error("Invalid file type"));
  }
};

filename: (req, file, cb) => {
  const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
  cb(null, file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname));
  // ❌ Uses originalname extension - can be spoofed!
}
```

**Security Gaps:**
1. ❌ **Filename not sanitized** - Path traversal risk
2. ❌ **Extension from originalname** - Can be spoofed
3. ❌ **No content validation** - Only checks extension/mimetype
4. ❌ **No file content scanning** - Could be malicious
5. ❌ **No access control** - Anyone can upload

---

#### 7.7.1. Security Best Practices

### 1. Filename Sanitization (CRITICAL)

**Problem:** Malicious filenames can contain path traversal sequences

**Attack Example:**
```javascript
// Attacker uploads file with name: "../../../etc/passwd"
// Without sanitization, file could be saved outside uploads directory!
```

**✅ Secure Solution:**
```javascript
const path = require('path');
const crypto = require('crypto');

filename: (req, file, cb) => {
  // Generate completely random filename (no user input)
  const randomName = crypto.randomBytes(16).toString('hex');
  
  // Get extension from original file (but validate it)
  const ext = path.extname(file.originalname).toLowerCase();
  
  // Only allow safe extensions
  const allowedExts = ['.jpg', '.jpeg', '.png', '.gif', '.pdf'];
  const finalExt = allowedExts.includes(ext) ? ext : '.bin';
  
  // Use random name + validated extension
  cb(null, `${randomName}${finalExt}`);
}
```

**Better: Generate extension from mimetype:**
```javascript
filename: (req, file, cb) => {
  const randomName = crypto.randomBytes(16).toString('hex');
  
  // Map mimetype to extension (more secure)
  const mimeToExt = {
    'image/jpeg': '.jpg',
    'image/png': '.png',
    'image/gif': '.gif',
    'application/pdf': '.pdf'
  };
  
  const ext = mimeToExt[file.mimetype] || '.bin';
  cb(null, `${randomName}${ext}`);
}
```

### 2. File Content Validation (Magic Number Checking)

**Problem:** File extensions and mimetypes can be spoofed. A `.jpg` file could actually be a `.php` script!

**Attack Example:**
```javascript
// Attacker renames malicious.php to malicious.jpg
// Your code sees .jpg extension and allows it
// But file content is still PHP script!
```

**✅ Secure Solution - Check File Magic Numbers:**

```javascript
const fs = require('fs');

// Magic numbers (file signatures) for different file types
const fileSignatures = {
  'image/jpeg': [0xFF, 0xD8, 0xFF],
  'image/png': [0x89, 0x50, 0x4E, 0x47],
  'image/gif': [0x47, 0x49, 0x46, 0x38],
  'application/pdf': [0x25, 0x50, 0x44, 0x46], // %PDF
};

function validateFileContent(filePath, expectedMimeType) {
  const buffer = fs.readFileSync(filePath);
  const signature = fileSignatures[expectedMimeType];
  
  if (!signature) return false;
  
  // Check if file starts with correct magic number
  return signature.every((byte, index) => buffer[index] === byte);
}

// Use in fileFilter
const fileFilter = async (req, file, cb) => {
  // First check extension and mimetype
  const allowedTypes = /jpeg|jpg|png|gif|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (!extname || !mimetype) {
    return cb(new Error('Invalid file type'), false);
  }
  
  // After file is saved, validate content
  // Note: This requires saving to temp location first, then validating
  cb(null, true);
};
```

**Better: Use a library for magic number checking:**
```bash
npm install file-type
```

```javascript
const FileType = require('file-type');

const fileFilter = async (req, file, cb) => {
  // For memory storage, we can check buffer directly
  // For disk storage, need to check after save
  cb(null, true);
};

// After file is saved, validate
app.post('/upload', upload.single('avatar'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file' });
  }
  
  // Check actual file content
  const fileType = await FileType.fromFile(req.file.path);
  
  if (!fileType || !['image/jpeg', 'image/png', 'image/gif'].includes(fileType.mime)) {
    // Delete malicious file
    fs.unlinkSync(req.file.path);
    return res.status(400).json({ error: 'Invalid file content' });
  }
  
  // File is safe, continue...
});
```

### 3. Enhanced File Type Validation

**✅ Improved fileFilter:**
```javascript
const fileFilter = (req, file, cb) => {
  // Whitelist approach (only allow specific types)
  const allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf'
  ];
  
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.pdf'];
  
  // Get file extension
  const ext = path.extname(file.originalname).toLowerCase();
  
  // Check both extension AND mimetype
  const isValidExtension = allowedExtensions.includes(ext);
  const isValidMimeType = allowedMimeTypes.includes(file.mimetype);
  
  // Both must match
  if (isValidExtension && isValidMimeType) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. Allowed: ${allowedExtensions.join(', ')}`), false);
  }
};
```

### 4. File Size Limits (You Have This - Good!)

**✅ Your current implementation:**
```javascript
limits: { fileSize: 5 * 1024 * 1024 }  // 5MB limit
```

**Additional limits to consider:**
```javascript
limits: {
  fileSize: 5 * 1024 * 1024,      // 5MB per file
  files: 5,                        // Max 5 files per request
  fields: 10,                      // Max 10 text fields
  fieldNameSize: 100,              // Max field name length
  fieldSize: 1024 * 1024,          // Max field value size
}
```

### 5. Storage Location Security

**✅ Secure storage configuration:**
```javascript
const path = require('path');

// Use absolute path (prevents path traversal)
const uploadDir = path.join(__dirname, 'uploads');

// Ensure directory exists and is writable
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  // Set permissions (Unix/Linux)
  fs.chmodSync(uploadDir, 0o755);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Always use absolute path
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate safe filename (no user input)
    const randomName = crypto.randomBytes(16).toString('hex');
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${randomName}${ext}`);
  }
});
```

### 6. Access Control

**✅ Add authentication/authorization:**
```javascript
// Middleware to check if user is authenticated
const requireAuth = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  next();
};

// Apply to upload route
app.post('/api/users', requireAuth, uploadLimiter, upload.single('avatar'), async (req, res) => {
  // Only authenticated users can upload
});
```

### 7. Rate Limiting (You Have This - Good!)

**✅ Your current implementation:**
```javascript
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,  // 1 hour
  max: 10,                     // 10 uploads per hour
});
```

### 8. Virus Scanning (For Production)

**For production, consider virus scanning:**
```bash
npm install clamscan  # ClamAV integration
```

```javascript
const NodeClam = require('clamscan');

const clamscan = await new NodeClam().init();

app.post('/upload', upload.single('avatar'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file' });
  }
  
  // Scan for viruses
  const { isInfected, viruses } = await clamscan.isInfected(req.file.path);
  
  if (isInfected) {
    fs.unlinkSync(req.file.path);  // Delete infected file
    return res.status(400).json({ error: 'File contains virus', viruses });
  }
  
  // File is clean, continue...
});
```

---

#### 7.7.2. Secure Implementation Example

**✅ Complete Secure File Upload Configuration:**

```javascript
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const fs = require('fs');
const FileType = require('file-type');

// Secure storage configuration
const uploadDir = path.join(__dirname, 'uploads');

// Ensure directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Whitelist of allowed file types
const allowedMimeTypes = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/gif': '.gif',
  'application/pdf': '.pdf'
};

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);  // Use absolute path
  },
  filename: (req, file, cb) => {
    // Generate random filename (no user input)
    const randomName = crypto.randomBytes(16).toString('hex');
    
    // Get extension from mimetype (more secure than originalname)
    const ext = allowedMimeTypes[file.mimetype] || '.bin';
    
    cb(null, `${randomName}${ext}`);
  }
});

// Enhanced file filter
const fileFilter = (req, file, cb) => {
  // Check if mimetype is in whitelist
  if (allowedMimeTypes[file.mimetype]) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Allowed: JPEG, PNG, GIF, PDF'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024,  // 5MB
    files: 1,                    // Max 1 file
  }
});

// Secure upload route
app.post('/api/users', 
  requireAuth,        // Authentication required
  uploadLimiter,      // Rate limiting
  upload.single('avatar'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
      }
      
      // Validate file content (magic number check)
      const fileType = await FileType.fromFile(req.file.path);
      
      if (!fileType || !allowedMimeTypes[fileType.mime]) {
        // Delete suspicious file
        fs.unlinkSync(req.file.path);
        return res.status(400).json({ 
          error: 'File content does not match file type' 
        });
      }
      
      // File is safe, save to database
      const avatar = `/uploads/${req.file.filename}`;
      // ... rest of your code
      
    } catch (error) {
      // Clean up file on error
      if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }
      res.status(500).json({ error: error.message });
    }
  }
);
```

---

#### 7.7.3. Security Checklist

**Before deploying file uploads, ensure:**

- ✅ **Filename sanitization** - No user input in filename
- ✅ **File type validation** - Whitelist approach
- ✅ **Content validation** - Magic number checking
- ✅ **File size limits** - Prevent DoS attacks
- ✅ **Rate limiting** - Prevent abuse
- ✅ **Access control** - Authentication required
- ✅ **Storage security** - Absolute paths, proper permissions
- ✅ **Error handling** - Clean up files on error
- ✅ **Virus scanning** - For production (optional but recommended)
- ✅ **HTTPS only** - Encrypt file transfers
- ✅ **Input validation** - Validate all form fields
- ✅ **Logging** - Log all upload attempts for security auditing

---

#### 7.7.4. Common Attack Vectors and Prevention

### Attack 1: Path Traversal

**Attack:**
```javascript
// Attacker uploads: "../../../etc/passwd"
// Without sanitization, file saved outside uploads/
```

**Prevention:**
```javascript
// Use absolute paths and random filenames
const uploadDir = path.join(__dirname, 'uploads');
const filename = crypto.randomBytes(16).toString('hex') + ext;
```

### Attack 2: File Type Spoofing

**Attack:**
```javascript
// Rename malicious.php to malicious.jpg
// Extension check passes, but file is still PHP
```

**Prevention:**
```javascript
// Check file content (magic numbers)
const fileType = await FileType.fromFile(req.file.path);
```

### Attack 3: Oversized Files (DoS)

**Attack:**
```javascript
// Upload 10GB file to crash server
```

**Prevention:**
```javascript
limits: { fileSize: 5 * 1024 * 1024 }  // 5MB max
```

### Attack 4: Malicious Scripts

**Attack:**
```javascript
// Upload PHP/JS script, then execute it
```

**Prevention:**
```javascript
// Whitelist only safe file types
// Never execute uploaded files
// Store outside web root if possible
```

---

#### 7.7.5. Quick Security Fixes for Your Current Code

**Immediate improvements you can make:**

```javascript
// 1. Sanitize filename (use random name)
filename: (req, file, cb) => {
  const randomName = crypto.randomBytes(16).toString('hex');
  const ext = path.extname(file.originalname).toLowerCase();
  cb(null, `${randomName}${ext}`);
}

// 2. Use absolute path
const uploadDir = path.join(__dirname, 'uploads');

// 3. Add content validation after upload
// Install: npm install file-type
const FileType = require('file-type');

app.post('/api/users', upload.single('avatar'), async (req, res) => {
  if (req.file) {
    const fileType = await FileType.fromFile(req.file.path);
    if (!fileType || fileType.mime !== 'image/jpeg') {
      fs.unlinkSync(req.file.path);
      return res.status(400).json({ error: 'Invalid file' });
    }
  }
  // ... rest of code
});
```

---

### 7.8. Complete Real-World Example

**Frontend (HTML + JavaScript):**
```html
<!DOCTYPE html>
<html>
<body>
  <form id="uploadForm" enctype="multipart/form-data">
    <input type="text" name="username" placeholder="Username" required>
    <input type="file" name="avatar" accept="image/*" required>
    <button type="submit">Upload</button>
  </form>
  
  <div id="result"></div>
  
  <script>
    document.getElementById('uploadForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const formData = new FormData(e.target);
      
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });
      
      const result = await response.json();
      document.getElementById('result').innerHTML = JSON.stringify(result, null, 2);
    });
  </script>
</body>
</html>
```

**Backend:**
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const uploadDir = './uploads';

// Create uploads directory
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${ext}`;
    cb(null, uniqueName);
  }
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only images allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }  // 5MB
});

// Upload route
app.post('/upload', upload.single('avatar'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  // Access text fields
  const username = req.body.username;
  
  // Access file info
  const fileInfo = {
    originalname: req.file.originalname,
    filename: req.file.filename,
    size: req.file.size,
    mimetype: req.file.mimetype,
    path: req.file.path,
    url: `/uploads/${req.file.filename}`
  };
  
  res.json({
    success: true,
    message: 'File uploaded successfully',
    username: username,
    file: fileInfo
  });
});

// Serve uploaded files
app.use('/uploads', express.static(uploadDir));

app.listen(3000);
```

### Installation
```bash
npm install multer
```

---

## 8. Path (Node.js Built-in)

**Package:** `path`  
**Type:** Node.js Built-in Module  
**Purpose:** Utilities for working with file and directory paths

### Description
The `path` module provides utilities for working with file and directory paths. It's particularly useful for handling path differences between operating systems (Windows uses backslashes `\`, Unix/Linux/Mac uses forward slashes `/`). The `path` module automatically handles these differences, making your code cross-platform compatible.

### Why Path Module is Important

**Problem Without Path Module:**
```javascript
// ❌ BAD - Hardcoded paths don't work cross-platform
const filePath = './uploads/file.txt';  // Works on Unix
const filePath = '.\\uploads\\file.txt'; // Works on Windows
// Different code needed for different OS!
```

**Solution With Path Module:**
```javascript
// ✅ GOOD - Works on all platforms
const path = require('path');
const filePath = path.join(__dirname, 'uploads', 'file.txt');
// Automatically uses correct separator for current OS
```

### Key Methods

These are the **most commonly used methods** in day-to-day development:

- **`path.join()`** - Join path segments together (most used!)
- **`path.resolve()`** - Resolve absolute path
- **`path.dirname()`** - Get directory name from path
- **`path.basename()`** - Get filename from path
- **`path.extname()`** - Get file extension

**Quick Examples:**
```javascript
const path = require('path');

// Most common: Join paths
const filePath = path.join(__dirname, 'uploads', 'file.txt');

// Resolve to absolute path
const absolutePath = path.resolve('./uploads');

// Extract parts of a path
const dir = path.dirname('/uploads/images/photo.jpg');      // '/uploads/images'
const filename = path.basename('/uploads/images/photo.jpg'); // 'photo.jpg'
const ext = path.extname('photo.jpg');                       // '.jpg'
```

### Key Methods - Detailed

#### 1. `path.join(...paths)` - Join Path Segments

**Purpose:** Joins path segments together using the platform-specific separator

**Syntax:**
```javascript
path.join([...paths])
```

**Examples:**
```javascript
const path = require('path');

// Basic joining
path.join('uploads', 'images', 'photo.jpg');
// Unix: 'uploads/images/photo.jpg'
// Windows: 'uploads\\images\\photo.jpg'

// With __dirname (current directory)
path.join(__dirname, 'uploads', 'file.txt');
// Unix: '/home/user/project/uploads/file.txt'
// Windows: 'C:\\Users\\user\\project\\uploads\\file.txt'

// Handles extra slashes automatically
path.join('uploads/', '/images', 'photo.jpg');
// Result: 'uploads/images/photo.jpg' (normalized)

// Handles relative paths
path.join('..', 'parent', 'file.txt');
// Goes up one directory, then into parent folder

// Real-world example
const uploadDir = path.join(__dirname, 'uploads', 'images');
// Creates: project/uploads/images
```

**Key Features:**
- ✅ Normalizes path separators automatically
- ✅ Removes extra slashes
- ✅ Handles relative paths (`..`, `.`)
- ✅ Cross-platform compatible

#### 2. `path.resolve(...paths)` - Resolve Absolute Path

**Purpose:** Resolves an absolute path from relative paths

**Syntax:**
```javascript
path.resolve([...paths])
```

**Examples:**
```javascript
const path = require('path');

// Resolve relative path to absolute
path.resolve('./uploads');
// Unix: '/home/user/project/uploads'
// Windows: 'C:\\Users\\user\\project\\uploads'

// Multiple segments
path.resolve('uploads', 'images', 'photo.jpg');
// Resolves all segments to absolute path

// With __dirname
path.resolve(__dirname, 'uploads', 'file.txt');
// Combines __dirname with additional segments

// From current working directory
path.resolve('config', 'database.json');
// Resolves from process.cwd()

// Real-world example
const configPath = path.resolve(__dirname, 'config', 'app.json');
// Always gets absolute path regardless of where script is run
```

**Difference: `join()` vs `resolve()`**
```javascript
// path.join() - Just joins segments
path.join('uploads', 'file.txt');
// Result: 'uploads/file.txt' (relative)

// path.resolve() - Resolves to absolute path
path.resolve('uploads', 'file.txt');
// Result: '/full/absolute/path/uploads/file.txt' (absolute)
```

#### 3. `path.dirname(path)` - Get Directory Name

**Purpose:** Returns the directory name of a path

**Syntax:**
```javascript
path.dirname(path)
```

**Examples:**
```javascript
const path = require('path');

// Get directory from file path
path.dirname('/uploads/images/photo.jpg');
// Result: '/uploads/images'

path.dirname('./uploads/file.txt');
// Result: './uploads'

// With __dirname
const filePath = path.join(__dirname, 'uploads', 'file.txt');
const dir = path.dirname(filePath);
// Result: '/path/to/project/uploads'

// Real-world example
const uploadedFile = '/uploads/user123/avatar.jpg';
const uploadDir = path.dirname(uploadedFile);
// Result: '/uploads/user123'
```

#### 4. `path.basename(path, [ext])` - Get Filename

**Purpose:** Returns the last portion of a path (filename)

**Syntax:**
```javascript
path.basename(path, [ext])
```

**Examples:**
```javascript
const path = require('path');

// Get filename
path.basename('/uploads/images/photo.jpg');
// Result: 'photo.jpg'

// Remove extension
path.basename('/uploads/images/photo.jpg', '.jpg');
// Result: 'photo'

path.basename('/uploads/images/photo.jpg', path.extname('photo.jpg'));
// Result: 'photo' (removes extension dynamically)

// Real-world example
const filePath = '/uploads/user123/avatar-1234567890.jpg';
const filename = path.basename(filePath);
// Result: 'avatar-1234567890.jpg'

const nameWithoutExt = path.basename(filePath, path.extname(filePath));
// Result: 'avatar-1234567890'
```

#### 5. `path.extname(path)` - Get File Extension

**Purpose:** Returns the extension of a path

**Syntax:**
```javascript
path.extname(path)
```

**Examples:**
```javascript
const path = require('path');

// Get extension
path.extname('photo.jpg');
// Result: '.jpg'

path.extname('/uploads/images/photo.jpg');
// Result: '.jpg'

path.extname('document.pdf');
// Result: '.pdf'

// No extension
path.extname('file');
// Result: ''

// Multiple dots
path.extname('file.min.js');
// Result: '.js' (returns last extension)

// Real-world example - File type validation
const uploadedFile = req.file.originalname;
const ext = path.extname(uploadedFile).toLowerCase();
const allowedExts = ['.jpg', '.png', '.gif'];
if (!allowedExts.includes(ext)) {
  throw new Error('Invalid file type');
}
```

#### 6. `path.parse(path)` - Parse Path into Object

**Purpose:** Returns an object with all path components

**Syntax:**
```javascript
path.parse(path)
```

**Examples:**
```javascript
const path = require('path');

// Parse full path
const parsed = path.parse('/uploads/images/photo.jpg');
console.log(parsed);
// {
//   root: '/',
//   dir: '/uploads/images',
//   base: 'photo.jpg',
//   ext: '.jpg',
//   name: 'photo'
// }

// Real-world example
const filePath = '/uploads/user123/avatar-1234567890.jpg';
const parsed = path.parse(filePath);
console.log(parsed.name);    // 'avatar-1234567890'
console.log(parsed.ext);     // '.jpg'
console.log(parsed.dir);     // '/uploads/user123'
console.log(parsed.base);    // 'avatar-1234567890.jpg'
```

#### 7. `path.format(pathObject)` - Format Object into Path

**Purpose:** Creates a path string from an object (opposite of `parse()`)

**Syntax:**
```javascript
path.format(pathObject)
```

**Examples:**
```javascript
const path = require('path');

// Format object to path
const pathObj = {
  root: '/',
  dir: '/uploads/images',
  base: 'photo.jpg',
  ext: '.jpg',
  name: 'photo'
};
path.format(pathObj);
// Result: '/uploads/images/photo.jpg'

// Real-world example - Modify filename
const originalPath = '/uploads/old-name.jpg';
const parsed = path.parse(originalPath);
parsed.name = 'new-name';
const newPath = path.format(parsed);
// Result: '/uploads/new-name.jpg'
```

#### 8. `path.normalize(path)` - Normalize Path

**Purpose:** Normalizes a path string (removes redundant separators, resolves `..` and `.`)

**Syntax:**
```javascript
path.normalize(path)
```

**Examples:**
```javascript
const path = require('path');

// Normalize redundant slashes
path.normalize('/uploads//images///photo.jpg');
// Result: '/uploads/images/photo.jpg'

// Normalize relative paths
path.normalize('uploads/../images/photo.jpg');
// Result: 'images/photo.jpg'

// Real-world example - Clean user input
const userInput = 'uploads//images/../images/photo.jpg';
const cleanPath = path.normalize(userInput);
// Result: 'uploads/images/photo.jpg'
```

#### 9. `path.isAbsolute(path)` - Check if Path is Absolute

**Purpose:** Determines if a path is an absolute path

**Syntax:**
```javascript
path.isAbsolute(path)
```

**Examples:**
```javascript
const path = require('path');

// Check if absolute
path.isAbsolute('/uploads/file.txt');
// Unix: true
// Windows: true

path.isAbsolute('./uploads/file.txt');
// Result: false (relative)

path.isAbsolute('uploads/file.txt');
// Result: false (relative)

// Real-world example
const userPath = req.body.filePath;
if (path.isAbsolute(userPath)) {
  // Security check - reject absolute paths from user input
  throw new Error('Absolute paths not allowed');
}
```

#### 10. `path.relative(from, to)` - Get Relative Path

**Purpose:** Returns the relative path from one path to another

**Syntax:**
```javascript
path.relative(from, to)
```

**Examples:**
```javascript
const path = require('path');

// Get relative path
path.relative('/uploads/images', '/uploads/images/photo.jpg');
// Result: 'photo.jpg'

path.relative('/uploads', '/uploads/images/photo.jpg');
// Result: 'images/photo.jpg'

path.relative('/uploads/images', '/uploads/documents/file.pdf');
// Result: '../documents/file.pdf'

// Real-world example
const baseDir = '/uploads';
const filePath = '/uploads/user123/avatar.jpg';
const relativePath = path.relative(baseDir, filePath);
// Result: 'user123/avatar.jpg'
```

### Platform-Specific Methods

#### Windows vs Unix Path Handling

**Windows Path Methods:**
```javascript
const path = require('path');

// Windows-specific separator
path.win32.sep;  // '\\'

// Windows path methods
path.win32.join('uploads', 'file.txt');
// Result: 'uploads\\file.txt'
```

**Unix Path Methods:**
```javascript
// Unix-specific separator
path.posix.sep;  // '/'

// Unix path methods
path.posix.join('uploads', 'file.txt');
// Result: 'uploads/file.txt'
```

**Default Behavior:**
```javascript
// Uses current platform's separator
path.join('uploads', 'file.txt');
// Windows: 'uploads\\file.txt'
// Unix: 'uploads/file.txt'
```

### Real-World Examples

#### Example 1: File Upload Path Construction

```javascript
const path = require('path');
const multer = require('multer');

// Create safe upload path
const uploadDir = path.join(__dirname, 'uploads', 'images');

// In multer configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const uniqueName = `${Date.now()}-${Math.random().toString(36).substring(7)}${ext}`;
    cb(null, uniqueName);
  }
});
```

#### Example 2: Reading Configuration Files

```javascript
const path = require('path');
const fs = require('fs');

// Resolve config file path
const configPath = path.resolve(__dirname, 'config', 'app.json');

// Read config
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
```

#### Example 3: Serving Static Files

```javascript
const path = require('path');
const express = require('express');

// Serve static files with absolute path
const publicDir = path.join(__dirname, 'public');
app.use(express.static(publicDir));

// Serve uploads
const uploadsDir = path.resolve(__dirname, 'uploads');
app.use('/uploads', express.static(uploadsDir));
```

#### Example 4: File Extension Validation

```javascript
const path = require('path');

function validateFileExtension(filename, allowedExts) {
  const ext = path.extname(filename).toLowerCase();
  return allowedExts.includes(ext);
}

// Usage
const filename = 'photo.jpg';
if (validateFileExtension(filename, ['.jpg', '.png', '.gif'])) {
  console.log('Valid file type');
}
```

#### Example 5: Path Sanitization

```javascript
const path = require('path');

function sanitizePath(userInput) {
  // Normalize path
  let cleanPath = path.normalize(userInput);
  
  // Remove any path traversal attempts
  if (cleanPath.includes('..')) {
    throw new Error('Path traversal not allowed');
  }
  
  // Resolve to ensure it's within allowed directory
  const baseDir = path.resolve(__dirname, 'uploads');
  const resolvedPath = path.resolve(baseDir, cleanPath);
  
  // Ensure resolved path is within base directory
  if (!resolvedPath.startsWith(baseDir)) {
    throw new Error('Path outside allowed directory');
  }
  
  return resolvedPath;
}
```

### Common Path Patterns

#### Pattern 1: Working with __dirname

```javascript
const path = require('path');

// Get file in same directory as script
const configFile = path.join(__dirname, 'config.json');

// Get file in parent directory
const parentFile = path.join(__dirname, '..', 'config.json');

// Get file in subdirectory
const dataFile = path.join(__dirname, 'data', 'users.json');
```

#### Pattern 2: Cross-Platform Paths

```javascript
const path = require('path');

// Always use path.join() instead of string concatenation
// ❌ BAD
const badPath = __dirname + '/uploads/file.txt';

// ✅ GOOD
const goodPath = path.join(__dirname, 'uploads', 'file.txt');
```

#### Pattern 3: Extracting File Information

```javascript
const path = require('path');

const filePath = '/uploads/images/photo-123.jpg';

// Get all components
const dir = path.dirname(filePath);        // '/uploads/images'
const filename = path.basename(filePath);  // 'photo-123.jpg'
const name = path.basename(filePath, path.extname(filePath)); // 'photo-123'
const ext = path.extname(filePath);        // '.jpg'

// Or use parse()
const parsed = path.parse(filePath);
// { root: '/', dir: '/uploads/images', base: 'photo-123.jpg', ext: '.jpg', name: 'photo-123' }
```

### Quick Reference Table

| Method | Purpose | Example |
|--------|---------|---------|
| `path.join()` | Join path segments | `path.join('a', 'b')` → `'a/b'` |
| `path.resolve()` | Resolve absolute path | `path.resolve('./a')` → `'/full/path/a'` |
| `path.dirname()` | Get directory | `path.dirname('/a/b.txt')` → `'/a'` |
| `path.basename()` | Get filename | `path.basename('/a/b.txt')` → `'b.txt'` |
| `path.extname()` | Get extension | `path.extname('file.jpg')` → `'.jpg'` |
| `path.parse()` | Parse to object | Returns object with all components |
| `path.format()` | Format from object | Creates path from object |
| `path.normalize()` | Normalize path | Removes redundant separators |
| `path.isAbsolute()` | Check if absolute | Returns true/false |
| `path.relative()` | Get relative path | Returns relative path between two |

### Important Notes

- ✅ **Always use `path.join()`** instead of string concatenation for cross-platform compatibility
- ✅ **Use `path.resolve()`** when you need absolute paths
- ✅ **Use `__dirname`** to reference files relative to your script location
- ✅ **Normalize user input** paths to prevent security issues
- ✅ **Validate paths** before using them in file operations
- ⚠️ **Path separators** are handled automatically - don't hardcode `/` or `\`
- ⚠️ **Relative paths** can be tricky - prefer absolute paths when possible

### No Installation Required
This is a built-in Node.js module, no installation needed.

---

## 9. FS (Node.js Built-in)

**Package:** `fs`  
**Type:** Node.js Built-in Module  
**Purpose:** File system operations  

### Description
The `fs` module provides an API for interacting with the file system. It allows you to read, write, create, delete files and directories. The module offers both **synchronous** (blocking) and **asynchronous** (non-blocking) versions of most methods.

### Key Methods

These are the **most commonly used methods** in day-to-day development:

- **`fs.readFileSync()` / `fs.readFile()`** - Read file content (most used!)
- **`fs.writeFileSync()` / `fs.writeFile()`** - Write/create file
- **`fs.existsSync()`** - Check if file/directory exists
- **`fs.mkdirSync()` / `fs.mkdir()`** - Create directory
- **`fs.readdirSync()` / `fs.readdir()`** - Read directory contents
- **`fs.unlinkSync()` / `fs.unlink()`** - Delete file
- **`fs.statSync()` / `fs.stat()`** - Get file/directory stats

**Quick Examples:**
```javascript
const fs = require('fs');

// Most common: Read file
const data = fs.readFileSync('./file.txt', 'utf8');

// Write file
fs.writeFileSync('./output.txt', 'Hello World', 'utf8');

// Check if exists
if (fs.existsSync('./uploads')) {
  console.log('Directory exists');
}

// Create directory
fs.mkdirSync('./uploads', { recursive: true });

// Read directory
const files = fs.readdirSync('./uploads');

// Delete file
fs.unlinkSync('./temp.txt');

// Get file stats
const stats = fs.statSync('./file.txt');
console.log('Size:', stats.size);
```

### Key Methods - CRUD Operations

#### 📁 **DIRECTORY Operations (CRUD)**

##### **CREATE Directory**
```javascript
// Synchronous (blocking)
fs.mkdirSync('./uploads', { recursive: true });

// Asynchronous (non-blocking)
fs.mkdir('./uploads', { recursive: true }, (err) => {
  if (err) console.error(err);
  else console.log('Directory created');
});

// Promise-based (async/await)
const fsPromises = require('fs').promises;
await fsPromises.mkdir('./uploads', { recursive: true });
```
- `recursive: true` - Creates parent directories if they don't exist
- Without `recursive`, parent directories must exist

##### **READ Directory**
```javascript
// Synchronous - Returns array of filenames
const files = fs.readdirSync('./uploads');
console.log(files); // ['file1.txt', 'file2.jpg', 'subfolder']

// Asynchronous
fs.readdir('./uploads', (err, files) => {
  if (err) console.error(err);
  else console.log(files);
});

// Promise-based with file details
const files = await fsPromises.readdir('./uploads', { withFileTypes: true });
files.forEach(file => {
  console.log(file.name, file.isDirectory() ? 'DIR' : 'FILE');
});
```

##### **UPDATE Directory** (Rename/Move)
```javascript
// Synchronous
fs.renameSync('./old-folder', './new-folder');

// Asynchronous
fs.rename('./old-folder', './new-folder', (err) => {
  if (err) console.error(err);
});

// Promise-based
await fsPromises.rename('./old-folder', './new-folder');
```

##### **DELETE Directory**
```javascript
// Synchronous - Only deletes empty directory
fs.rmdirSync('./uploads');

// Asynchronous - Only deletes empty directory
fs.rmdir('./uploads', (err) => {
  if (err) console.error(err);
});

// Delete directory with all contents (recursive)
fs.rmSync('./uploads', { recursive: true, force: true });
// or
await fsPromises.rm('./uploads', { recursive: true, force: true });
```

---

#### 📄 **FILE Operations (CRUD)**

##### **CREATE File** (Write)
```javascript
// Synchronous - Creates file or overwrites if exists
fs.writeFileSync('./data.txt', 'Hello World', 'utf8');

// Asynchronous
fs.writeFile('./data.txt', 'Hello World', 'utf8', (err) => {
  if (err) console.error(err);
  else console.log('File created');
});

// Promise-based
await fsPromises.writeFile('./data.txt', 'Hello World', 'utf8');

// Append to file (add content without overwriting)
fs.appendFileSync('./data.txt', '\nNew line');
await fsPromises.appendFile('./data.txt', '\nNew line');
```

##### **READ File**
```javascript
// Synchronous - Returns file content
const data = fs.readFileSync('./data.txt', 'utf8');
console.log(data); // "Hello World"

// Asynchronous
fs.readFile('./data.txt', 'utf8', (err, data) => {
  if (err) console.error(err);
  else console.log(data);
});

// Promise-based
const data = await fsPromises.readFile('./data.txt', 'utf8');

// Read file as Buffer (binary data)
const buffer = fs.readFileSync('./image.jpg');
```

##### **UPDATE File** (Modify/Append)
```javascript
// Overwrite entire file
fs.writeFileSync('./data.txt', 'New content', 'utf8');

// Append to existing file
fs.appendFileSync('./data.txt', '\nAppended text', 'utf8');

// Read, modify, write pattern
let content = fs.readFileSync('./data.txt', 'utf8');
content = content.replace('old', 'new');
fs.writeFileSync('./data.txt', content, 'utf8');
```

##### **DELETE File**
```javascript
// Synchronous
fs.unlinkSync('./data.txt');

// Asynchronous
fs.unlink('./data.txt', (err) => {
  if (err) console.error(err);
  else console.log('File deleted');
});

// Promise-based
await fsPromises.unlink('./data.txt');
```

---

### 🔍 **UTILITY Methods**

##### **Check if File/Directory EXISTS**
```javascript
// Synchronous - Returns true/false
if (fs.existsSync('./uploads')) {
  console.log('Directory exists');
}

// Check if path is a file
if (fs.statSync('./data.txt').isFile()) {
  console.log('It is a file');
}

// Check if path is a directory
if (fs.statSync('./uploads').isDirectory()) {
  console.log('It is a directory');
}
```

##### **Get File/Directory STATS** (Size, dates, permissions)
```javascript
// Synchronous
const stats = fs.statSync('./data.txt');
console.log('Size:', stats.size);           // File size in bytes
console.log('Created:', stats.birthtime);   // Creation date
console.log('Modified:', stats.mtime);      // Last modified date
console.log('Is File:', stats.isFile());    // true/false
console.log('Is Directory:', stats.isDirectory()); // true/false

// Asynchronous
fs.stat('./data.txt', (err, stats) => {
  if (err) console.error(err);
  else console.log(stats);
});

// Promise-based
const stats = await fsPromises.stat('./data.txt');
```

##### **COPY File/Directory**
```javascript
// Copy file
fs.copyFileSync('./source.txt', './destination.txt');
await fsPromises.copyFile('./source.txt', './destination.txt');

// Copy directory (requires recursive function or external package)
```

---

### 📊 **Quick Reference Table**

| Operation | File | Directory |
|-----------|------|-----------|
| **CREATE** | `writeFileSync()` / `writeFile()` | `mkdirSync()` / `mkdir()` |
| **READ** | `readFileSync()` / `readFile()` | `readdirSync()` / `readdir()` |
| **UPDATE** | `writeFileSync()` / `appendFileSync()` | `renameSync()` / `rename()` |
| **DELETE** | `unlinkSync()` / `unlink()` | `rmdirSync()` / `rm()` or `rmSync()` |

### 🎯 **Method Naming Pattern**

**Synchronous methods** end with `Sync`:
- `readFileSync()`, `writeFileSync()`, `mkdirSync()`

**Asynchronous methods** use callbacks:
- `readFile()`, `writeFile()`, `mkdir()`

**Promise-based** (use `fs.promises`):
- `fsPromises.readFile()`, `fsPromises.writeFile()`, `fsPromises.mkdir()`

### 💡 **Common Usage Examples**

```javascript
const fs = require('fs');
const path = require('path');

// 1. Create directory if it doesn't exist
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 2. Read file
const data = fs.readFileSync('file.txt', 'utf8');
console.log(data);

// 3. Write file
fs.writeFileSync('output.txt', 'Hello World', 'utf8');

// 4. Append to file
fs.appendFileSync('log.txt', '\nNew log entry', 'utf8');

// 5. Read directory contents
const files = fs.readdirSync('./uploads');
files.forEach(file => {
  console.log(file);
});

// 6. Check file stats
if (fs.existsSync('data.txt')) {
  const stats = fs.statSync('data.txt');
  console.log(`File size: ${stats.size} bytes`);
  console.log(`Modified: ${stats.mtime}`);
}

// 7. Delete file
if (fs.existsSync('temp.txt')) {
  fs.unlinkSync('temp.txt');
}

// 8. Delete directory (must be empty)
if (fs.existsSync('./temp-folder')) {
  fs.rmdirSync('./temp-folder');
}

// 9. Delete directory with contents
fs.rmSync('./temp-folder', { recursive: true, force: true });
```

### 🔥 **Advanced Real-World Examples**

#### Example 1: Recursive Directory Traversal

```javascript
const fs = require('fs');
const path = require('path');

// Recursively read all files in directory
function getAllFiles(dirPath, arrayOfFiles = []) {
  const files = fs.readdirSync(dirPath);
  
  files.forEach(file => {
    const filePath = path.join(dirPath, file);
    if (fs.statSync(filePath).isDirectory()) {
      arrayOfFiles = getAllFiles(filePath, arrayOfFiles);
    } else {
      arrayOfFiles.push(filePath);
    }
  });
  
  return arrayOfFiles;
}

// Usage
const allFiles = getAllFiles('./uploads');
console.log(allFiles);
// ['uploads/image1.jpg', 'uploads/subfolder/image2.jpg', ...]
```

#### Example 2: File Size Monitoring

```javascript
const fs = require('fs');
const path = require('path');

// Monitor directory size
function getDirectorySize(dirPath) {
  let totalSize = 0;
  
  function calculateSize(currentPath) {
    const stats = fs.statSync(currentPath);
    
    if (stats.isFile()) {
      totalSize += stats.size;
    } else if (stats.isDirectory()) {
      const files = fs.readdirSync(currentPath);
      files.forEach(file => {
        calculateSize(path.join(currentPath, file));
      });
    }
  }
  
  calculateSize(dirPath);
  return totalSize;
}

// Usage
const uploadsSize = getDirectorySize('./uploads');
console.log(`Uploads directory size: ${(uploadsSize / 1024 / 1024).toFixed(2)} MB`);
```

#### Example 3: Cleanup Old Files

```javascript
const fs = require('fs');
const path = require('path');

// Delete files older than specified days
function cleanupOldFiles(dirPath, daysOld = 30) {
  const files = fs.readdirSync(dirPath);
  const now = Date.now();
  const maxAge = daysOld * 24 * 60 * 60 * 1000; // Convert days to milliseconds
  
  files.forEach(file => {
    const filePath = path.join(dirPath, file);
    const stats = fs.statSync(filePath);
    const fileAge = now - stats.mtime.getTime();
    
    if (fileAge > maxAge) {
      fs.unlinkSync(filePath);
      console.log(`Deleted old file: ${file}`);
    }
  });
}

// Usage - Delete files older than 30 days
cleanupOldFiles('./uploads', 30);
```

#### Example 4: Safe File Writing with Backup

```javascript
const fs = require('fs');
const path = require('path');

// Write file with automatic backup
function safeWriteFile(filePath, data, encoding = 'utf8') {
  // Create backup if file exists
  if (fs.existsSync(filePath)) {
    const backupPath = filePath + '.backup';
    fs.copyFileSync(filePath, backupPath);
    console.log(`Backup created: ${backupPath}`);
  }
  
  // Write new file
  fs.writeFileSync(filePath, data, encoding);
  console.log(`File written: ${filePath}`);
}

// Usage
safeWriteFile('./config.json', JSON.stringify({ key: 'value' }, null, 2));
```

#### Example 5: Reading JSON Configuration Files

```javascript
const fs = require('fs');
const path = require('path');

// Read and parse JSON config file
function loadConfig(configPath) {
  try {
    if (!fs.existsSync(configPath)) {
      throw new Error(`Config file not found: ${configPath}`);
    }
    
    const data = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error loading config:', error.message);
    return null;
  }
}

// Usage
const config = loadConfig('./config.json');
if (config) {
  console.log('Config loaded:', config);
}
```

#### Example 6: Logging to File

```javascript
const fs = require('fs');
const path = require('path');

// Simple file logger
class FileLogger {
  constructor(logPath) {
    this.logPath = logPath;
    this.ensureLogFile();
  }
  
  ensureLogFile() {
    if (!fs.existsSync(this.logPath)) {
      fs.writeFileSync(this.logPath, '');
    }
  }
  
  log(level, message) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] [${level}] ${message}\n`;
    fs.appendFileSync(this.logPath, logEntry, 'utf8');
  }
  
  info(message) { this.log('INFO', message); }
  error(message) { this.log('ERROR', message); }
  warn(message) { this.log('WARN', message); }
}

// Usage
const logger = new FileLogger('./app.log');
logger.info('Application started');
logger.error('Something went wrong');
```

#### Example 7: File Watcher (Monitor File Changes)

```javascript
const fs = require('fs');

// Watch file for changes
function watchFile(filePath, callback) {
  fs.watchFile(filePath, { interval: 1000 }, (curr, prev) => {
    if (curr.mtime !== prev.mtime) {
      console.log(`File ${filePath} was modified`);
      callback(curr, prev);
    }
  });
}

// Usage
watchFile('./config.json', (curr, prev) => {
  console.log('Config file changed, reloading...');
  const config = JSON.parse(fs.readFileSync('./config.json', 'utf8'));
  // Reload configuration
});

// Stop watching
// fs.unwatchFile('./config.json');
```

#### Example 8: Create Directory Structure

```javascript
const fs = require('fs');
const path = require('path');

// Create nested directory structure
function createDirectoryStructure(basePath, structure) {
  for (const [name, children] of Object.entries(structure)) {
    const dirPath = path.join(basePath, name);
    
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
      console.log(`Created directory: ${dirPath}`);
    }
    
    if (children && typeof children === 'object') {
      createDirectoryStructure(dirPath, children);
    }
  }
}

// Usage - Create upload directory structure
createDirectoryStructure('./', {
  uploads: {
    images: {},
    documents: {},
    videos: {}
  },
  logs: {},
  temp: {}
});
```

#### Example 9: File Type Detection and Organization

```javascript
const fs = require('fs');
const path = require('path');

// Organize files by type
function organizeFilesByType(sourceDir, targetBaseDir) {
  const files = fs.readdirSync(sourceDir);
  
  const fileTypes = {
    images: ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
    documents: ['.pdf', '.doc', '.docx', '.txt'],
    videos: ['.mp4', '.avi', '.mov', '.mkv']
  };
  
  files.forEach(file => {
    const filePath = path.join(sourceDir, file);
    if (fs.statSync(filePath).isFile()) {
      const ext = path.extname(file).toLowerCase();
      
      // Find category
      let category = 'other';
      for (const [type, extensions] of Object.entries(fileTypes)) {
        if (extensions.includes(ext)) {
          category = type;
          break;
        }
      }
      
      // Create category directory if needed
      const categoryDir = path.join(targetBaseDir, category);
      if (!fs.existsSync(categoryDir)) {
        fs.mkdirSync(categoryDir, { recursive: true });
      }
      
      // Move file
      const targetPath = path.join(categoryDir, file);
      fs.renameSync(filePath, targetPath);
      console.log(`Moved ${file} to ${category}/`);
    }
  });
}

// Usage
organizeFilesByType('./downloads', './organized');
```

#### Example 10: Async/Await Pattern for File Operations

```javascript
const fs = require('fs').promises;
const path = require('path');

// Modern async/await file operations
async function processFiles() {
  try {
    // Read directory
    const files = await fs.readdir('./uploads');
    
    // Process each file
    for (const file of files) {
      const filePath = path.join('./uploads', file);
      const stats = await fs.stat(filePath);
      
      if (stats.isFile()) {
        const content = await fs.readFile(filePath, 'utf8');
        console.log(`File: ${file}, Size: ${stats.size} bytes`);
        // Process file content...
      }
    }
  } catch (error) {
    console.error('Error processing files:', error);
  }
}

// Usage
processFiles();
```

#### Example 11: Stream Large Files

```javascript
const fs = require('fs');

// Read large file in chunks (streaming)
function readLargeFile(filePath, chunkSize = 1024 * 1024) { // 1MB chunks
  return new Promise((resolve, reject) => {
    const stream = fs.createReadStream(filePath, { highWaterMark: chunkSize });
    let data = '';
    
    stream.on('data', (chunk) => {
      data += chunk.toString();
      // Process chunk if needed
      console.log(`Read ${chunk.length} bytes`);
    });
    
    stream.on('end', () => {
      resolve(data);
    });
    
    stream.on('error', (error) => {
      reject(error);
    });
  });
}

// Usage
readLargeFile('./large-file.txt')
  .then(data => console.log('File read complete'))
  .catch(error => console.error('Error:', error));
```

#### Example 12: Check Disk Space (Unix/Linux)

```javascript
const fs = require('fs');

// Get directory stats (Unix/Linux only)
function getDirectoryStats(dirPath) {
  try {
    const stats = fs.statSync(dirPath);
    return {
      exists: true,
      isDirectory: stats.isDirectory(),
      isFile: stats.isFile(),
      size: stats.size,
      created: stats.birthtime,
      modified: stats.mtime,
      accessed: stats.atime
    };
  } catch (error) {
    return { exists: false, error: error.message };
  }
}

// Usage
const stats = getDirectoryStats('./uploads');
console.log('Directory stats:', stats);
```

### ⚠️ **Important Notes**

- **Synchronous methods block** the event loop - use carefully
- **Asynchronous methods** are preferred for better performance
- **Always handle errors** when using async methods
- **Use `recursive: true`** when creating nested directories
- **File paths** can be relative (`./file.txt`) or absolute (`/path/to/file.txt`)
- **Encoding:** Always specify encoding (`'utf8'`) for text files, omit for binary
- **Delete operations:** Directories must be empty unless using `recursive: true`

### No Installation Required
This is a built-in Node.js module, no installation needed.

---

## 10. OS (Node.js Built-in)

**Package:** `os`  
**Type:** Node.js Built-in Module  
**Purpose:** Operating system-related utility methods and properties

### Description
The `os` module provides operating system-related utility methods and properties. It allows you to interact with the underlying operating system, get system information, network interfaces, CPU details, memory information, and more. This is particularly useful for system monitoring, logging, and cross-platform compatibility.

### Why OS Module is Important

**Use Cases:**
- ✅ **System Information:** Get OS type, platform, architecture
- ✅ **Resource Monitoring:** Check CPU, memory usage
- ✅ **Network Information:** Get network interfaces and IP addresses
- ✅ **Path Utilities:** Get system-specific paths (home directory, temp directory)
- ✅ **Performance Monitoring:** Monitor system resources
- ✅ **Cross-Platform Compatibility:** Detect OS and adjust behavior accordingly

### Key Methods

These are the **most commonly used methods** in day-to-day development:

- **`os.platform()`** - Get OS platform (win32, darwin, linux) (most used!)
- **`os.homedir()`** - Get home directory path
- **`os.tmpdir()`** - Get temporary directory path
- **`os.totalmem()` / `os.freemem()`** - Get memory information
- **`os.cpus()`** - Get CPU information
- **`os.networkInterfaces()`** - Get network interfaces and IP addresses

**Quick Examples:**
```javascript
const os = require('os');

// Most common: Get platform
const platform = os.platform(); // 'win32', 'darwin', 'linux'

// Get paths
const homeDir = os.homedir();   // '/home/user' or 'C:\\Users\\user'
const tempDir = os.tmpdir();    // '/tmp' or 'C:\\Users\\user\\AppData\\Local\\Temp'

// Get memory
const totalMem = os.totalmem(); // Total memory in bytes
const freeMem = os.freemem();   // Free memory in bytes

// Get CPU info
const cpus = os.cpus();
console.log(`CPU cores: ${cpus.length}`);

// Get network interfaces
const interfaces = os.networkInterfaces();
```

### Key Methods and Properties - Detailed

#### 1. `os.platform()` - Get Operating System Platform

**Purpose:** Returns the operating system platform

**Syntax:**
```javascript
os.platform()
```

**Examples:**
```javascript
const os = require('os');

// Get platform
const platform = os.platform();
console.log(platform);
// 'win32' - Windows
// 'darwin' - macOS
// 'linux' - Linux
// 'freebsd' - FreeBSD
// 'openbsd' - OpenBSD

// Real-world example - Platform-specific code
if (os.platform() === 'win32') {
  console.log('Running on Windows');
  // Windows-specific code
} else if (os.platform() === 'darwin') {
  console.log('Running on macOS');
  // macOS-specific code
} else {
  console.log('Running on Unix/Linux');
  // Unix/Linux-specific code
}
```

#### 2. `os.type()` - Get Operating System Type

**Purpose:** Returns the operating system type

**Syntax:**
```javascript
os.type()
```

**Examples:**
```javascript
const os = require('os');

// Get OS type
const osType = os.type();
console.log(osType);
// 'Windows_NT' - Windows
// 'Darwin' - macOS
// 'Linux' - Linux
// 'FreeBSD' - FreeBSD

// Real-world example
const osType = os.type();
console.log(`Operating System: ${osType}`);
```

#### 3. `os.arch()` - Get CPU Architecture

**Purpose:** Returns the CPU architecture

**Syntax:**
```javascript
os.arch()
```

**Examples:**
```javascript
const os = require('os');

// Get architecture
const arch = os.arch();
console.log(arch);
// 'x64' - 64-bit
// 'arm' - ARM
// 'arm64' - ARM 64-bit
// 'ia32' - 32-bit
// 'mips' - MIPS

// Real-world example
const arch = os.arch();
console.log(`CPU Architecture: ${arch}`);
if (arch === 'x64') {
  console.log('Running on 64-bit system');
}
```

#### 4. `os.release()` - Get OS Release Version

**Purpose:** Returns the operating system release version

**Syntax:**
```javascript
os.release()
```

**Examples:**
```javascript
const os = require('os');

// Get OS release
const release = os.release();
console.log(release);
// Windows: '10.0.19042'
// macOS: '20.6.0'
// Linux: '5.4.0-74-generic'

// Real-world example
console.log(`OS Release: ${os.release()}`);
```

#### 5. `os.hostname()` - Get System Hostname

**Purpose:** Returns the hostname of the operating system

**Syntax:**
```javascript
os.hostname()
```

**Examples:**
```javascript
const os = require('os');

// Get hostname
const hostname = os.hostname();
console.log(hostname);
// 'DESKTOP-ABC123'
// 'my-macbook.local'
// 'server-01'

// Real-world example - Server identification
const serverInfo = {
  hostname: os.hostname(),
  platform: os.platform(),
  arch: os.arch()
};
console.log('Server Info:', serverInfo);
```

#### 6. `os.homedir()` - Get Home Directory

**Purpose:** Returns the home directory of the current user

**Syntax:**
```javascript
os.homedir()
```

**Examples:**
```javascript
const os = require('os');
const path = require('path');

// Get home directory
const homeDir = os.homedir();
console.log(homeDir);
// Windows: 'C:\\Users\\username'
// Unix/Linux: '/home/username'
// macOS: '/Users/username'

// Real-world example - User config file
const configPath = path.join(os.homedir(), '.myapp', 'config.json');
console.log(`Config file: ${configPath}`);
```

#### 7. `os.tmpdir()` - Get Temporary Directory

**Purpose:** Returns the operating system's default directory for temporary files

**Syntax:**
```javascript
os.tmpdir()
```

**Examples:**
```javascript
const os = require('os');
const path = require('path');
const fs = require('fs');

// Get temp directory
const tempDir = os.tmpdir();
console.log(tempDir);
// Windows: 'C:\\Users\\username\\AppData\\Local\\Temp'
// Unix/Linux: '/tmp'
// macOS: '/var/folders/.../T'

// Real-world example - Create temp file
const tempFile = path.join(os.tmpdir(), `temp-${Date.now()}.txt`);
fs.writeFileSync(tempFile, 'Temporary data');
console.log(`Temp file created: ${tempFile}`);
```

#### 8. `os.cpus()` - Get CPU Information

**Purpose:** Returns an array of objects containing information about each CPU/core

**Syntax:**
```javascript
os.cpus()
```

**Examples:**
```javascript
const os = require('os');

// Get CPU information
const cpus = os.cpus();
console.log(`Number of CPUs: ${cpus.length}`);

cpus.forEach((cpu, index) => {
  console.log(`CPU ${index}:`, {
    model: cpu.model,
    speed: `${cpu.speed} MHz`,
    times: {
      user: cpu.times.user,
      nice: cpu.times.nice,
      sys: cpu.times.sys,
      idle: cpu.times.idle,
      irq: cpu.times.irq
    }
  });
});

// Real-world example - CPU usage calculation
function getCPUUsage() {
  const cpus = os.cpus();
  let totalIdle = 0;
  let totalTick = 0;
  
  cpus.forEach(cpu => {
    for (const type in cpu.times) {
      totalTick += cpu.times[type];
    }
    totalIdle += cpu.times.idle;
  });
  
  const idle = totalIdle / cpus.length;
  const total = totalTick / cpus.length;
  const usage = 100 - ~~(100 * idle / total);
  
  return usage;
}

console.log(`CPU Usage: ${getCPUUsage()}%`);
```

#### 9. `os.totalmem()` - Get Total System Memory

**Purpose:** Returns the total amount of system memory in bytes

**Syntax:**
```javascript
os.totalmem()
```

**Examples:**
```javascript
const os = require('os');

// Get total memory
const totalMem = os.totalmem();
console.log(`Total Memory: ${(totalMem / 1024 / 1024 / 1024).toFixed(2)} GB`);

// Real-world example - Memory information
function getMemoryInfo() {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;
  
  return {
    total: `${(totalMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
    free: `${(freeMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
    used: `${(usedMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
    usagePercent: ((usedMem / totalMem) * 100).toFixed(2) + '%'
  };
}

console.log('Memory Info:', getMemoryInfo());
```

#### 10. `os.freemem()` - Get Free System Memory

**Purpose:** Returns the amount of free system memory in bytes

**Syntax:**
```javascript
os.freemem()
```

**Examples:**
```javascript
const os = require('os');

// Get free memory
const freeMem = os.freemem();
console.log(`Free Memory: ${(freeMem / 1024 / 1024 / 1024).toFixed(2)} GB`);

// Real-world example - Memory monitoring
function checkMemory() {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;
  const usagePercent = (usedMem / totalMem) * 100;
  
  if (usagePercent > 90) {
    console.warn('⚠️ High memory usage:', usagePercent.toFixed(2) + '%');
  } else {
    console.log('✓ Memory usage:', usagePercent.toFixed(2) + '%');
  }
}

checkMemory();
```

#### 11. `os.uptime()` - Get System Uptime

**Purpose:** Returns the system uptime in seconds

**Syntax:**
```javascript
os.uptime()
```

**Examples:**
```javascript
const os = require('os');

// Get system uptime
const uptime = os.uptime();
console.log(`System Uptime: ${uptime} seconds`);

// Format uptime
function formatUptime(seconds) {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  return `${days}d ${hours}h ${minutes}m ${secs}s`;
}

console.log(`System Uptime: ${formatUptime(os.uptime())}`);
```

#### 12. `os.networkInterfaces()` - Get Network Interfaces

**Purpose:** Returns an object containing network interfaces that have been assigned a network address

**Syntax:**
```javascript
os.networkInterfaces()
```

**Examples:**
```javascript
const os = require('os');

// Get network interfaces
const interfaces = os.networkInterfaces();
console.log('Network Interfaces:', interfaces);

// Real-world example - Get local IP address
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      // Skip internal (loopback) addresses
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  
  return '127.0.0.1'; // Fallback to localhost
}

const localIP = getLocalIP();
console.log(`Local IP Address: ${localIP}`);

// Get all IP addresses
function getAllIPs() {
  const interfaces = os.networkInterfaces();
  const ips = [];
  
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push({
          interface: name,
          address: iface.address,
          netmask: iface.netmask,
          mac: iface.mac
        });
      }
    }
  }
  
  return ips;
}

console.log('All IP Addresses:', getAllIPs());
```

#### 13. `os.endianness()` - Get CPU Endianness

**Purpose:** Returns the endianness of the CPU

**Syntax:**
```javascript
os.endianness()
```

**Examples:**
```javascript
const os = require('os');

// Get endianness
const endianness = os.endianness();
console.log(endianness);
// 'BE' - Big Endian
// 'LE' - Little Endian (most common)

// Real-world example
if (os.endianness() === 'LE') {
  console.log('Little Endian system');
} else {
  console.log('Big Endian system');
}
```

#### 14. `os.loadavg()` - Get System Load Average (Unix/Linux only)

**Purpose:** Returns an array containing the 1, 5, and 15 minute load averages (Unix/Linux only)

**Syntax:**
```javascript
os.loadavg()
```

**Examples:**
```javascript
const os = require('os');

// Get load average (Unix/Linux only)
if (os.platform() !== 'win32') {
  const loadAvg = os.loadavg();
  console.log('Load Average:', {
    '1 minute': loadAvg[0].toFixed(2),
    '5 minutes': loadAvg[1].toFixed(2),
    '15 minutes': loadAvg[2].toFixed(2)
  });
} else {
  console.log('Load average not available on Windows');
}
```

#### 15. `os.userInfo([options])` - Get User Information

**Purpose:** Returns information about the current user

**Syntax:**
```javascript
os.userInfo([options])
```

**Examples:**
```javascript
const os = require('os');

// Get user info
const userInfo = os.userInfo();
console.log(userInfo);
// {
//   username: 'username',
//   uid: 1000,        // Unix/Linux only
//   gid: 1000,        // Unix/Linux only
//   homedir: '/home/username',
//   shell: '/bin/bash'  // Unix/Linux only
// }

// With encoding option
const userInfoEncoded = os.userInfo({ encoding: 'buffer' });
console.log(userInfoEncoded);

// Real-world example
console.log(`Current User: ${userInfo.username}`);
console.log(`Home Directory: ${userInfo.homedir}`);
```

### Real-World Examples

#### Example 1: System Information Dashboard

```javascript
const os = require('os');

function getSystemInfo() {
  return {
    platform: os.platform(),
    type: os.type(),
    release: os.release(),
    architecture: os.arch(),
    hostname: os.hostname(),
    cpus: {
      count: os.cpus().length,
      model: os.cpus()[0].model
    },
    memory: {
      total: `${(os.totalmem() / 1024 / 1024 / 1024).toFixed(2)} GB`,
      free: `${(os.freemem() / 1024 / 1024 / 1024).toFixed(2)} GB`,
      used: `${((os.totalmem() - os.freemem()) / 1024 / 1024 / 1024).toFixed(2)} GB`
    },
    uptime: `${Math.floor(os.uptime() / 3600)} hours`,
    homeDir: os.homedir(),
    tempDir: os.tmpdir()
  };
}

console.log('System Information:', JSON.stringify(getSystemInfo(), null, 2));
```

#### Example 2: Server Health Check

```javascript
const os = require('os');

function checkServerHealth() {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    issues: []
  };
  
  // Check memory usage
  const memUsage = ((os.totalmem() - os.freemem()) / os.totalmem()) * 100;
  if (memUsage > 90) {
    health.status = 'warning';
    health.issues.push(`High memory usage: ${memUsage.toFixed(2)}%`);
  }
  
  // Check disk space (would need additional module)
  // Check CPU load (Unix/Linux)
  if (os.platform() !== 'win32') {
    const loadAvg = os.loadavg()[0];
    const cpuCount = os.cpus().length;
    if (loadAvg > cpuCount * 2) {
      health.status = 'warning';
      health.issues.push(`High CPU load: ${loadAvg.toFixed(2)}`);
    }
  }
  
  return health;
}

console.log('Server Health:', checkServerHealth());
```

#### Example 3: Cross-Platform Path Handling

```javascript
const os = require('os');
const path = require('path');

// Get platform-specific paths
function getPlatformPaths() {
  const platform = os.platform();
  
  if (platform === 'win32') {
    return {
      config: path.join(os.homedir(), 'AppData', 'Roaming', 'myapp'),
      logs: path.join(os.homedir(), 'AppData', 'Local', 'myapp', 'logs'),
      temp: os.tmpdir()
    };
  } else {
    return {
      config: path.join(os.homedir(), '.config', 'myapp'),
      logs: path.join(os.homedir(), '.local', 'share', 'myapp', 'logs'),
      temp: os.tmpdir()
    };
  }
}

const paths = getPlatformPaths();
console.log('Platform Paths:', paths);
```

#### Example 4: Resource Monitoring

```javascript
const os = require('os');

// Monitor system resources
class SystemMonitor {
  constructor() {
    this.interval = null;
  }
  
  start(intervalMs = 5000) {
    this.interval = setInterval(() => {
      this.logResources();
    }, intervalMs);
  }
  
  stop() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }
  
  logResources() {
    const memUsage = ((os.totalmem() - os.freemem()) / os.totalmem()) * 100;
    const uptime = Math.floor(os.uptime() / 3600);
    
    console.log(`[${new Date().toISOString()}]`, {
      memory: `${memUsage.toFixed(2)}%`,
      uptime: `${uptime}h`,
      cpus: os.cpus().length
    });
  }
}

// Usage
const monitor = new SystemMonitor();
monitor.start(5000); // Log every 5 seconds

// Stop after 30 seconds
setTimeout(() => monitor.stop(), 30000);
```

#### Example 5: Network Interface Detection

```javascript
const os = require('os');

// Get primary network interface
function getPrimaryInterface() {
  const interfaces = os.networkInterfaces();
  
  // Priority order: Ethernet > WiFi > Other
  const priorities = ['eth0', 'en0', 'Ethernet', 'Wi-Fi', 'WiFi'];
  
  for (const priority of priorities) {
    if (interfaces[priority]) {
      for (const iface of interfaces[priority]) {
        if (iface.family === 'IPv4' && !iface.internal) {
          return {
            name: priority,
            address: iface.address,
            netmask: iface.netmask
          };
        }
      }
    }
  }
  
  // Fallback: get first non-internal IPv4
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return {
          name: name,
          address: iface.address,
          netmask: iface.netmask
        };
      }
    }
  }
  
  return null;
}

const primaryInterface = getPrimaryInterface();
console.log('Primary Network Interface:', primaryInterface);
```

#### Example 6: CPU Usage Calculation

```javascript
const os = require('os');

// Calculate CPU usage over time
function calculateCPUUsage(intervalMs = 1000) {
  return new Promise((resolve) => {
    const cpus1 = os.cpus();
    const startIdle = cpus1.reduce((acc, cpu) => acc + cpu.times.idle, 0);
    const startTotal = cpus1.reduce((acc, cpu) => {
      return acc + Object.values(cpu.times).reduce((sum, time) => sum + time, 0);
    }, 0);
    
    setTimeout(() => {
      const cpus2 = os.cpus();
      const endIdle = cpus2.reduce((acc, cpu) => acc + cpu.times.idle, 0);
      const endTotal = cpus2.reduce((acc, cpu) => {
        return acc + Object.values(cpu.times).reduce((sum, time) => sum + time, 0);
      }, 0);
      
      const idle = endIdle - startIdle;
      const total = endTotal - startTotal;
      const usage = 100 - (100 * idle / total);
      
      resolve(usage.toFixed(2));
    }, intervalMs);
  });
}

// Usage
calculateCPUUsage(1000).then(usage => {
  console.log(`CPU Usage: ${usage}%`);
});
```

### Quick Reference Table

| Method/Property | Purpose | Returns |
|----------------|---------|---------|
| `os.platform()` | Get OS platform | 'win32', 'darwin', 'linux', etc. |
| `os.type()` | Get OS type | 'Windows_NT', 'Darwin', 'Linux', etc. |
| `os.arch()` | Get CPU architecture | 'x64', 'arm', 'arm64', etc. |
| `os.release()` | Get OS release version | Version string |
| `os.hostname()` | Get system hostname | Hostname string |
| `os.homedir()` | Get home directory | Path string |
| `os.tmpdir()` | Get temp directory | Path string |
| `os.cpus()` | Get CPU information | Array of CPU objects |
| `os.totalmem()` | Get total memory | Bytes (number) |
| `os.freemem()` | Get free memory | Bytes (number) |
| `os.uptime()` | Get system uptime | Seconds (number) |
| `os.networkInterfaces()` | Get network interfaces | Object with interfaces |
| `os.endianness()` | Get CPU endianness | 'BE' or 'LE' |
| `os.loadavg()` | Get load average | Array [1min, 5min, 15min] |
| `os.userInfo()` | Get user information | User info object |

### Important Notes

- ✅ **Cross-platform:** Most methods work on all platforms, but some (like `loadavg()`) are Unix/Linux only
- ✅ **Memory values:** Always in bytes - convert to KB/MB/GB as needed
- ✅ **Uptime:** Returns seconds - format for display (days, hours, minutes)
- ✅ **Network interfaces:** Returns object with interface names as keys
- ✅ **CPU information:** Array contains one object per CPU core
- ⚠️ **Windows limitations:** Some methods (like `loadavg()`) don't work on Windows
- ⚠️ **Performance:** Some methods (like `cpus()`) can be expensive - cache results if needed

### No Installation Required
This is a built-in Node.js module, no installation needed.

---

## 11. HTTP (Node.js Built-in)

**Package:** `http`  
**Type:** Node.js Built-in Module  
**Purpose:** Create HTTP servers and make HTTP requests

### Description
The `http` module provides functionality to create HTTP servers and make HTTP client requests. While Express.js is built on top of the `http` module and is more commonly used, understanding the `http` module is important for low-level HTTP operations, creating custom servers, or making HTTP requests without external dependencies.

### Why HTTP Module is Important

**Use Cases:**
- ✅ **Creating HTTP Servers:** Build custom HTTP servers without Express
- ✅ **Making HTTP Requests:** Send GET, POST, PUT, DELETE requests
- ✅ **Understanding Express:** Express is built on top of `http` module
- ✅ **Low-level Control:** Fine-grained control over HTTP requests/responses
- ✅ **No Dependencies:** Built-in module, no need to install packages
- ✅ **Learning:** Understanding how HTTP works at a low level

### Key Methods

These are the **most commonly used methods** in day-to-day development:

- **`http.createServer()`** - Create HTTP server (most used!)
- **`http.request()`** - Make HTTP client request
- **`http.get()`** - Make HTTP GET request (simpler than request)
- **`server.listen()`** - Start server listening on port
- **`req.on('data')`** - Handle incoming request data
- **`res.write()` / `res.end()`** - Send response data

**Quick Examples:**
```javascript
const http = require('http');

// Most common: Create HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello World');
});

// Start server
server.listen(3000, () => {
  console.log('Server running on port 3000');
});

// Make HTTP GET request
http.get('http://api.example.com/data', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(data));
});
```

### Key Methods - Detailed

#### 1. `http.createServer([options][, requestListener])` - Create HTTP Server

**Purpose:** Creates an HTTP server instance

**Syntax:**
```javascript
http.createServer([options][, requestListener])
```

**Examples:**
```javascript
const http = require('http');

// Basic server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello World');
});

// Server with options
const server2 = http.createServer({
  keepAlive: true,
  keepAliveInitialDelay: 1000
}, (req, res) => {
  res.end('Response');
});

// Real-world example - Simple API server
const apiServer = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  
  if (req.method === 'GET' && req.url === '/api/users') {
    res.writeHead(200);
    res.end(JSON.stringify({ users: ['John', 'Jane'] }));
  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not Found' }));
  }
});

apiServer.listen(3000, () => {
  console.log('API Server running on http://localhost:3000');
});
```

#### 2. `server.listen([port][, host][, backlog][, callback])` - Start Server

**Purpose:** Starts the HTTP server listening for connections

**Syntax:**
```javascript
server.listen([port][, host][, backlog][, callback])
```

**Examples:**
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.end('Hello');
});

// Listen on port 3000
server.listen(3000);

// Listen on port with callback
server.listen(3000, () => {
  console.log('Server started on port 3000');
});

// Listen on specific host and port
server.listen(3000, 'localhost', () => {
  console.log('Server running on http://localhost:3000');
});

// Listen on all interfaces (0.0.0.0)
server.listen(3000, '0.0.0.0', () => {
  console.log('Server accessible from all network interfaces');
});

// Real-world example
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

#### 3. `http.request(options[, callback])` - Make HTTP Request

**Purpose:** Makes an HTTP request to a server

**Syntax:**
```javascript
http.request(options[, callback])
```

**Examples:**
```javascript
const http = require('http');

// Basic POST request
const options = {
  hostname: 'api.example.com',
  port: 80,
  path: '/users',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(JSON.stringify({ name: 'John' }))
  }
};

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Response:', JSON.parse(data));
  });
});

req.on('error', (error) => {
  console.error('Request error:', error);
});

// Send request body
req.write(JSON.stringify({ name: 'John' }));
req.end();

// Real-world example - API request function
function makeAPIRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.example.com',
      port: 443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', chunk => responseData += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(responseData));
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${responseData}`));
        }
      });
    });
    
    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Usage
makeAPIRequest('GET', '/users')
  .then(users => console.log(users))
  .catch(error => console.error(error));
```

#### 4. `http.get(options[, callback])` - Make HTTP GET Request

**Purpose:** Simplified method for making GET requests (automatically calls `req.end()`)

**Syntax:**
```javascript
http.get(options[, callback])
```

**Examples:**
```javascript
const http = require('http');

// Simple GET request
http.get('http://api.example.com/users', (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Response:', JSON.parse(data));
  });
}).on('error', (error) => {
  console.error('Error:', error);
});

// With options object
http.get({
  hostname: 'api.example.com',
  path: '/users',
  headers: {
    'User-Agent': 'MyApp/1.0'
  }
}, (res) => {
  // Handle response
}).on('error', (error) => {
  console.error('Error:', error);
});

// Real-world example - Fetch JSON data
function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      const { statusCode } = res;
      
      if (statusCode !== 200) {
        reject(new Error(`Request failed. Status: ${statusCode}`));
        return;
      }
      
      res.setEncoding('utf8');
      let rawData = '';
      
      res.on('data', chunk => rawData += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(rawData));
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', reject);
  });
}

// Usage
fetchJSON('http://api.example.com/data')
  .then(data => console.log(data))
  .catch(error => console.error(error));
```

#### 5. Request Object (`req`) - Incoming HTTP Request

**Purpose:** Represents the incoming HTTP request

**Key Properties and Methods:**
```javascript
const server = http.createServer((req, res) => {
  // Request properties
  console.log(req.method);        // 'GET', 'POST', 'PUT', 'DELETE'
  console.log(req.url);           // '/api/users?id=123'
  console.log(req.headers);        // Object with all headers
  console.log(req.headers['content-type']); // Specific header
  
  // Request events
  req.on('data', (chunk) => {
    // Handle request body data
    console.log('Received chunk:', chunk);
  });
  
  req.on('end', () => {
    // Request body finished
    console.log('Request complete');
  });
  
  req.on('error', (error) => {
    // Handle request errors
    console.error('Request error:', error);
  });
});
```

**Real-world example - Parse request body:**
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  let body = '';
  
  // Collect request body
  req.on('data', chunk => {
    body += chunk.toString();
  });
  
  req.on('end', () => {
    try {
      const data = JSON.parse(body);
      console.log('Received data:', data);
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, received: data }));
    } catch (error) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Invalid JSON' }));
    }
  });
});
```

#### 6. Response Object (`res`) - Outgoing HTTP Response

**Purpose:** Represents the outgoing HTTP response

**Key Methods:**
```javascript
const server = http.createServer((req, res) => {
  // Set status code and headers
  res.writeHead(200, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  });
  
  // Write response data
  res.write('Hello ');
  res.write('World');
  
  // End response (sends it)
  res.end();
  
  // Or write and end in one call
  res.end('Hello World');
});
```

**Real-world example - Send JSON response:**
```javascript
const server = http.createServer((req, res) => {
  const data = { message: 'Hello', users: ['John', 'Jane'] };
  
  res.writeHead(200, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  });
  
  res.end(JSON.stringify(data));
});
```

### Real-World Examples

#### Example 1: Simple HTTP Server

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  // Set response headers
  res.writeHead(200, { 'Content-Type': 'text/html' });
  
  // Send response
  res.end(`
    <html>
      <body>
        <h1>Hello from Node.js HTTP Server!</h1>
        <p>Method: ${req.method}</p>
        <p>URL: ${req.url}</p>
      </body>
    </html>
  `);
});

server.listen(3000, () => {
  console.log('Server running at http://localhost:3000');
});
```

#### Example 2: REST API Server

```javascript
const http = require('http');
const url = require('url');

let users = [
  { id: 1, name: 'John' },
  { id: 2, name: 'Jane' }
];

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;
  
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  
  // GET /users
  if (method === 'GET' && path === '/users') {
    res.writeHead(200);
    res.end(JSON.stringify(users));
  }
  // GET /users/:id
  else if (method === 'GET' && path.startsWith('/users/')) {
    const id = parseInt(path.split('/')[2]);
    const user = users.find(u => u.id === id);
    
    if (user) {
      res.writeHead(200);
      res.end(JSON.stringify(user));
    } else {
      res.writeHead(404);
      res.end(JSON.stringify({ error: 'User not found' }));
    }
  }
  // POST /users
  else if (method === 'POST' && path === '/users') {
    let body = '';
    
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const newUser = JSON.parse(body);
      newUser.id = users.length + 1;
      users.push(newUser);
      
      res.writeHead(201);
      res.end(JSON.stringify(newUser));
    });
  }
  else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not Found' }));
  }
});

server.listen(3000, () => {
  console.log('REST API Server running on http://localhost:3000');
});
```

#### Example 3: HTTP Client - Fetch Data

```javascript
const http = require('http');

function fetchData(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      const { statusCode } = res;
      
      if (statusCode !== 200) {
        reject(new Error(`Request failed. Status: ${statusCode}`));
        res.resume(); // Consume response data to free up memory
        return;
      }
      
      res.setEncoding('utf8');
      let rawData = '';
      
      res.on('data', chunk => rawData += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(rawData));
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', reject);
  });
}

// Usage
fetchData('http://jsonplaceholder.typicode.com/users')
  .then(users => {
    console.log('Users:', users);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

#### Example 4: File Server

```javascript
const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
  // Remove query string
  const filePath = req.url.split('?')[0];
  
  // Security: prevent path traversal
  if (filePath.includes('..')) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }
  
  // Serve from public directory
  const fullPath = path.join(__dirname, 'public', filePath || 'index.html');
  
  fs.readFile(fullPath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('File not found');
      return;
    }
    
    // Determine content type
    const ext = path.extname(fullPath);
    const contentTypes = {
      '.html': 'text/html',
      '.css': 'text/css',
      '.js': 'application/javascript',
      '.json': 'application/json',
      '.png': 'image/png',
      '.jpg': 'image/jpeg'
    };
    
    res.writeHead(200, {
      'Content-Type': contentTypes[ext] || 'text/plain'
    });
    res.end(data);
  });
});

server.listen(3000, () => {
  console.log('File server running on http://localhost:3000');
});
```

### Quick Reference Table

| Method | Purpose | Example |
|--------|---------|---------|
| `http.createServer()` | Create HTTP server | `http.createServer((req, res) => {...})` |
| `server.listen()` | Start server | `server.listen(3000)` |
| `http.request()` | Make HTTP request | `http.request(options, callback)` |
| `http.get()` | Make GET request | `http.get(url, callback)` |
| `req.method` | Request method | `'GET'`, `'POST'`, etc. |
| `req.url` | Request URL | `'/api/users?id=123'` |
| `req.headers` | Request headers | Object with headers |
| `res.writeHead()` | Set status & headers | `res.writeHead(200, {...})` |
| `res.write()` | Write response data | `res.write('data')` |
| `res.end()` | End response | `res.end('final data')` |

### Important Notes

- ✅ **Express is built on `http`:** Understanding `http` helps understand Express
- ✅ **Low-level control:** More control but more code than Express
- ✅ **No routing:** Must manually handle routes (Express does this automatically)
- ✅ **Request body:** Must manually parse request body (Express does this automatically)
- ✅ **HTTPS:** Use `https` module for HTTPS (similar API)
- ⚠️ **Error handling:** Always handle errors in request/response events
- ⚠️ **Memory:** Large request bodies can consume memory - use streams for large data
- ⚠️ **Security:** Always validate and sanitize user input

### HTTPS Module

For HTTPS servers and requests, use the `https` module (similar API):

```javascript
const https = require('https');

// HTTPS server (requires certificates)
const server = https.createServer({
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
}, (req, res) => {
  res.end('Hello HTTPS');
});

// HTTPS request
https.get('https://api.example.com/data', (res) => {
  // Handle response
});
```

### No Installation Required
This is a built-in Node.js module, no installation needed.

---

## 12. Express Rate Limit

**Package:** `express-rate-limit`  
**Type:** External NPM Package  
**Purpose:** Rate limiting middleware for Express

### Description
Express Rate Limit is a middleware that limits repeated requests to public APIs and/or endpoints. It helps prevent abuse, brute-force attacks, and DoS (Denial of Service) attacks by limiting the number of requests a client can make within a specified time window.

### Key Features
- **IP-based Limiting:** Limit requests per IP address
- **Time Windows:** Define time periods (e.g., 15 minutes, 1 hour)
- **Custom Messages:** Customize error messages
- **Skip Options:** Skip rate limiting for certain conditions
- **Store Options:** Use different storage backends (memory, Redis, etc.)
- **Rate Limit Headers:** Automatically adds headers showing rate limit status

### Common Usage
```javascript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);
```

### Configuration Options Explained

#### Basic Options

**`windowMs`** - Time window in milliseconds
```javascript
windowMs: 15 * 60 * 1000  // 15 minutes
windowMs: 60 * 60 * 1000  // 1 hour
windowMs: 24 * 60 * 60 * 1000  // 24 hours
```

**`max`** - Maximum number of requests allowed in the time window
```javascript
max: 100  // Allow 100 requests per window
max: 10   // Allow 10 requests per window
```

**`message`** - Error message sent when limit is exceeded
```javascript
message: "Too many requests, please try again later."
// or
message: {
  success: false,
  error: "Rate limit exceeded"
}
```

#### Header Options: `standardHeaders` and `legacyHeaders`

These options control which HTTP headers are added to responses to inform clients about rate limit status.

##### `standardHeaders: true` (Recommended)

**What it does:**
- Adds **RFC 7231 compliant** standard rate limit headers
- Uses modern header names that follow HTTP standards
- Headers added:
  - `RateLimit-Limit`: Maximum number of requests allowed
  - `RateLimit-Remaining`: Number of requests remaining in current window
  - `RateLimit-Reset`: Unix timestamp when the rate limit resets

**Example Response Headers:**
```
HTTP/1.1 200 OK
RateLimit-Limit: 100
RateLimit-Remaining: 95
RateLimit-Reset: 1704067200
```

**When limit is exceeded:**
```
HTTP/1.1 429 Too Many Requests
RateLimit-Limit: 100
RateLimit-Remaining: 0
RateLimit-Reset: 1704067200
Retry-After: 900
```

**Why use it:**
- ✅ **Standard compliant** - Follows RFC 7231
- ✅ **Modern approach** - Industry best practice
- ✅ **Client-friendly** - Clients can programmatically check limits
- ✅ **Future-proof** - Works with modern tools and libraries

##### `legacyHeaders: false` (Recommended)

**What it does:**
- **Disables** old/deprecated header names
- Prevents adding headers like `X-RateLimit-*` (old format)
- Keeps responses clean and standard-compliant

**Legacy headers (when `legacyHeaders: true`):**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

**Why disable it:**
- ❌ **Deprecated format** - Old naming convention
- ❌ **Not standard** - Doesn't follow RFC standards
- ❌ **Redundant** - Standard headers already provide this info
- ✅ **Cleaner responses** - Less header clutter

##### Your Current Configuration

```javascript
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,                    // 100 requests max
  message: {
    success: false,
    error: "Too many requests, please try again later.",
  },
  standardHeaders: true,   // ✅ Add modern standard headers
  legacyHeaders: false,    // ✅ Don't add old deprecated headers
});
```

**What this means:**
- ✅ Clients will receive `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset` headers
- ✅ No deprecated `X-RateLimit-*` headers will be added
- ✅ Modern, clean, standard-compliant implementation

### Complete Example with Headers

**Backend:**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,
  message: {
    success: false,
    error: "Too many requests, please try again later.",
  },
  standardHeaders: true,   // Enable standard rate limit headers
  legacyHeaders: false,    // Disable legacy headers
});

app.use('/api/', limiter);

app.get('/api/data', (req, res) => {
  res.json({ data: 'Some data' });
});
```

**Client Request (First Request):**
```javascript
fetch('http://localhost:3000/api/data')
  .then(response => {
    console.log(response.headers.get('RateLimit-Limit'));      // "100"
    console.log(response.headers.get('RateLimit-Remaining'));  // "99"
    console.log(response.headers.get('RateLimit-Reset'));       // "1704067200"
  });
```

**Client Request (After 100 requests - Rate Limited):**
```javascript
fetch('http://localhost:3000/api/data')
  .then(response => {
    console.log(response.status);  // 429 (Too Many Requests)
    console.log(response.headers.get('RateLimit-Remaining'));  // "0"
    console.log(response.headers.get('Retry-After'));          // "900" (seconds)
  });
```

### Header Comparison Table

| Header Type | Header Name | `standardHeaders: true` | `legacyHeaders: true` |
|------------|-------------|------------------------|----------------------|
| **Limit** | `RateLimit-Limit` | ✅ Added | ❌ Not added |
| **Limit (Legacy)** | `X-RateLimit-Limit` | ❌ Not added | ✅ Added |
| **Remaining** | `RateLimit-Remaining` | ✅ Added | ❌ Not added |
| **Remaining (Legacy)** | `X-RateLimit-Remaining` | ❌ Not added | ✅ Added |
| **Reset** | `RateLimit-Reset` | ✅ Added | ❌ Not added |
| **Reset (Legacy)** | `X-RateLimit-Reset` | ❌ Not added | ✅ Added |

### Recommended Configuration

```javascript
// ✅ RECOMMENDED - Modern and standard-compliant
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,   // Use modern standard headers
  legacyHeaders: false,    // Don't use old headers
});

// ❌ NOT RECOMMENDED - Using deprecated headers
const oldLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: false,  // Missing modern headers
  legacyHeaders: true,      // Using old format
});
```

### Other Useful Options

```javascript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  
  // Skip rate limiting for certain conditions
  skip: (req) => {
    // Skip for admin users
    return req.user && req.user.isAdmin;
  },
  
  // Custom key generator (rate limit by user ID instead of IP)
  keyGenerator: (req) => {
    return req.user ? req.user.id : req.ip;
  },
  
  // Custom handler when limit is exceeded
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error: 'Too many requests',
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000)
    });
  }
});
```

### Installation
```bash
npm install express-rate-limit
```

---

## 13. Express.json() and Body Parser Relationship

### What is `express.json()`?

**Purpose:** Parse incoming JSON request bodies and make them available in `req.body`

`express.json()` is a built-in Express middleware (available since Express 4.16.0) that:
1. **Parses JSON data** from incoming HTTP request bodies
2. **Converts JSON strings** to JavaScript objects
3. **Makes parsed data available** in `req.body` for your route handlers

### Why is it needed?

When a client sends JSON data in the request body (like from a POST or PUT request), Express doesn't automatically parse it. Without `express.json()`, `req.body` would be `undefined` or contain raw string data.

**Example without `express.json()`:**
```javascript
// Client sends: { "name": "John", "age": 30 }
app.post('/user', (req, res) => {
  console.log(req.body); // undefined or raw string
});
```

**Example with `express.json()`:**
```javascript
app.use(express.json()); // Enable JSON parsing

app.post('/user', (req, res) => {
  console.log(req.body); // { name: "John", age: 30 } ✅
  console.log(req.body.name); // "John" ✅
});
```

### The Relationship with Body-Parser

**Historical Context:**
- **Before Express 4.16.0:** You had to install `body-parser` as a separate package
- **After Express 4.16.0:** Express integrated body-parser's functionality directly

**The Connection:**
- `express.json()` is **literally the same code** as `bodyParser.json()` from the body-parser package
- Express team **adopted body-parser** and made it built-in to reduce dependencies
- The body-parser package still exists, but it's now **redundant** for Express 4.16.0+

**Old Way (Before Express 4.16.0):**
```javascript
const bodyParser = require('body-parser');
app.use(bodyParser.json());        // Parse JSON
app.use(bodyParser.urlencoded({ extended: true })); // Parse form data
```

**New Way (Express 4.16.0+):**
```javascript
// No need to install body-parser!
app.use(express.json());                    // Parse JSON (same as bodyParser.json())
app.use(express.urlencoded({ extended: true })); // Parse form data (same as bodyParser.urlencoded())
```

### How `express.json()` Works

1. **Intercepts requests** with `Content-Type: application/json` header
2. **Reads the raw body** from the HTTP request stream
3. **Parses the JSON string** using `JSON.parse()`
4. **Attaches the parsed object** to `req.body`
5. **Passes control** to the next middleware or route handler

### Configuration Options

`express.json()` accepts options:
```javascript
app.use(express.json({
  limit: '10mb',        // Maximum request body size
  strict: true,         // Only parse arrays and objects
  type: 'application/json' // Content-Type to match
}));
```

### Common Use Cases

- **REST APIs:** Receiving JSON data from frontend applications
- **Mobile Apps:** Handling JSON payloads from mobile clients
- **Microservices:** Communication between services using JSON
- **AJAX/Fetch Requests:** Processing JSON from browser requests

### Important Notes

- **Must be placed before routes** that need to access `req.body`
- **Only parses JSON** - use `express.urlencoded()` for form data
- **Security:** Consider setting a `limit` option to prevent large payload attacks
- **Performance:** Parsing happens synchronously, so very large JSON bodies can block the event loop

---

## 14. Express.urlencoded() - Understanding URL-Encoded Form Data

### What is `express.urlencoded()`?

**Purpose:** Parse incoming URL-encoded form data and make it available in `req.body`

`express.urlencoded()` is a built-in Express middleware that:
1. **Parses URL-encoded data** from HTML forms (Content-Type: `application/x-www-form-urlencoded`)
2. **Converts URL-encoded strings** to JavaScript objects
3. **Makes parsed data available** in `req.body` for your route handlers

### What is "URL-Encoded" Format?

URL-encoded format is how HTML forms send data by default. It looks like this:
```
name=John+Doe&age=30&email=john%40example.com
```

**Key characteristics:**
- Fields are separated by `&`
- Spaces are encoded as `+` or `%20`
- Special characters are URL-encoded (e.g., `@` becomes `%40`)
- Format: `key=value&key2=value2`

### What Does `{ extended: true }` Mean?

The `extended` option determines which parsing library to use:

#### `extended: false` (Legacy Mode)
- Uses Node's built-in `querystring` library
- **Limited:** Only supports simple key-value pairs
- **No nested objects or arrays**
- **Example:** `name=John&age=30` → `{ name: "John", age: "30" }`

#### `extended: true` (Recommended - Modern Mode)
- Uses `qs` library (more powerful)
- **Supports nested objects:** `user[name]=John&user[age]=30`
- **Supports arrays:** `hobbies[]=reading&hobbies[]=coding`
- **More flexible and feature-rich**
- **Example:** `user[name]=John&user[age]=30` → `{ user: { name: "John", age: "30" } }`

### Real-World Scenarios

#### Scenario 1: HTML Form Submission

**Frontend (HTML Form):**
```html
<form action="/submit" method="POST">
  <input type="text" name="username" value="john_doe">
  <input type="email" name="email" value="john@example.com">
  <input type="number" name="age" value="25">
  <button type="submit">Submit</button>
</form>
```

**What the browser sends:**
```
POST /submit HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=john_doe&email=john%40example.com&age=25
```

**Backend (Express):**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/submit', (req, res) => {
  console.log(req.body);
  // Output: { username: 'john_doe', email: 'john@example.com', age: '25' }
  
  res.json({ message: 'Form submitted successfully', data: req.body });
});
```

#### Scenario 2: Nested Form Data (extended: true)

**Frontend (HTML Form with Nested Fields):**
```html
<form action="/user" method="POST">
  <input type="text" name="user[name]" value="John Doe">
  <input type="text" name="user[email]" value="john@example.com">
  <input type="text" name="address[street]" value="123 Main St">
  <input type="text" name="address[city]" value="New York">
  <button type="submit">Submit</button>
</form>
```

**What the browser sends:**
```
user[name]=John+Doe&user[email]=john%40example.com&address[street]=123+Main+St&address[city]=New+York
```

**Backend with `extended: true`:**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/user', (req, res) => {
  console.log(req.body);
  // Output: {
  //   user: { name: 'John Doe', email: 'john@example.com' },
  //   address: { street: '123 Main St', city: 'New York' }
  // }
  
  const userName = req.body.user.name; // "John Doe" ✅
  const city = req.body.address.city;  // "New York" ✅
});
```

**Backend with `extended: false`:**
```javascript
app.use(express.urlencoded({ extended: false }));

app.post('/user', (req, res) => {
  console.log(req.body);
  // Output: {
  //   'user[name]': 'John Doe',
  //   'user[email]': 'john@example.com',
  //   'address[street]': '123 Main St',
  //   'address[city]': 'New York'
  // }
  // ❌ Nested structure is lost! Keys are strings with brackets
});
```

#### Scenario 3: Arrays in Form Data (extended: true)

**Frontend (HTML Form with Checkboxes/Arrays):**
```html
<form action="/preferences" method="POST">
  <input type="checkbox" name="hobbies[]" value="reading" checked>
  <input type="checkbox" name="hobbies[]" value="coding" checked>
  <input type="checkbox" name="hobbies[]" value="gaming">
  <button type="submit">Submit</button>
</form>
```

**What the browser sends:**
```
hobbies[]=reading&hobbies[]=coding
```

**Backend with `extended: true`:**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/preferences', (req, res) => {
  console.log(req.body);
  // Output: { hobbies: ['reading', 'coding'] } ✅
  
  req.body.hobbies.forEach(hobby => {
    console.log(hobby); // "reading", "coding"
  });
});
```

**Backend with `extended: false`:**
```javascript
app.use(express.urlencoded({ extended: false }));

app.post('/preferences', (req, res) => {
  console.log(req.body);
  // Output: { 'hobbies[]': 'coding' } ❌ Only last value!
  // Arrays are not properly handled
});
```

#### Scenario 4: AJAX/Fetch Request with FormData

**Frontend (JavaScript):**
```javascript
// Create form data
const formData = new FormData();
formData.append('username', 'john_doe');
formData.append('email', 'john@example.com');

// Send as URL-encoded (default for FormData)
fetch('/api/user', {
  method: 'POST',
  body: formData  // Browser sets Content-Type: application/x-www-form-urlencoded
});
```

**Backend:**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/api/user', (req, res) => {
  console.log(req.body);
  // Output: { username: 'john_doe', email: 'john@example.com' }
});
```

#### Scenario 5: jQuery/Axios Form Submission

**Frontend (jQuery):**
```javascript
$.ajax({
  url: '/api/submit',
  method: 'POST',
  data: {
    name: 'John',
    age: 30,
    city: 'New York'
  },
  // jQuery automatically converts to URL-encoded format
});
```

**Backend:**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/api/submit', (req, res) => {
  console.log(req.body);
  // Output: { name: 'John', age: '30', city: 'New York' }
  // Note: age is a string '30', not number 30
});
```

### Comparison: extended: true vs extended: false

| Feature | `extended: false` | `extended: true` |
|---------|-------------------|------------------|
| **Nested Objects** | ❌ Not supported | ✅ Supported |
| **Arrays** | ❌ Not supported | ✅ Supported |
| **Complex Data** | ❌ Limited | ✅ Full support |
| **Performance** | ⚡ Faster | 🐢 Slightly slower |
| **Security** | ✅ More secure | ⚠️ Can parse complex nested data |
| **Recommendation** | Legacy only | ✅ **Use this** |

### When to Use `express.urlencoded()`

✅ **Use it when:**
- Receiving data from HTML forms
- Handling traditional form submissions
- Processing data from `<form>` elements
- Working with `FormData` objects
- Receiving `application/x-www-form-urlencoded` content type

❌ **Don't use it for:**
- JSON data (use `express.json()` instead)
- File uploads (use `multer` instead)
- Raw text or binary data

### Complete Example: Contact Form

**Frontend:**
```html
<!DOCTYPE html>
<html>
<body>
  <form action="/contact" method="POST">
    <input type="text" name="name" placeholder="Your Name" required>
    <input type="email" name="email" placeholder="Your Email" required>
    <textarea name="message" placeholder="Your Message" required></textarea>
    <button type="submit">Send Message</button>
  </form>
</body>
</html>
```

**Backend:**
```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/contact', (req, res) => {
  const { name, email, message } = req.body;
  
  console.log('Contact form submission:');
  console.log('Name:', name);
  console.log('Email:', email);
  console.log('Message:', message);
  
  // Save to database, send email, etc.
  
  res.json({ 
    success: true, 
    message: 'Thank you for your message!' 
  });
});
```

### Important Notes

- **Always use `extended: true`** unless you have a specific reason not to
- **Must be placed before routes** that need to access `req.body`
- **Works with HTML forms** by default (they send URL-encoded data)
- **Values are always strings** - convert to numbers if needed: `parseInt(req.body.age)`
- **Security:** Be careful with nested parsing - validate and sanitize input
- **Content-Type:** Only processes requests with `application/x-www-form-urlencoded` header

### Difference from `express.json()`

| Feature | `express.json()` | `express.urlencoded()` |
|---------|------------------|------------------------|
| **Content-Type** | `application/json` | `application/x-www-form-urlencoded` |
| **Data Format** | JSON strings | URL-encoded strings |
| **Use Case** | APIs, AJAX with JSON | HTML forms, traditional forms |
| **Example** | `{"name":"John"}` | `name=John&age=30` |

---

## 15. Express.static() - Serving Static Files

### What is `express.static()`?

**Purpose:** Serve static files (HTML, CSS, JavaScript, images, etc.) directly from a directory

`express.static()` is a built-in Express middleware that serves static files from a specified directory. It's one of the most commonly used Express features for serving frontend assets, images, documents, and other files that don't change dynamically.

### Why is it needed?    

When you have files like:
- **HTML files** (`index.html`, `about.html`)
- **CSS stylesheets** (`style.css`, `bootstrap.css`)
- **JavaScript files** (`app.js`, `script.js`)
- **Images** (`logo.png`, `photo.jpg`)
- **Documents** (`report.pdf`, `data.json`)
- **Uploaded files** (user uploads stored in a folder)

You need a way to serve these files to clients. Without `express.static()`, you'd have to manually write routes for each file, which is impractical.

### How it Works

1. **Specifies a directory** containing static files
2. **Maps URL paths** to files in that directory
3. **Automatically serves files** when requested
4. **Handles file types** correctly (sets proper Content-Type headers)
5. **Supports directory browsing** (optional) 

### Basic Syntax

```javascript
app.use(path, express.static(directory));
```

- **`path`** (optional): URL path prefix (e.g., `/uploads`, `/public`, `/static`)
- **`directory`**: Physical directory path on your server (e.g., `'./uploads'`, `'./public'`)

### Real-World Scenarios

#### Scenario 1: Serving Uploaded Files

**Problem:** Users upload images/files, and you need to make them accessible via URL

**Directory Structure:**
```
project/
  ├── server.js
  └── uploads/
      ├── image-123.jpg
      ├── document-456.pdf
      └── video-789.mp4
```

**Backend:**
```javascript
// Serve files from 'uploads' directory at URL path '/uploads'
app.use('/uploads', express.static('uploads'));

// Now files are accessible at:
// http://localhost:3000/uploads/image-123.jpg
// http://localhost:3000/uploads/document-456.pdf
// http://localhost:3000/uploads/video-789.mp4
```

**Frontend (HTML):**
```html
<!-- Access uploaded image -->
<img src="http://localhost:3000/uploads/image-123.jpg" alt="User Image">

<!-- Link to document -->
<a href="http://localhost:3000/uploads/document-456.pdf">Download PDF</a>
```

#### Scenario 2: Serving Frontend Assets (HTML, CSS, JS)

**Directory Structure:**
```
project/
  ├── server.js
  └── public/
      ├── index.html
      ├── css/
      │   └── style.css
      ├── js/
      │   └── app.js
      └── images/
          └── logo.png
```

**Backend:**
```javascript
// Serve all files from 'public' directory at root URL
app.use(express.static('public'));

// Files are accessible at:
// http://localhost:3000/index.html
// http://localhost:3000/css/style.css
// http://localhost:3000/js/app.js
// http://localhost:3000/images/logo.png
```

**Frontend (index.html):**
```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <img src="/images/logo.png" alt="Logo">
  <script src="/js/app.js"></script>
</body>
</html>
```

#### Scenario 3: Multiple Static Directories

**Backend:**
```javascript
// Serve public assets at root
app.use(express.static('public')); // Serve assets from "public" Dir. 

// Serve uploaded files at /uploads path
app.use('/uploads', express.static('uploads')); // Serve assets from "uploads" Dir, if we get Request at "/uploads" path/route. 

// Serve admin assets at /admin path
app.use('/admin', express.static('admin-assets')); // Serve assets from "admin-assets" Dir, if we get Request at "/admin" path/route. 
```

**Access:**
- `http://localhost:3000/style.css` → from `public/` directory
- `http://localhost:3000/uploads/photo.jpg` → from `uploads/` directory
- `http://localhost:3000/admin/dashboard.html` → from `admin-assets/` directory

#### Scenario 4: Your Current Code

**In your server.js:**
```javascript
app.use('./uploads', express.static('upload'));
```

**⚠️ Potential Issues:**
1. **Path mismatch:** You're using `'./uploads'` (with dot) as the URL path - should be `'/uploads'` (with forward slash)
2. **Directory name:** Using `'upload'` (singular) but your variable is `uploadDir = "./uploads"` (plural)

**Recommended Fix:**
```javascript
// Option 1: Match your uploadDir variable
app.use('/uploads', express.static('uploads'));

// Option 2: Use path.join for better cross-platform support
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

### Understanding the Parameters

#### Without URL Path (Root Level)
```javascript
app.use(express.static('public'));
// Files in 'public' folder are served at root:
// public/index.html → http://localhost:3000/index.html
// public/css/style.css → http://localhost:3000/css/style.css
```

#### With URL Path (Prefixed)
```javascript
app.use('/static', express.static('public'));
// Files in 'public' folder are served with /static prefix:
// public/index.html → http://localhost:3000/static/index.html
// public/css/style.css → http://localhost:3000/static/css/style.css
```

### Advanced Configuration

#### With Options
```javascript
const express = require('express');
const path = require('path');

app.use('/uploads', express.static('uploads', {
  // Set custom headers
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.pdf')) {
      res.setHeader('Content-Disposition', 'attachment');
    }
  },
  // Enable directory listing (shows files in directory)
  index: false, // Don't serve index.html automatically
  // Custom 404 handler
  fallthrough: true
}));
```

#### Absolute vs Relative Paths
```javascript
const path = require('path');

// Relative path (relative to where node process runs)
app.use('/uploads', express.static('uploads'));

// Absolute path (recommended for production)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Using __dirname ensures path works regardless of where you run the script
```

### Common Use Cases

✅ **Serving uploaded files:**
```javascript
app.use('/uploads', express.static('uploads'));
```

✅ **Serving frontend build files:**
```javascript
app.use(express.static('dist')); // React/Vue build output
```

✅ **Serving public assets:**
```javascript
app.use('/assets', express.static('public'));
```

✅ **Serving documentation:**
```javascript
app.use('/docs', express.static('documentation'));
```

### How It Differs from Regular Routes

**Without express.static() (Manual Route):**
```javascript
app.get('/uploads/image.jpg', (req, res) => {
  res.sendFile(path.join(__dirname, 'uploads', 'image.jpg'));
});
// ❌ Have to write a route for EVERY file
```

**With express.static() (Automatic):**
```javascript
app.use('/uploads', express.static('uploads'));
// ✅ Automatically serves ANY file in the uploads directory
```

### Security Considerations

⚠️ **Important Security Notes:**

1. **Don't serve sensitive directories:**
```javascript
// ❌ BAD - Exposes entire project
app.use(express.static('.'));

// ✅ GOOD - Only serve specific safe directory
app.use(express.static('public'));
```

2. **Validate file access:**
```javascript
// For user uploads, consider adding authentication
app.use('/uploads', authenticateUser, express.static('uploads'));
```

3. **Set file size limits:**
```javascript
// Use express.json() limit for request body
app.use(express.json({ limit: '10mb' }));
```

### Complete Example: File Upload + Serving

**Backend:**
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const uploadDir = './uploads';

// Create uploads directory
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer for file uploads
const upload = multer({ dest: uploadDir });

// Serve uploaded files
app.use('/uploads', express.static(uploadDir));

// Upload endpoint
app.post('/upload', upload.single('file'), (req, res) => {
  const fileUrl = `/uploads/${req.file.filename}`;
  res.json({ 
    success: true, 
    fileUrl: fileUrl,
    message: 'File uploaded successfully'
  });
});

app.listen(3000);
```

**Frontend:**
```html
<form id="uploadForm">
  <input type="file" name="file" id="fileInput">
  <button type="submit">Upload</button>
</form>
<img id="preview" style="display: none;">

<script>
document.getElementById('uploadForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const formData = new FormData();
  formData.append('file', document.getElementById('fileInput').files[0]);
  
  const response = await fetch('/upload', {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  
  // Display uploaded image using the static file URL
  if (data.success) {
    document.getElementById('preview').src = data.fileUrl;
    document.getElementById('preview').style.display = 'block';
  }
});
</script>
```

### Key Points to Remember

1. **`express.static()` serves files automatically** - no need for individual routes
2. **First parameter is URL path** (optional, defaults to root `/`)
3. **Second parameter is directory path** (where files are stored)
4. **Files are accessible via HTTP GET requests**
5. **Works with any file type** (images, PDFs, videos, etc.)
6. **Use absolute paths** (`path.join(__dirname, 'dir')`) for production
7. **Place before other routes** to avoid conflicts
8. **Security:** Only serve directories you trust

### Common Mistakes

❌ **Wrong:**
```javascript
app.use('./uploads', express.static('upload')); // Wrong path format
app.use('/uploads', express.static('./uploads')); // Works but relative paths can be problematic
```

✅ **Correct:**
```javascript
app.use('/uploads', express.static('uploads')); // Simple and works
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Best practice
```

---

## 16. Body Parser (Deprecated)

**Package:** `body-parser`  
**Type:** External NPM Package (Deprecated)  
**Purpose:** Parse incoming request bodies

### Description
Body Parser was used to parse incoming request bodies in a middleware before your handlers. However, **Express 4.16.0+ includes built-in body parsing**, making this package redundant.

### Current Status
- **Deprecated:** No longer needed with Express 4.16.0+
- **Built-in Alternative:** Use `express.json()` and `express.urlencoded()` instead
- **Direct Relationship:** `express.json()` is the same as `bodyParser.json()`

### Why It's Not Needed
The body-parser package is not needed because Express now provides built-in methods that do the exact same thing:
- `express.json()` = `bodyParser.json()`
- `express.urlencoded()` = `bodyParser.urlencoded()`

### Modern Usage (Express Built-in)
```javascript
// Instead of body-parser, use:
app.use(express.json()); // Parse JSON bodies (replaces bodyParser.json())
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies (replaces bodyParser.urlencoded())
```

### Installation (Not Recommended)
```bash
npm install body-parser  # Only if using Express < 4.16.0
```

---

## 17. Testing with Postman

This section documents everything a backend developer needs to set in Postman so that the server receives data correctly. Missing or wrong headers/settings cause empty `req.body`, 400 errors, and auth failures. Use this as a reference for all common scenarios.

---

### 17.1. Why Headers and Settings Matter

**What goes wrong when you skip them:**

| You forget / set wrong | What happens on the server |
|------------------------|----------------------------|
| **Content-Type: application/json** | Body is not parsed. `req.body` stays `{}`. You get "Name is required" or similar because `req.body.name` is `undefined`. |
| **Authorization: Bearer &lt;token&gt;** | Protected routes get no token. Server returns 401 Unauthorized. |
| **Body type** (e.g. raw vs form-data) | Server expects JSON but gets raw text or form data; parsing fails or fields are missing. |
| **Accept header** (optional) | Server may return HTML or wrong format instead of JSON. |

**Rule:** In Postman, **Headers** and **Body** must match what your backend expects. The sections below tell you exactly what to set and when.

---

### 17.2. Content-Type: Sending JSON, Form Data, and Files

The **Content-Type** header tells the server how the request body is encoded. Express uses it to choose the right parser (`express.json()`, `express.urlencoded()`, or multer for multipart).

#### When you send JSON (e.g. POST/PUT/PATCH with a JSON body)

**You must set:**

- **Header:** `Content-Type: application/json`
- **Body tab:** **raw** → dropdown set to **JSON**

**Why:** Without `Content-Type: application/json`, Express does **not** run the JSON parser. The raw body is not parsed, so `req.body` remains `{}`. Your validation then fails with "Name is required" or similar.

**Postman steps:**

1. Open your request (e.g. POST `http://localhost:3000/api/courses`).
2. Go to **Headers**.
3. Add (or ensure):
   - **Key:** `Content-Type`
   - **Value:** `application/json`
4. Go to **Body**.
5. Select **raw**.
6. In the dropdown to the right of "raw", choose **JSON**.
7. Type or paste your JSON, e.g.:
```json
{
  "name": "React Fundamentals",
  "author": "Alex Smith",
  "price": 149,
  "isPublished": true
}
```

**Server side:** You need `app.use(express.json())` so that `req.body` is the parsed object.

---

#### When you send form data (key=value, no files)

**Use when:** API expects `application/x-www-form-urlencoded` (e.g. classic HTML form submit, or login form).

**You must set:**

- **Header:** Usually set automatically by Postman when you pick this body type: `Content-Type: application/x-www-form-urlencoded`
- **Body tab:** **x-www-form-urlencoded**

**Postman steps:**

1. **Body** → **x-www-form-urlencoded**.
2. Add key-value rows (e.g. `username`, `password`).

**Server side:** You need `app.use(express.urlencoded({ extended: true }))` so that `req.body` contains the form fields.

---

#### When you send files (multipart/form-data)

**Use when:** Uploading files (images, documents) along with other fields.

**You must set:**

- **Header:** Postman sets it automatically when you use form-data: `Content-Type: multipart/form-data; boundary=...`
- **Body tab:** **form-data**

**Postman steps:**

1. **Body** → **form-data**.
2. Add keys. For a file:
   - In the **Value** column, change type from "Text" to **File**.
   - Choose file.
3. Add other fields as Text keys (e.g. `title`, `userId`).

**Server side:** You use **multer** (or similar) to parse multipart data. Do **not** use `express.json()` or `express.urlencoded()` for the multipart route; multer puts files in `req.file` / `req.files` and other fields in `req.body`.

---

### 17.3. Authorization: Bearer Token, Basic Auth, API Key

#### Bearer Token (JWT or session token)

**Use when:** After login you get a token; protected routes expect it in the `Authorization` header.

**You must set:**

- **Header:** `Authorization: Bearer <your-token>`

**Postman steps (recommended):**

1. Go to **Authorization** tab.
2. **Type:** select **Bearer Token**.
3. **Token:** paste the token (without the word "Bearer").

Postman will send: `Authorization: Bearer eyJhbGciOiJIUzI1NiIs...`

**Manual way (Headers tab):**

- **Key:** `Authorization`
- **Value:** `Bearer eyJhbGciOiJIUzI1NiIs...` (include the word "Bearer" and a space)

**Typical workflow:**

1. POST to `/api/login` with JSON body `{ "email", "password" }` and `Content-Type: application/json`.
2. Copy the `token` from the response (e.g. `res.json({ token: "..." })`).
3. In other requests (GET /api/me, GET /api/courses, etc.), set Authorization to **Bearer Token** and paste that token.

**Server side:** Middleware reads `req.headers.authorization`, checks for `Bearer <token>`, and validates the token (e.g. JWT verify).

---

#### Basic Authentication (username:password)

**Use when:** API uses HTTP Basic Auth (username and password sent as base64).

**You must set:**

- **Header:** `Authorization: Basic <base64(username:password)>`

**Postman steps:**

1. **Authorization** tab.
2. **Type:** **Basic Auth**.
3. **Username** and **Password:** enter credentials.

Postman encodes them and sends `Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=`.

---

#### API Key (custom header)

**Use when:** API expects a key in a header like `X-API-Key` or `Api-Key`.

**You must set:**

- **Header:** e.g. `X-API-Key: your-api-key-here`

**Postman steps:**

1. **Headers** tab.
2. Add:
   - **Key:** `X-API-Key` (or whatever the API docs say).
   - **Value:** your API key.

**Server side:** Middleware reads `req.headers['x-api-key']` and validates it.

---

### 17.4. Request Body Types in Postman (raw, form-data, urlencoded)

| Body type in Postman | Content-Type sent        | When to use                         | Server expects                          |
|----------------------|--------------------------|-------------------------------------|-----------------------------------------|
| **none**             | (no body)                | GET requests (usually no body)      | No body parsing                         |
| **raw** + JSON       | application/json         | JSON APIs (create/update resources) | `express.json()` → `req.body`           |
| **raw** + Text/XML   | text/plain or application/xml | Special APIs                   | Custom parser or none                    |
| **form-data**        | multipart/form-data      | File uploads + fields               | Multer → `req.file`, `req.body`         |
| **x-www-form-urlencoded** | application/x-www-form-urlencoded | Form submit (no files)     | `express.urlencoded()` → `req.body`     |

**Important:** For JSON APIs, always use **raw** + **JSON** and set **Content-Type: application/json** (or rely on Postman setting it when you pick JSON). Using "raw" with "Text" and pasting JSON often does **not** set the header, so the server may not parse the body.

---

### 17.5. Query Parameters vs Request Body

| Data type      | Where to put it in Postman | Used for                          | Server reads it as                |
|----------------|----------------------------|-----------------------------------|-----------------------------------|
| **Query params** | **Params** tab (or URL)   | GET filters, pagination, search   | `req.query` (e.g. `req.query.page`) |
| **Request body** | **Body** tab              | POST/PUT/PATCH payload            | `req.body` (after parsing)        |

**Examples:**

- **GET** `/api/courses?page=1&limit=10` → **Params** in Postman: `page = 1`, `limit = 10`. Server: `req.query.page`, `req.query.limit`.
- **POST** `/api/courses` with course object → **Body** → raw JSON. Server: `req.body.name`, `req.body.author`, etc.
- **PUT** `/api/courses/1` with partial update → **Body** → raw JSON. Server: `req.body`.

Do **not** put JSON in the URL. Use the **Body** tab for POST/PUT/PATCH payloads.

---

### 17.6. Common Headers Quick Reference

| Header             | Example value                  | When to set                        |
|--------------------|--------------------------------|------------------------------------|
| **Content-Type**   | application/json               | Sending JSON in body               |
| **Content-Type**   | application/x-www-form-urlencoded | Sending form (no files)          |
| **Content-Type**   | (set by Postman)               | form-data (file upload)            |
| **Authorization** | Bearer &lt;token&gt;           | Protected routes (JWT/session)     |
| **Authorization** | Basic &lt;base64&gt;           | Basic Auth                         |
| **Accept**         | application/json               | Ask server to return JSON          |
| **X-API-Key**      | your-api-key                   | When API uses API key auth         |

---

### 17.7. Environment Variables and Workflow

**Why use Postman environments:**  
You can store base URL and token once and reuse them (e.g. switch between local and production, or refresh token after login).

**Suggested variables:**

- `base_url` — e.g. `http://localhost:3000` or `https://api.example.com`
- `token` — JWT or session token after login

**Usage in request:**

- URL: `{{base_url}}/api/courses`
- Authorization (Bearer Token): use `{{token}}` as the token value

**Typical workflow:**

1. Create environment with `base_url` and `token` (token can be empty at start).
2. POST to `{{base_url}}/api/login` with credentials.
3. Copy token from response → save to environment variable `token`.
4. For all other requests, use **Authorization → Bearer Token** with `{{token}}`. No need to paste token again until it expires.

---

### 17.8. Scenario Checklist and Examples

Use this as a quick checklist for each type of request.

#### Scenario: POST – Create resource (JSON body)

- Method: **POST**
- URL: `http://localhost:3000/api/courses`
- **Headers:** `Content-Type: application/json`
- **Body:** raw → JSON  
  Example: `{ "name": "React", "author": "Alex", "price": 149, "isPublished": true, "units": [...], "exam": [...] }`

---

#### Scenario: GET – List with query params

- Method: **GET**
- URL: `http://localhost:3000/api/courses`
- **Params:** e.g. `page=1`, `limit=10`, `search=node`
- **Body:** none

---

#### Scenario: GET – Protected route (Bearer token)

- Method: **GET**
- URL: `http://localhost:3000/api/me`
- **Authorization:** Bearer Token → paste token (or `{{token}}`)
- **Body:** none

---

#### Scenario: POST – Login (get token)

- Method: **POST**
- URL: `http://localhost:3000/api/login`
- **Headers:** `Content-Type: application/json`
- **Body:** raw → JSON  
  Example: `{ "email": "user@example.com", "password": "secret" }`
- Copy `token` from response and use it in subsequent requests as Bearer token.

---

#### Scenario: POST – File upload (multipart)

- Method: **POST**
- URL: `http://localhost:3000/api/upload`
- **Body:** form-data  
  - Key: `file` (type: File) → choose file  
  - Key: `title` (type: Text) → value
- Do **not** set Content-Type manually; Postman sets multipart boundary.

---

#### Scenario: PUT – Update resource (full replace, JSON body)

- Method: **PUT**
- URL: `http://localhost:3000/api/courses/1`
- **Headers:** `Content-Type: application/json`
- **Body:** raw → JSON (full resource)  
  Example: `{ "name": "Updated Name", "author": "Alex", "price": 199, "isPublished": true, "units": [...], "exam": [...] }`
- **Authorization:** Bearer Token if route is protected.

---

#### Scenario: PATCH – Partial update (JSON body)

- Method: **PATCH**
- URL: `http://localhost:3000/api/courses/1`
- **Headers:** `Content-Type: application/json`
- **Body:** raw → JSON (only changed fields)  
  Example: `{ "price": 199 }` or `{ "name": "New Name", "isPublished": false }`
- **Authorization:** Bearer Token if route is protected.

---

#### Scenario: DELETE – Remove resource

- Method: **DELETE**
- URL: `http://localhost:3000/api/courses/1`
- **Body:** none (usually). Some APIs accept body for bulk delete: raw → JSON e.g. `{ "ids": [1, 2, 3] }`.
- **Authorization:** Bearer Token if route is protected.

---

**Quick reminder:**  
- JSON body → **Content-Type: application/json** and **Body → raw → JSON**.  
- Protected routes → **Authorization: Bearer &lt;token&gt;** (or Basic/API Key as required).  
- File upload → **Body → form-data** and let Postman set Content-Type.

---

### 17.9. HTTP Status Codes and Reading the Response

**Where to see status in Postman:**  
After sending a request, the **status code** appears next to the response (e.g. `200 OK`, `400 Bad Request`, `401 Unauthorized`). The **response body** shows what the server returned (JSON, HTML, or plain text).

**Common status codes and what they mean:**

| Code | Meaning | When you see it |
|------|---------|------------------|
| **200 OK** | Success. Request succeeded. | GET returned data; PUT/PATCH updated; sometimes DELETE. |
| **201 Created** | Success. Resource was created. | POST create (e.g. new course, new user). |
| **204 No Content** | Success. No body in response. | Often DELETE (resource removed, nothing to return). |
| **400 Bad Request** | Client error. Request was invalid. | Missing/invalid body, validation failed (e.g. "Name is required"), wrong Content-Type. |
| **401 Unauthorized** | Client error. Not authenticated. | No token, wrong token, or token expired. |
| **403 Forbidden** | Client error. Authenticated but not allowed. | Valid token but no permission for this resource. |
| **404 Not Found** | Client error. Resource or route not found. | Wrong URL, or ID doesn't exist (e.g. GET /api/courses/999). |
| **409 Conflict** | Client error. Conflict with current state. | Duplicate email, version conflict. |
| **429 Too Many Requests** | Client error. Rate limit exceeded. | Too many requests in a short time; wait or use Retry-After. |
| **500 Internal Server Error** | Server error. Something broke on the server. | Unhandled exception, DB error; check server logs. |

**Reading the response body:**

- **JSON:** Response tab shows formatted JSON. Use **Pretty** view. Your backend often returns `{ "message": "Error text" }` or `{ "error": "Name is required" }` on 400/401/500.
- **HTML:** Sometimes 404/500 return an HTML error page. If you expect JSON, set **Accept: application/json** (see 17.11) so the server may return JSON instead.
- **Empty body:** 204 and some 201 responses have no body; that's normal.

**Rate limiting (429):**

- Server may send header **Retry-After** (seconds to wait). In Postman you can add a delay or retry later.
- Fix: reduce request frequency, or use rate limit only in production so local testing doesn't hit it.

---

### 17.10. Path Parameters (URL Params) vs Query Parameters

**Path parameters** are part of the URL path (e.g. `/api/courses/:id`). The server reads them as **`req.params`** (e.g. `req.params.id`).

**Query parameters** are after `?` (e.g. `?page=1&limit=10`). The server reads them as **`req.query`** (e.g. `req.query.page`).

**In Postman:**

| Type | Where to set | Example URL | Server gets |
|------|--------------|-------------|-------------|
| **Path params** | **Params** tab → **Path Variables** (or type in URL) | `{{base_url}}/api/courses/1` | `req.params.id` = `"1"` |
| **Query params** | **Params** tab → **Query Params** | `?page=1&limit=10` | `req.query.page`, `req.query.limit` |

**Path variables in Postman:**

1. URL: `http://localhost:3000/api/courses/:id`
2. In **Params** tab, under **Path Variables**, add: **Variable** `id`, **Value** `1`.
3. Postman will replace `:id` with `1` in the request.

**When to use which:**

- **Path:** Resource identity (e.g. get/update/delete course **by ID**). Example: GET `/api/courses/1`, PUT `/api/courses/1`.
- **Query:** Filtering, pagination, search (optional). Example: GET `/api/courses?page=1&limit=10&search=node`.

---

### 17.11. Accept Header and Response Format

**What it does:**  
The **Accept** header tells the server what format you want in the **response** (e.g. JSON vs HTML).

**Why set it:**  
Some servers return HTML for errors (404/500) by default. If you set **Accept: application/json**, the server may return JSON (e.g. `{ "message": "Not found" }`) instead, which is easier to read in Postman and in frontend code.

**When to set:**

- **Accept: application/json** — For REST APIs when you always want JSON responses.

**Postman steps:**

1. **Headers** tab.
2. Add: **Key** `Accept`, **Value** `application/json`.

**Server side:**  
Your Express API can check `req.headers.accept` and send `res.json(...)` for API routes. Many backends always respond with JSON for `/api/*` routes regardless of Accept, but setting Accept is good practice for consistency and for APIs that support multiple formats.

---

### 17.12. Cookie-Based Authentication

**Use when:** The API uses **cookies** for session/auth instead of (or in addition to) Bearer tokens. After login, the server sends **Set-Cookie**; the client sends **Cookie** on later requests.

**How it works:**

1. **Login:** POST to `/api/login` with credentials. Response includes header **Set-Cookie** (e.g. `sessionId=abc123; HttpOnly; Path=/`).
2. **Later requests:** Browser or Postman sends header **Cookie** with that value (e.g. `Cookie: sessionId=abc123`).
3. Server reads `req.cookies` (with `cookie-parser`) or `req.headers.cookie` and validates the session.

**In Postman:**

- Postman can **automatically store and send cookies** if you enable it.
- **Settings** → **General** → **Cookies** → **Manage Cookies** (or allow "Send cookies").
- After a request that returns **Set-Cookie**, Postman stores it and sends it on subsequent requests to the same domain.
- You can also set **Cookie** manually in **Headers**: **Key** `Cookie`, **Value** `sessionId=abc123`.

**Server side:**  
Use `cookie-parser` so that `req.cookies.sessionId` is available. For cookie + JWT, you might set an httpOnly cookie with the token and not use the Authorization header.

---

### 17.13. Pre-request Scripts and Tests Tab

**Pre-request Scripts** run **before** the request is sent. Use them to set variables (e.g. timestamp), or to **get a token** by calling login and saving it to the environment.

**Example: Auto-get token before a request**

Use on a **Collection** or on a **single request** that needs auth. This example runs a login request and saves the token:

```javascript
// Pre-request Script (run before request)
// Option A: Only get token if not set or expired (simplified: always get for demo)
const loginUrl = pm.environment.get("base_url") + "/api/login";
pm.sendRequest({
    url: loginUrl,
    method: "POST",
    header: { "Content-Type": "application/json" },
    body: {
        mode: "raw",
        raw: JSON.stringify({
            email: pm.environment.get("user_email"),
            password: pm.environment.get("user_password")
        })
    }
}, (err, res) => {
    if (!err && res.code === 200) {
        const json = res.json();
        if (json.token) {
            pm.environment.set("token", json.token);
        }
    }
});
```

**Environment variables needed:** `base_url`, `user_email`, `user_password`. After this runs, `{{token}}` is set for Bearer Token auth.

**Tests tab** runs **after** the response. Use it to assert status code and body so you can run the collection as a regression test.

**Example: Assert status and body**

```javascript
// Tests tab (run after response)
pm.test("Status is 200", () => pm.response.to.have.status(200));
pm.test("Response has body", () => {
    const json = pm.response.json();
    pm.expect(json).to.have.property("name");
});
```

**Useful assertions:**

- `pm.response.to.have.status(200);` — status code
- `pm.response.json()` — parsed JSON body
- `pm.expect(json.message).to.eql("Success");` — exact value
- `pm.expect(json.items).to.be.an("array");` — type

---

### 17.14. SSL Certificate Verification (Local / Dev)

**Use when:** You call **HTTPS** endpoints that use **self-signed** or invalid certificates (e.g. local server with HTTPS). Postman may show SSL errors and block the request.

**Fix (only for local/dev):**

1. **Settings** (gear icon) → **General**.
2. Turn **OFF** **"SSL certificate verification"**.

**Warning:** Do **not** disable this in production. Use it only for local or dev environments with self-signed certs.

---

### 17.15. PATCH vs PUT vs DELETE

**PUT** — Full replace. Client sends the **entire** resource; server replaces it.  
- Example: PUT `/api/courses/1` with full course object.  
- Body: full JSON.  
- Often returns **200 OK** with updated resource, or **204 No Content**.

**PATCH** — Partial update. Client sends **only changed fields**; server merges.  
- Example: PATCH `/api/courses/1` with `{ "price": 199 }`.  
- Body: partial JSON.  
- Returns **200 OK** with updated resource.

**DELETE** — Remove resource.  
- Example: DELETE `/api/courses/1`.  
- **Body:** usually **none**. Some APIs accept a body for bulk delete (e.g. `{ "ids": [1, 2, 3] }`); check API docs.  
- Returns **200 OK** with message, or **204 No Content** (no body).

**In Postman:**

- **PUT / PATCH:** Set **Content-Type: application/json**, **Body** → raw → JSON. For PATCH, send only the fields you want to update.
- **DELETE:** Usually leave Body as **none**. If API expects a body, use raw JSON.

---

### 17.16. Multiple Files Upload and Form-Data Details

**Multiple files in one request:**

- **Same field name:** Some backends expect multiple files under one name (e.g. `files`). In Postman **form-data**, add multiple rows with the **same key** `files` and type **File**, each with a different file. Server gets an array (e.g. `req.files` with multer).
- **Different field names:** Use different keys (e.g. `avatar`, `document`). Server gets `req.files.avatar`, `req.files.document` or similar depending on multer config.

**Form-data best practices:**

- **File field name** must match what the server expects (e.g. `file` or `image`). Check your multer `upload.single('file')` or `upload.array('files')`.
- **Other fields** (e.g. `title`, `userId`) go as **Text** in form-data; server reads them from `req.body` after multer.
- **Do not** set Content-Type manually for form-data; Postman adds `multipart/form-data` and the correct **boundary**.

**Large files:**  
If the server has a body size limit (e.g. `express.json({ limit: '10mb' })` or multer limits), requests may fail with 413 or timeout. Increase limit on server or reduce file size for testing.

---

### 17.17. Collection vs Environment Variables

| Scope | Where to set | When to use |
|-------|--------------|-------------|
| **Environment** | **Environments** → select env → **Edit** → Variables | Values that **change per environment**: `base_url` (local vs prod), `token`, `user_email`, `user_password`. Switch env to switch base URL and credentials. |
| **Collection** | **Collection** → **Variables** tab | Values **same for whole collection**: e.g. shared `api_version`, or default `base_url` if you only have one env. |

**Precedence:** Request-level variables override collection, which override environment. Use **`{{variable}}`** in URL, headers, or body.

**Tip:** Create environments like "Local", "Staging", "Production" with different `base_url` and (if needed) different credentials. Select the environment from the top-right dropdown before sending requests.

---

### 17.18. Troubleshooting: Common Mistakes and Fixes

| Problem | Likely cause | Fix |
|---------|----------------|-----|
| **"Name is required" or empty `req.body`** | No **Content-Type: application/json** or Body not **raw** + **JSON** | Set Header **Content-Type: application/json** and Body → **raw** → **JSON**. |
| **401 Unauthorized on protected route** | Token not sent or wrong | Set **Authorization** → **Bearer Token** and paste token (or use `{{token}}`). Ensure no extra space; value is token only, Postman adds "Bearer". |
| **404 on correct path** | Wrong method or typo in URL | Check method (GET/POST/PUT/DELETE) and URL (trailing slash can matter). Check **Params** so path/query are correct. |
| **Response is HTML instead of JSON** | Server returns HTML error page | Set **Accept: application/json**. Ensure your API route sends `res.json()` for errors. |
| **File upload: "Unexpected end of form" or empty `req.file`** | Wrong field name or body type | Use **form-data**; file key must match server (e.g. `upload.single('file')` → key `file`). Don't use raw JSON for file upload. |
| **CORS error in browser but Postman works** | CORS is browser-only | Postman doesn't enforce CORS. For browser, backend must set CORS headers (e.g. `cors()` middleware). |
| **SSL certificate error** | Self-signed or invalid cert (local/dev) | Settings → General → turn **OFF** "SSL certificate verification" (dev only). |
| **429 Too Many Requests** | Rate limit hit | Wait; check **Retry-After** header. For local testing, relax or disable rate limit. |
| **413 Payload Too Large** | Request body exceeds server limit | Increase limit on server (e.g. `express.json({ limit: '10mb' })`) or send smaller body. |
| **404 but URL looks correct** | Trailing slash or typo | `/api/courses` vs `/api/courses/` are different in Express. Match server URL exactly. |

**Checklist before sending:**

1. **Method** and **URL** correct?  
2. **Headers:** Content-Type (if body), Authorization (if protected), Accept (if you want JSON).  
3. **Body:** raw + JSON for JSON APIs; form-data for file upload.  
4. **Params:** Path variables and query params set if needed.  
5. **Environment** selected if you use `{{base_url}}` or `{{token}}`.

---

### 17.19. Response Time and Response Headers

**Response time:**  
After sending a request, Postman shows **response time** (e.g. `234 ms`) at the bottom of the response panel or in the status line. Use it to spot slow endpoints or compare before/after changes.

**Response headers:**  
In the **Response** tab, open **Headers** to see what the server sent. Useful for:

| Header | What it tells you |
|--------|--------------------|
| **Content-Type** | Response format (e.g. `application/json`). |
| **Set-Cookie** | Cookie-based auth; server is setting a cookie. |
| **Retry-After** | After 429; seconds to wait before retrying. |
| **Link** | Pagination (e.g. `rel="next"`, `rel="prev"`). |
| **X-Total-Count** | Total items (for paginated lists). |
| **Access-Control-*** | CORS headers (e.g. `Access-Control-Allow-Origin`). |

**Server side:**  
Your backend sets these with `res.setHeader()` or `res.set()`. Checking them in Postman helps verify CORS, cookies, and pagination.

---

### 17.20. Saving Token from Response (Tests Tab After Login)

**Use when:** You have a **Login** request and want to **save the token** from the response so other requests can use `{{token}}` without copy-paste.

**Steps:**

1. Open the **Login** request (e.g. POST `/api/login`).
2. Go to **Tests** tab.
3. Add a script that runs **after** the response and saves the token to the environment:

```javascript
// Tests tab on Login request (runs after response)
if (pm.response.code === 200) {
    const json = pm.response.json();
    if (json.token) {
        pm.environment.set("token", json.token);
        console.log("Token saved to environment.");
    }
}
```

4. Send the Login request once. The token is saved to `token` in the **current environment**.
5. In other requests, set **Authorization** → **Bearer Token** and use **`{{token}}`** as the token value.

**Tip:** Combine with Pre-request Script (17.13) if you want to auto-login before every request; or use this Tests script so you log in once and reuse the token until it expires.

---

### 17.21. URL and Method Details (Trailing Slash, GET Body, 413)

**Trailing slash:**  
Express treats `/api/courses` and `/api/courses/` as **different routes** unless you normalize them. In Postman, the URL must **exactly match** what your server defines. If you get 404, check for an extra or missing trailing slash.

**GET request and body:**  
**GET** requests **should not** have a body for practical use. Many servers, proxies, and caches ignore or reject a GET body. Use **query parameters** (Params tab) for filters and pagination. In Postman, leave **Body** as **none** for GET.

**413 Payload Too Large:**  
If the server rejects the request with **413**, the **request body is too large**. The server has a limit (e.g. `express.json({ limit: '10kb' })` or multer `limits`). Fix: increase the limit on the server (e.g. `express.json({ limit: '10mb' })`) or send a smaller body for testing.

**Content-Type charset (optional):**  
For non-ASCII characters (e.g. Unicode) in JSON, you can set **Content-Type: application/json; charset=utf-8**. Postman usually sends UTF-8 by default when you pick JSON. Only set charset explicitly if the server expects it or you see encoding issues.

---

### 17.22. PATCH and DELETE Scenarios (Summary)

**PATCH** — Partial update. Send **only the fields you want to change** in the body.  
- Method: **PATCH**  
- URL: `{{base_url}}/api/courses/1` (or use path variable)  
- Headers: **Content-Type: application/json**, **Authorization: Bearer {{token}}** if protected  
- Body: raw → JSON, e.g. `{ "price": 199 }`  

**DELETE** — Remove resource. Usually **no body**.  
- Method: **DELETE**  
- URL: `{{base_url}}/api/courses/1`  
- Body: **none** (or raw JSON only if API supports bulk delete body)  
- Authorization: Bearer Token if protected  

---

### 17.23. Collection Runner and Quick Tips

**Collection Runner:**  
Use **Run** on a **Collection** to execute all requests in sequence. Useful for:

- **Regression testing:** Run after code changes to ensure endpoints still work.
- **Order:** Put Login first so its Tests script saves the token; later requests use `{{token}}`.
- **Iterations:** Run multiple times (e.g. with a data file) for load or data-driven tests.

**Quick tips:**

- **Duplicate request:** Right-click a request → Duplicate to create a variant (e.g. same URL, different body).
- **Request-level variables:** In scripts you can use `pm.variables.set("name", value)` and `pm.variables.get("name")` for values that exist only for that request (e.g. timestamp). They don’t persist across requests unless you also set them in env/collection.
- **Bulk create:** POST with **Body** → raw → JSON array, e.g. `[{ "name": "A" }, { "name": "B" }]`. Content-Type remains **application/json**. Server must expect an array and create multiple resources (if your API supports it).
- **Idempotency:** **PUT** is idempotent (same request twice = same result). **POST** is not (each call can create a new resource). Use PUT for full replace, PATCH for partial update, POST for create.

---

## 18. Morgan

**Package:** `morgan`  
**Type:** External NPM Package  
**Purpose:** HTTP request logger middleware for Express. Logs each incoming request (method, URL, status, response time, etc.) to the console or to a stream (e.g. file).

---

### 18.1. What Morgan Does (HTTP Request Logger)

Morgan is **middleware** that runs on every request and writes a log line describing that request. It does **not** parse the body or modify the request; it only logs and calls `next()`.

**What gets logged (depends on format):**

- HTTP method (GET, POST, etc.)
- URL path
- Status code of the response
- Response time
- Content length
- User-Agent (optional)
- Date (optional)

**Why use it:**  
In development, you see each request in the terminal (e.g. `GET /api/courses 200 12.345 ms`). In production, you can stream logs to a file or log service for debugging and monitoring.

---

### 18.2. Installation and Basic Usage

**Installation:**
```bash
npm install morgan
```

**Basic usage (use before routes):**
```javascript
const express = require("express");
const morgan = require("morgan");

const app = express();

// Log all requests with "dev" format (colored, concise)
app.use(morgan("dev"));

app.get("/", (req, res) => {
  res.send("Hello, world!");
});

app.listen(3000);
```

**Output example (dev format):**
```
GET / 200 2.123 ms - 13
GET /api/courses 200 1.456 ms - 234
POST /api/courses 201 3.789 ms - 512
```

---

### 18.3. Predefined Formats (dev, combined, common, short, tiny)

Morgan provides several **predefined format strings**. You pass the format name as the first argument: `app.use(morgan("formatName"))`.

| Format    | Typical use   | What it logs |
|-----------|---------------|---------------|
| **dev**   | Development   | Colored output: `:method :url :status :response-time ms - :res[content-length]`. Concise, one line per request. |
| **combined** | Production (Apache-style) | Standard Apache combined log: `:remote-addr - :remote-user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent"`. |
| **common** | Production     | Apache common log format (no referrer/user-agent in same style). |
| **short** | Dev / staging  | Shorter than default: `:remote-addr :method :url :status :response-time - :res[content-length]`. |
| **tiny**  | Minimal        | Minimal: `:method :url :status :res[content-length] - :response-time ms`. |

**Examples:**
```javascript
// Development: colored, easy to read
app.use(morgan("dev"));

// Production: full Apache-style log (e.g. for nginx/load balancer parsing)
app.use(morgan("combined"));

// Minimal output
app.use(morgan("tiny"));
```

**Recommendation:** Use **`dev`** in development and **`combined`** (or **`common`**) in production if you write logs to a file or log aggregator.

---

### 18.4. Custom Format and Options

**Custom format string:**  
You can define your own format using **tokens** (e.g. `:method`, `:url`, `:status`, `:response-time`, `:res[content-length]`, `:date[clf]`).

```javascript
// Custom format
morgan(":method :url :status :response-time ms");
```

**Log to a file (stream):**  
By default Morgan writes to `process.stdout`. To write to a file, pass a **write stream** as the second argument:

```javascript
const fs = require("fs");
const path = require("path");

// Create a write stream for access log (append mode)
const accessLogStream = fs.createWriteStream(
  path.join(__dirname, "access.log"),
  { flags: "a" }
);

// Log to file in "combined" format
app.use(morgan("combined", { stream: accessLogStream }));

// Optional: also log to console in dev
if (process.env.NODE_ENV !== "production") {
  app.use(morgan("dev"));
}
```

**Skip logging for certain requests:**  
Use the **skip** option so health checks or static assets don’t clutter logs:

```javascript
app.use(
  morgan("dev", {
    skip: (req, res) => res.statusCode < 400, // Only log errors
  })
);

// Or skip static files
app.use(
  morgan("dev", {
    skip: (req) => req.url.startsWith("/static"),
  })
);
```

---

### 18.5. When to Use Morgan (Dev vs Production)

| Environment   | Suggestion |
|---------------|------------|
| **Development** | Use `morgan("dev")` so every request is visible in the terminal. Helps debug routes and see status/response time. |
| **Production**  | Use `morgan("combined")` or `morgan("common")` and send output to a **stream** (file or log service). Avoid logging sensitive data (e.g. full body); Morgan logs method, URL, status, etc., not the body by default. |
| **Conditional** | Only enable Morgan in development, or use different formats per environment. |

**Conditional usage example:**
```javascript
if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
} else {
  app.use(morgan("combined")); // or stream to file
}
```

---

### 18.6. Quick Reference

| Task              | Code |
|-------------------|------|
| Log all requests (dev) | `app.use(morgan("dev"));` |
| Production log format  | `app.use(morgan("combined"));` |
| Log to file            | `app.use(morgan("combined", { stream: accessLogStream }));` |
| Skip by status        | `app.use(morgan("dev", { skip: (req, res) => res.statusCode < 400 }));` |
| Custom format         | `app.use(morgan(":method :url :status :response-time ms"));` |

**Placement:** Use Morgan **early** in your middleware stack (e.g. after `express.json()` if you want, but before routes) so every request is logged.

---

## 19. Config (node-config)

**Package:** `config`  
**Type:** External NPM Package  
**Purpose:** Load application configuration from files in a `config/` folder, with different files per environment (development, production, etc.). Merges `default` + environment-specific + `local` so you can override per machine without changing code.

---

### 19.1. What Config Does (Configuration by Environment)

The **config** package (often called node-config) reads configuration from a **config/** directory. It loads **default** values first, then **environment-specific** values (based on `NODE_ENV`), then **local** overrides. You use `config.get('key')` in code instead of hardcoding or reading JSON yourself.

**What it gives you:**

- One place for app settings (port, DB name, feature flags, etc.).
- Different values per environment (dev, staging, production) without changing code.
- Optional **local** file (e.g. `local.json`) for machine-specific overrides, usually not committed.

**Why use it:**  
Keeps configuration out of code and makes it easy to switch environments by setting `NODE_ENV`. Complements **dotenv** (which is better for secrets like API keys and DB passwords).

---

### 19.2. Installation and Folder Structure

**Installation:**
```bash
npm install config
```

**Folder structure (by default config reads from `./config`):**
```
project/
├── config/
│   ├── default.json      # Base config (all environments)
│   ├── development.json  # Overrides when NODE_ENV=development
│   ├── production.json   # Overrides when NODE_ENV=production
│   ├── staging.json      # Overrides when NODE_ENV=staging (optional)
│   └── local.json       # Local overrides (optional, often in .gitignore)
├── app.js
└── package.json
```

**Example `config/default.json`:**
```json
{
  "name": "My App",
  "port": 3000,
  "db": {
    "host": "localhost",
    "port": 3306,
    "name": "myapp"
  },
  "featureFlags": {
    "newDashboard": false
  }
}
```

**Example `config/development.json`:**
```json
{
  "port": 3001,
  "db": {
    "name": "myapp_dev"
  },
  "featureFlags": {
    "newDashboard": true
  }
}
```

**Example `config/production.json`:**
```json
{
  "port": 8080,
  "db": {
    "host": "db.production.example.com"
  }
}
```

**Example `config/local.json` (optional, for your machine only):**
```json
{
  "port": 4000,
  "db": {
    "password": "from-dotenv-or-secret-manager"
  }
}
```

---

### 19.3. File Loading Order and NODE_ENV

**Loading order (later files override earlier):**

1. **default.json** (or default.js, default.yml) — base config.
2. **{NODE_ENV}.json** — e.g. `development.json`, `production.json`. Loaded only if `NODE_ENV` is set.
3. **local.json** — local overrides. Often in `.gitignore`.

So for `NODE_ENV=development`, config = default + development + local (deep merge).

**Setting NODE_ENV:**

- Shell: `export NODE_ENV=production`
- One-off: `NODE_ENV=production node app.js`
- In code (before requiring config): `process.env.NODE_ENV = 'production'; const config = require('config');`

**Config directory:**  
By default config looks for the **config/** folder in the current working directory. Override with environment variable **NODE_CONFIG_DIR** (absolute path).

---

### 19.4. Using config.get() and Nested Keys

**Basic usage:**
```javascript
const config = require('config');

// Top-level key
const appName = config.get('name');           // "My App"
const port = config.get('port');              // 3001 in dev, 8080 in prod

// Nested key (dot notation)
const dbHost = config.get('db.host');         // "localhost" or overridden
const dbName = config.get('db.name');        // "myapp_dev" in development

// Check if key exists
if (config.has('featureFlags.newDashboard')) {
  const enabled = config.get('featureFlags.newDashboard');
}

// Get entire section
const dbConfig = config.get('db');            // { host, port, name, ... }
```

**If a required key is missing**, `config.get('missing')` throws. Use **config.has('key')** to avoid throwing, or **config.get('key', defaultValue)** if your version supports it (or wrap in try/catch).

**Common pattern:**  
Use config for non-secret settings (port, hostnames, feature flags). Use **dotenv** for secrets (passwords, API keys) and reference them via `process.env`; you can also put `process.env` values in config files if the format supports it (e.g. in custom .js config).

---

### 19.5. Config vs Dotenv (When to Use Which)

| Use case | Prefer | Reason |
|----------|--------|--------|
| Port, app name, feature flags, DB hostname | **config** | Structured, per-environment, one place. |
| DB password, API keys, secrets | **dotenv** (or secret manager) | Keep out of config files in repo; use .env (in .gitignore) or env vars. |
| Simple app, few vars | **dotenv** only | No need for config folder. |
| Many settings, multiple environments | **config** + **dotenv** | config for structure and env overrides; dotenv for secrets loaded into `process.env`. |

**Together:**  
Call `require('dotenv').config()` first so `process.env` is set. Then `require('config')`. In config files you can reference env vars if you use **custom config files** (e.g. `config/default.js` that reads `process.env.DB_PASSWORD`). For JSON config files, keep secrets in .env and read them in code via `process.env`, not in config JSON.

#### custom-environment-variables.json: Explanation and Example

**What it is:**  
`custom-environment-variables.json` is a **special config file** recognized by the **config** package. It does **not** store values. It only maps **config key paths** to **environment variable names**. When you call `config.get('some.key')`, config checks this file; if `some.key` is mapped to an env var name (e.g. `"API_KEY"`), it returns `process.env.API_KEY` instead of a value from default.json or development.json.

**How the mapping works:**

| In custom-environment-variables.json | Meaning |
|---------------------------------------|--------|
| **Key** (e.g. `"db"` → `"password"`) | The **config path** you use in code: `config.get('db.password')`. |
| **Value** (e.g. `"DB_PASSWORD"`)     | The **name of the environment variable**. Config returns `process.env.DB_PASSWORD` when you call `config.get('db.password')`. |

So the **value** in the JSON is always the **name of the env var** (a string). Dotenv (or the system) puts the actual secret in `process.env.DB_PASSWORD`; config only says “for the key `db.password`, use `process.env.DB_PASSWORD`”.

**Loading order:**  
Config loads and merges files in this order: `default.json` → `development.json` (or other NODE_ENV) → `custom-environment-variables.json` (and others). The custom-environment-variables mapping is applied when you call `config.get()`. You must run **dotenv** before the first `require('config')` so that `process.env` is already populated from `.env`.

**If the env var is missing:**  
If `process.env.DB_PASSWORD` is undefined (e.g. not in .env and not set in the shell), `config.get('db.password')` typically returns `undefined`. Your code should check for that if the value is required. Some setups or validators may throw if a required key is missing; see the config package docs.

**Complete example:**

**1. .env** (project root; in .gitignore):
```env
NODE_ENV=development
DB_PASSWORD=secret123
DB_USER=appuser
API_KEY=sk_abc
```

**2. config/default.json** — only non-secret, non-env settings:
```json
{
  "name": "My App",
  "port": 3000,
  "db": {
    "host": "localhost",
    "port": 3306,
    "database": "myapp"
  }
}
```
Do **not** put `password` or `user` here if you use custom-environment-variables for them; the env mapping will supply those keys.

**3. config/custom-environment-variables.json** — map config paths to env var **names**:
```json
{
  "db": {
    "password": "DB_PASSWORD",
    "user": "DB_USER"
  },
  "api": {
    "key": "API_KEY"
  }
}
```

- `config.get('db.password')` → config reads `process.env.DB_PASSWORD` → e.g. `"secret123"`.
- `config.get('db.user')` → config reads `process.env.DB_USER` → e.g. `"appuser"`.
- `config.get('api.key')` → config reads `process.env.API_KEY` → e.g. `"sk_abc"`.
- `config.get('db.host')` → not in this file, so config uses **default.json** → `"localhost"`.

**4. app.js** — load dotenv first, then config; use config for everything:
```javascript
// 1. Load .env into process.env BEFORE config is required
require('dotenv').config();

// 2. Config will use custom-environment-variables to read from process.env
const config = require('config');

const port = config.get('port');                    // from default.json: 3000
const dbHost = config.get('db.host');               // from default.json: "localhost"
const dbPassword = config.get('db.password');       // from process.env.DB_PASSWORD
const dbUser = config.get('db.user');               // from process.env.DB_USER
const apiKey = config.get('api.key');               // from process.env.API_KEY

// One API for all settings (structure from JSON, secrets from env)
const pool = require('mysql2/promise').createPool({
  host: config.get('db.host'),
  port: config.get('db.port'),
  user: config.get('db.user'),
  password: config.get('db.password'),
  database: config.get('db.database'),
});
```

**Summary:**  
Put the **name** of each env var in `custom-environment-variables.json` (as the string value). Load dotenv first so `process.env` has the values. Then `config.get('key')` gives you either a value from default/development JSON or, for mapped keys, the value from the corresponding environment variable.

---

#### 19.5.1. Config with Dotenv: Complete Examples

**Example 1: Dotenv first, then config; use config for settings, process.env for secrets**

Load dotenv **before** requiring config so that `process.env` is available. Use **config** for non-secret settings and **process.env** for secrets in your application code.

**.env** (in project root; add to .gitignore):
```env
NODE_ENV=development
DB_PASSWORD=mySecretPassword123
API_KEY=sk_live_abc123
JWT_SECRET=yourJwtSecretKey
```

**config/default.json** (no secrets; safe to commit):
```json
{
  "name": "My App",
  "port": 3000,
  "db": {
    "host": "localhost",
    "port": 3306,
    "database": "myapp",
    "user": "root"
  },
  "api": {
    "timeout": 5000
  }
}
```

**config/development.json** (overrides for development):
```json
{
  "port": 3001,
  "db": {
    "database": "myapp_dev"
  }
}
```

**app.js** (or server.js):
```javascript
// 1. Load dotenv FIRST so process.env is set before anything else
require('dotenv').config();

// 2. Then load config (can use NODE_ENV from .env now)
const config = require('config');
const express = require('express');

const app = express();
const PORT = config.get('port');

// 3. Use config for non-secret settings
const dbHost = config.get('db.host');
const dbPort = config.get('db.port');
const dbName = config.get('db.database');
const dbUser = config.get('db.user');

// 4. Use process.env for secrets (from .env)
const dbPassword = process.env.DB_PASSWORD;
const apiKey = process.env.API_KEY;
const jwtSecret = process.env.JWT_SECRET;

// Example: create DB connection using config + env
async function getDbConnection() {
  const mysql = require('mysql2/promise');
  return mysql.createPool({
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPassword,  // from dotenv, never in config JSON
    database: dbName,
  });
}

app.listen(PORT, () => {
  console.log(`${config.get('name')} running on port ${PORT}`);
});
```

---

**Example 2: Config “custom-environment-variables” — map config keys to env vars**

The **config** package can read certain keys from environment variables using a file named **custom-environment-variables.json**. You still load dotenv first; then `config.get('db.password')` will return `process.env.DB_PASSWORD`.

**config/custom-environment-variables.json**:
```json
{
  "db": {
    "password": "DB_PASSWORD",
    "user": "DB_USER"
  },
  "api": {
    "key": "API_KEY"
  },
  "jwt": {
    "secret": "JWT_SECRET"
  }
}
```

Each value is the **name of the environment variable** (dotenv loads these from .env into `process.env`). Config will call `process.env.DB_PASSWORD` when you `config.get('db.password')`.

**.env** (unchanged):
```env
NODE_ENV=development
DB_PASSWORD=mySecretPassword123
DB_USER=root
API_KEY=sk_live_abc123
JWT_SECRET=yourJwtSecretKey
```

**config/default.json** (omit secrets; they come from env via custom-environment-variables):
```json
{
  "name": "My App",
  "port": 3000,
  "db": {
    "host": "localhost",
    "port": 3306,
    "database": "myapp"
  }
}
```

**app.js** — one place for all config:
```javascript
// 1. Dotenv first
require('dotenv').config();

// 2. Config (reads custom-environment-variables → process.env)
const config = require('config');

const port = config.get('port');
const dbPassword = config.get('db.password');   // from process.env.DB_PASSWORD
const dbUser = config.get('db.user');           // from process.env.DB_USER
const apiKey = config.get('api.key');           // from process.env.API_KEY
const jwtSecret = config.get('jwt.secret');     // from process.env.JWT_SECRET

// All settings (including secrets) via config.get()
const pool = require('mysql2/promise').createPool({
  host: config.get('db.host'),
  port: config.get('db.port'),
  user: config.get('db.user'),
  password: config.get('db.password'),
  database: config.get('db.database'),
});
```

---

**Example 3: Config with dotenv using a .js config file**

If you use **config/default.js** (instead of default.json), you can read `process.env` inside the file. Load dotenv **before** the first `require('config')` so `process.env` is already set.

**config/default.js**:
```javascript
// Dotenv must already have been run (e.g. in app.js: require('dotenv').config() first)
module.exports = {
  name: 'My App',
  port: process.env.PORT || 3000,
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    database: process.env.DB_NAME || 'myapp',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,  // from .env; no default
  },
  jwt: {
    secret: process.env.JWT_SECRET,
  },
};
```

**app.js**:
```javascript
require('dotenv').config();  // Must be first
const config = require('config');

const port = config.get('port');
const dbConfig = config.get('db');  // includes password from process.env
```

**Summary of the three approaches:**

| Approach | Use when |
|---------|----------|
| **Example 1** (config for structure, process.env for secrets in code) | You want a clear split: config = non-secret, secrets only in process.env. |
| **Example 2** (custom-environment-variables.json) | You want a single API: everything via config.get(); secrets still live in .env. |
| **Example 3** (default.js with process.env) | You want full control in JS (defaults, parsing, validation) and one config file that uses env. |

---

### 19.6. Quick Reference

| Task | Code |
|------|------|
| Load config | `const config = require('config');` |
| Get value | `config.get('port')` or `config.get('db.host')` |
| Check key | `config.has('featureFlags.newDashboard')` |
| Current env | `config.util.getEnv('NODE_ENV')` (after require) |
| Override config dir | Set env **NODE_CONFIG_DIR** to absolute path |

**File formats:**  
Config supports **.json**, **.js**, **.yml**, **.yaml**, **.xml**, etc. Same base name with different extension (e.g. default.json vs default.js); see package docs for precedence.

**Placement:**  
Require config **once** at app startup (e.g. top of server.js or in a small config loader). Use `config.get()` wherever you need a setting (e.g. port, DB host). Keep **config/** at project root (or path given by NODE_CONFIG_DIR).

---

## 20. Debug

**Package:** `debug`  
**Type:** External NPM Package  
**Purpose:** A small debugging utility that uses the **DEBUG** environment variable to turn logging on or off by **namespace**. You can enable only certain parts of your app (e.g. `myapp:db`, `myapp:api`) instead of leaving `console.log` everywhere or seeing everything at once.

---

### 20.1. What Debug Does (Namespace-Based Logging)

**debug** gives you a logger function tied to a **namespace** (e.g. `myapp:db`). Logs are written only when that namespace is enabled via the **DEBUG** environment variable. By default (when DEBUG is not set), nothing is printed.

**What you get:**

- **Namespaces** — Group logs by module or area (e.g. `myapp:db`, `myapp:auth`).
- **Toggle by env** — Enable/disable without code changes: `DEBUG=myapp:* node app.js`.
- **No removal** — Leave `debug('...')` calls in code; they are no-ops when DEBUG is off.

**Why use it:**  
In development you can turn on only the namespaces you need (e.g. DB or auth). In production you typically don’t set DEBUG, so no debug output. Avoids scattering and removing `console.log` and gives a single switch (DEBUG) for all debug logging.

---

### 20.2. Installation and Basic Usage

**Installation:**
```bash
npm install debug
```

**Basic usage:**
```javascript
const debug = require('debug')('myapp:server');

debug('Server starting on port %d', 3000);
// When DEBUG=myapp:server (or myapp:* or *) is set, prints something like:
//   myapp:server Server starting on port 3000
```

**Creating a logger:**  
Call `require('debug')('namespace')` once per file or module. The string is the **namespace** (e.g. `myapp`, `myapp:db`, `myapp:auth`). Use colons to group (e.g. `myapp:db:query`).

**Example with multiple namespaces:**
```javascript
// server.js
const debug = require('debug')('myapp:server');
debug('Listening on port %s', 3000);

// db.js
const debug = require('debug')('myapp:db');
debug('Connecting to database');
debug('Query result: %o', { id: 1, name: 'test' });

// auth.js
const debug = require('debug')('myapp:auth');
debug('Checking token');
```

**Run with:**  
`DEBUG=myapp:* node server.js` — all `myapp:*` logs appear.  
`DEBUG=myapp:db node server.js` — only `myapp:db` logs appear.

---

### 20.3. DEBUG Environment Variable and Namespaces

**How DEBUG works:**  
DEBUG is a list of **patterns** (namespaces or wildcards). If the pattern matches a logger’s namespace, that logger outputs; otherwise it does nothing.

| DEBUG value | Effect |
|-------------|--------|
| (not set or empty) | No debug output. |
| `*` | Enable all namespaces. |
| `myapp:*` | Enable all namespaces that start with `myapp:` (e.g. `myapp:server`, `myapp:db`). |
| `myapp:db` | Enable only `myapp:db`. |
| `myapp:db,myapp:auth` | Enable `myapp:db` and `myapp:auth` (comma-separated). |
| `*,-myapp:noise` | Enable all except namespaces matching `myapp:noise` (minus = exclude). |

**Namespace naming:**  
Use a prefix (e.g. app name) plus a colon and area: `appname:module` or `appname:module:sub`. Many packages use their own namespaces (e.g. `express:router`). Enabling `*` or `express:*` shows their debug output too.

---

### 20.4. Enabling and Disabling (Unix, CMD, PowerShell)

**Linux / macOS (and Windows with Bash-style shells):**
```bash
DEBUG=myapp:* node app.js
DEBUG=* node app.js
DEBUG=myapp:db,myapp:auth node app.js
```

**Windows CMD:**
```cmd
set DEBUG=myapp:* && node app.js
```

**Windows PowerShell:**
```powershell
$env:DEBUG='myapp:*'; node app.js
```

**In .env (with dotenv):**  
You can put `DEBUG=myapp:*` in `.env` and run `require('dotenv').config()` before any `require('debug')`. Then `node app.js` will use that value. Useful for local development; keep DEBUG unset in production.

**Scope:**  
Setting DEBUG like this applies only to that process. It does not change your shell’s environment after the process exits.

---

### 20.5. When to Use Debug vs console.log vs Morgan

| Tool | Use when |
|------|----------|
| **debug** | Development; you want to toggle logs by namespace (db, auth, etc.) without editing code. Leave calls in place; they are off when DEBUG is unset. |
| **console.log** | Quick one-off logs; always on unless you remove or guard them. No namespaces or env switch. |
| **morgan** | HTTP request logging only (method, URL, status, time). Not for general app debugging. |

**Typical combo:**  
Use **morgan** for request logs and **debug** for application-level debugging (DB, auth, business logic). Use **console.log** sparingly or for errors (e.g. `console.error`).

---

### 20.6. Quick Reference

| Task | Code |
|------|------|
| Create logger | `const debug = require('debug')('myapp:server');` |
| Log message | `debug('message');` or `debug('format %s', value);` |
| Log object | `debug('data: %o', obj);` |
| Enable all | `DEBUG=* node app.js` |
| Enable namespace | `DEBUG=myapp:* node app.js` |
| Enable multiple | `DEBUG=myapp:db,myapp:auth node app.js` |
| Exclude namespace | `DEBUG=*,-myapp:noise node app.js` |

**Format specifiers:**  
Like `console.log`: `%s` string, `%d` number, `%o` object, `%j` JSON. Use them for cleaner output and to avoid stringifying large objects by hand.

**Placement:**  
Require and create the logger at the top of each file that needs it. Call `debug('...')` wherever you want conditional debug output. No need to remove calls for production; just don’t set DEBUG.

---

## Summary

| Package | Type | Purpose | Installation |
|---------|------|---------|--------------|
| express | External | Web framework | `npm install express` |
| mysql2 | External | Database client | `npm install mysql2` |
| dotenv | External | Environment variables | `npm install dotenv` |
| cors | External | Cross-origin requests | `npm install cors` |
| multer | External | File uploads | `npm install multer` |
| path | Built-in | Path utilities | No installation needed |
| fs | Built-in | File system | No installation needed |
| os | Built-in | Operating system utilities | No installation needed |
| http | Built-in | HTTP server and client | No installation needed |
| express-rate-limit | External | Rate limiting | `npm install express-rate-limit` |
| morgan | External | HTTP request logging | `npm install morgan` |
| config | External | Configuration by environment (config/ folder) | `npm install config` |
| debug | External | Namespace-based debug logging (DEBUG env var) | `npm install debug` |
| express.json() | Built-in (Express 4.16.0+) | JSON body parsing | No installation needed |
| express.urlencoded() | Built-in (Express 4.16.0+) | Form data parsing | No installation needed |
| body-parser | External (Deprecated) | Body parsing | Not recommended |

---

## Best Practices

1. **Environment Variables:** Always use `dotenv` for sensitive configuration
2. **Security:** Implement rate limiting for public APIs
3. **File Uploads:** Validate file types and sizes when using multer
4. **CORS:** Configure CORS properly for production (don't allow all origins)
5. **Database:** Use connection pooling and prepared statements with mysql2
6. **Error Handling:** Always handle errors in async database operations
7. **Logging:** Use morgan (or similar) for HTTP request logging in development; in production, stream logs to a file or log service
8. **Configuration:** Use dotenv for secrets (API keys, passwords); use the config package for structured, environment-specific settings (port, hostnames, feature flags) when you have multiple environments
9. **Debugging:** Use the debug package with namespaces (e.g. `myapp:db`, `myapp:auth`) for development; leave DEBUG unset in production so debug output is off

---

---

## Server.js Code Structure

Here's how the libraries are used in `server.js`:

### Package Imports
```javascript
const express = require("express");
const mysql = require("mysql2/promise");
const dotenv = require("dotenv");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const rateLimit = require("express-rate-limit");
```

### Initialization
```javascript
// Load environment variables from .env file
dotenv.config();

// Create Express application instance
const app = express();
const PORT = process.env.PORT || 3000;
```

### Directory Setup
```javascript
// Create uploads directory if it doesn't exist
// Uses fs.existsSync() to check and fs.mkdirSync() to create directory
const uploadDir = "./uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
```

### Middleware Configuration
```javascript
// CORS - Enable Cross-Origin Resource Sharing
// Allows requests from different origins/domains
app.use(cors());

// express.json() - Parses incoming JSON request bodies and makes them available in req.body
// This is the built-in Express version of bodyParser.json() (no need to install body-parser)
// Intercepts requests with Content-Type: application/json header
// Converts JSON strings to JavaScript objects and attaches to req.body
app.use(express.json());

// express.urlencoded() - Parses incoming URL-encoded form data (application/x-www-form-urlencoded)
// This is the built-in Express version of bodyParser.urlencoded()
// Handles form submissions and URL-encoded data
// extended: true allows parsing of rich objects and arrays
app.use(express.urlencoded({ extended: true }));

// Serve static files from uploads directory
app.use('./uploads', express.static('upload'));
```

### Key Points
- **Middleware Order Matters:** Middleware is executed in the order it's defined
- **express.json()** must be placed before routes that need to access JSON data in `req.body`
- **express.urlencoded()** handles traditional HTML form submissions
- **CORS** should be configured early in the middleware chain
- **dotenv.config()** must be called before accessing `process.env` variables

---

## Additional Resources

- [Express Documentation](https://expressjs.com/)
- [MySQL2 Documentation](https://github.com/sidorares/node-mysql2)
- [Dotenv Documentation](https://github.com/motdotla/dotenv)
- [CORS Documentation](https://github.com/expressjs/cors)
- [Multer Documentation](https://github.com/expressjs/multer)
- [Node.js Path Module](https://nodejs.org/api/path.html)
- [Node.js FS Module](https://nodejs.org/api/fs.html)
- [Express Rate Limit](https://github.com/express-rate-limit/express-rate-limit)

