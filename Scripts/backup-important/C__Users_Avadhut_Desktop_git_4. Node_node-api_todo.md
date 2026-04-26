# Todo App Backend API - Node.js + Express + MySQL

## Project Structure
```
todo-api/
├── src/
│   ├── config/
│   │   └── database.js
│   ├── controllers/
│   │   └── todoController.js
│   ├── routes/
│   │   └── todoRoutes.js
│   ├── models/
│   │   └── todoModel.js
│   └── app.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

## Installation Steps

### 1. Initialize the project
```bash
mkdir todo-api
cd todo-api
npm init -y
```

### 2. Install dependencies
```bash
npm install express mysql2 dotenv cors body-parser
npm install --save-dev nodemon
```

### 3. Create MySQL Database
```sql
CREATE DATABASE todo_db;

USE todo_db;

CREATE TABLE todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in-progress', 'completed') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Project Files

### package.json
```json
{
  "name": "todo-api",
  "version": "1.0.0",
  "description": "Todo API with Node.js, Express and MySQL",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": ["todo", "api", "express", "mysql"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

### .env
```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=todo_db
DB_PORT=3306
```

### .gitignore
```
node_modules/
.env
*.log
```

### server.js
```javascript
require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
```

### src/app.js
```javascript
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const todoRoutes = require('./routes/todoRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/todos', todoRoutes);

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Todo API is running' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

module.exports = app;
```

### src/config/database.js
```javascript
const mysql = require('mysql2');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const promisePool = pool.promise();

module.exports = promisePool;
```

### src/models/todoModel.js
```javascript
const db = require('../config/database');

class Todo {
  static async findAll() {
    const [rows] = await db.query('SELECT * FROM todos ORDER BY created_at DESC');
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.query('SELECT * FROM todos WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(todoData) {
    const { title, description, status, priority } = todoData;
    const [result] = await db.query(
      'INSERT INTO todos (title, description, status, priority) VALUES (?, ?, ?, ?)',
      [title, description, status || 'pending', priority || 'medium']
    );
    return result.insertId;
  }

  static async update(id, todoData) {
    const { title, description, status, priority } = todoData;
    const [result] = await db.query(
      'UPDATE todos SET title = ?, description = ?, status = ?, priority = ? WHERE id = ?',
      [title, description, status, priority, id]
    );
    return result.affectedRows;
  }

  static async delete(id) {
    const [result] = await db.query('DELETE FROM todos WHERE id = ?', [id]);
    return result.affectedRows;
  }

  static async findByStatus(status) {
    const [rows] = await db.query('SELECT * FROM todos WHERE status = ? ORDER BY created_at DESC', [status]);
    return rows;
  }
}

module.exports = Todo;
```

### src/controllers/todoController.js
```javascript
const Todo = require('../models/todoModel');

exports.getAllTodos = async (req, res) => {
  try {
    const todos = await Todo.findAll();
    res.json({ success: true, data: todos });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getTodoById = async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);
    if (!todo) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }
    res.json({ success: true, data: todo });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.createTodo = async (req, res) => {
  try {
    const { title, description, status, priority } = req.body;
    
    if (!title) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }

    const todoId = await Todo.create({ title, description, status, priority });
    const todo = await Todo.findById(todoId);
    
    res.status(201).json({ success: true, data: todo });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.updateTodo = async (req, res) => {
  try {
    const { title, description, status, priority } = req.body;
    
    if (!title) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }

    const affectedRows = await Todo.update(req.params.id, { title, description, status, priority });
    
    if (affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }

    const todo = await Todo.findById(req.params.id);
    res.json({ success: true, data: todo });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.deleteTodo = async (req, res) => {
  try {
    const affectedRows = await Todo.delete(req.params.id);
    
    if (affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }

    res.json({ success: true, message: 'Todo deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getTodosByStatus = async (req, res) => {
  try {
    const { status } = req.params;
    const validStatuses = ['pending', 'in-progress', 'completed'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, error: 'Invalid status' });
    }

    const todos = await Todo.findByStatus(status);
    res.json({ success: true, data: todos });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

### src/routes/todoRoutes.js
```javascript
const express = require('express');
const router = express.Router();
const todoController = require('../controllers/todoController');

// Get all todos
router.get('/', todoController.getAllTodos);

// Get todos by status
router.get('/status/:status', todoController.getTodosByStatus);

// Get single todo by ID
router.get('/:id', todoController.getTodoById);

// Create new todo
router.post('/', todoController.createTodo);

// Update todo
router.put('/:id', todoController.updateTodo);

// Delete todo
router.delete('/:id', todoController.deleteTodo);

module.exports = router;
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/todos` | Get all todos |
| GET | `/api/todos/:id` | Get todo by ID |
| GET | `/api/todos/status/:status` | Get todos by status |
| POST | `/api/todos` | Create new todo |
| PUT | `/api/todos/:id` | Update todo |
| DELETE | `/api/todos/:id` | Delete todo |
| GET | `/health` | Health check |

## Sample API Requests

### Create Todo
```bash
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project",
    "description": "Finish the todo API project",
    "status": "inProgress",
    "priority": "high"
  }'
```

### Get All Todos
```bash
curl http://localhost:3000/api/todos
```

### Update Todo
```bash
curl -X PUT http://localhost:3000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project",
    "description": "Finish the todo API project",
    "status": "completed",
    "priority": "high"
  }'
```

### Delete Todo
```bash
curl -X DELETE http://localhost:3000/api/todos/1
```

## Running the Project

1. Update the `.env` file with your MySQL credentials
2. Create the database using the SQL commands provided
3. Run the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`