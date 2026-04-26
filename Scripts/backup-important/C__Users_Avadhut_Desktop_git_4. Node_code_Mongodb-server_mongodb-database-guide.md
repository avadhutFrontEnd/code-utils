# MongoDB Database Creation and Management Guide

## How MongoDB Creates Databases

**Important:** In MongoDB, databases are created **automatically** when you first write data to them. There's no explicit `CREATE DATABASE` command like in SQL databases.

### How It Works:

1. **Automatic Creation**: When you connect to a database that doesn't exist and insert your first document, MongoDB automatically creates the database and collection.

2. **Example**:
   ```javascript
   // Connect to a non-existent database
   await mongoose.connect('mongodb://localhost:27017/my_new_database');
   
   // Insert a document - this creates both the database and collection
   const user = new User({ name: 'John', email: 'john@example.com' });
   await user.save(); // Database 'my_new_database' is now created!
   ```

## Methods to Create a Database

### Method 1: Using Mongoose (Recommended for Node.js)

```javascript
const mongoose = require('mongoose');

// Connect to the database (it will be created when you insert data)
await mongoose.connect('mongodb://localhost:27017/new_database_name');

// Create a model and save a document
const User = mongoose.model('User', userSchema);
const user = new User({ name: 'Test', email: 'test@example.com' });
await user.save(); // Database is now created!
```

### Method 2: Using MongoDB Shell

```bash
# Connect to MongoDB shell
mongosh

# Switch to or create a database
use my_new_database

# Insert a document to actually create the database
db.users.insertOne({ name: "John", email: "john@example.com" })
```

### Method 3: Using MongoDB Native Driver

```javascript
const { MongoClient } = require('mongodb');

const client = new MongoClient('mongodb://localhost:27017');
await client.connect();

const db = client.db('new_database_name');
const collection = db.collection('users');

// Insert a document - this creates the database
await collection.insertOne({ name: 'John', email: 'john@example.com' });
```

## How to Check if a Database Exists

### Method 1: Using MongoDB Shell

```bash
# Connect to MongoDB shell
mongosh

# List all databases
show dbs

# Or use the command
show databases

# Check if a specific database exists
use my_database
# If the database doesn't exist, MongoDB will still switch to it,
# but it won't be created until you insert data
```

### Method 2: Programmatically with Mongoose (Node.js)

The code in `index.js` includes utility functions:

```javascript
// List all databases
const databases = await listDatabases();
console.log(databases);
// Output: [{ name: 'admin', sizeOnDisk: 32768, empty: false }, ...]

// Check if a specific database exists
const exists = await databaseExists('my_database');
console.log(exists); // true or false

// Get current database name
const currentDb = getCurrentDatabase();
console.log(currentDb); // 'myapp_db'

// Get database statistics
const stats = await getDatabaseStats('my_database');
console.log(stats);
```

### Method 3: Using API Endpoints (Included in index.js)

```bash
# List all databases
GET http://localhost:3000/api/databases

# Check if a database exists
GET http://localhost:3000/api/databases/my_database/exists

# Get current database info
GET http://localhost:3000/api/database/current

# Get database statistics
GET http://localhost:3000/api/databases/my_database/stats
```

## Complete Example: Creating and Checking a Database

```javascript
const mongoose = require('mongoose');

async function createAndCheckDatabase() {
  try {
    // Step 1: Connect to MongoDB (not to a specific database yet)
    await mongoose.connect('mongodb://localhost:27017');
    
    // Step 2: List existing databases
    const adminDb = mongoose.connection.db.admin();
    const result = await adminDb.listDatabases();
    console.log('Existing databases:', result.databases.map(db => db.name));
    
    // Step 3: Check if our target database exists
    const targetDbName = 'my_new_database';
    const exists = result.databases.some(db => db.name === targetDbName);
    console.log(`Database '${targetDbName}' exists:`, exists);
    
    // Step 4: Connect to the target database (or create it)
    await mongoose.connect(`mongodb://localhost:27017/${targetDbName}`);
    
    // Step 5: Create a schema and model
    const userSchema = new mongoose.Schema({
      name: String,
      email: String
    });
    const User = mongoose.model('User', userSchema);
    
    // Step 6: Insert a document (this creates the database if it doesn't exist)
    const user = new User({ name: 'John Doe', email: 'john@example.com' });
    await user.save();
    console.log('Database created and document inserted!');
    
    // Step 7: Verify the database now exists
    const adminDb2 = mongoose.connection.db.admin();
    const result2 = await adminDb2.listDatabases();
    const nowExists = result2.databases.some(db => db.name === targetDbName);
    console.log(`Database '${targetDbName}' now exists:`, nowExists);
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await mongoose.connection.close();
  }
}

createAndCheckDatabase();
```

## Important Notes

1. **Empty Databases**: MongoDB doesn't show empty databases in `show dbs`. A database must have at least one document to appear in the list.

2. **Database Names**:
   - Must be valid UTF-8 strings
   - Cannot contain: `/`, `\`, `.`, `"`, `*`, `<`, `>`, `:`, `|`, `?`, `$`, ` ` (space), or null character
   - Case-sensitive
   - Maximum length: 64 bytes

3. **Collections**: Like databases, collections are also created automatically when you insert the first document.

4. **Connection String**: The database name in the connection string determines which database you're using:
   ```javascript
   // Uses 'myapp_db' database
   mongoose.connect('mongodb://localhost:27017/myapp_db');
   
   // Uses 'test' database (default)
   mongoose.connect('mongodb://localhost:27017');
   ```

## Common Commands Reference

### MongoDB Shell Commands:
```bash
show dbs                    # List all databases
use database_name          # Switch to a database
db                         # Show current database
db.getName()              # Get current database name
db.stats()                # Get database statistics
db.dropDatabase()        # Delete current database
```

### Mongoose/Node.js Commands:
```javascript
mongoose.connection.db.databaseName        // Get current database name
mongoose.connection.db.admin()             // Access admin database
mongoose.connection.db.admin().listDatabases()  // List all databases
mongoose.connection.db.stats()            // Get current database stats
mongoose.connection.db.dropDatabase()     // Drop current database
```

## Testing the API Endpoints

After starting your server, you can test the database management endpoints:

```bash
# List all databases
curl http://localhost:3000/api/databases

# Check if 'myapp_db' exists
curl http://localhost:3000/api/databases/myapp_db/exists

# Get current database info
curl http://localhost:3000/api/database/current

# Get stats for a specific database
curl http://localhost:3000/api/databases/myapp_db/stats
```

## Summary

- **Creating a database**: Just connect to it and insert data - MongoDB creates it automatically
- **Checking existence**: Use `listDatabases()` and check if the name exists in the list
- **No explicit CREATE command**: Unlike SQL, MongoDB doesn't require explicit database creation
- **Empty databases**: Don't appear in `show dbs` until they contain data

