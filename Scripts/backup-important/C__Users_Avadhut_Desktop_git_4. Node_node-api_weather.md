# Weather App Backend API - Node.js + Express + MySQL

## Project Structure
```
weather-api/
├── src/
│   ├── config/
│   │   └── database.js 
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── weatherController.js
│   │   └── favoriteController.js
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── weatherRoutes.js
│   │   └── favoriteRoutes.js
│   ├── models/
│   │   ├── userModel.js
│   │   └── favoriteModel.js
│   ├── middleware/
│   │   └── authMiddleware.js
│   ├── services/
│   │   └── weatherService.js
│   └── app.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

## Installation Steps

### 1. Initialize the project
```bash
mkdir weather-api
cd weather-api
npm init -y
```

### 2. Install dependencies
```bash
npm install express mysql2 dotenv cors body-parser bcryptjs jsonwebtoken axios
npm install --save-dev nodemon
```

### 3. Create MySQL Database
```sql
CREATE DATABASE weather_app_db;

USE weather_app_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE favorite_cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    country VARCHAR(100),
    lat DECIMAL(10, 7),
    lon DECIMAL(10, 7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_city (user_id, city_name)
);

CREATE INDEX idx_user_id ON favorite_cities(user_id);
```

## Project Files

### package.json
```json
{
  "name": "weather-api",
  "version": "1.0.0",
  "description": "Weather API with Authentication and Favorites",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": ["weather", "api", "express", "mysql", "authentication"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "axios": "^1.5.0"
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
DB_NAME=weather_app_db
DB_PORT=3306

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d

# OpenWeatherMap API Key (Get free key from https://openweathermap.org/api)
WEATHER_API_KEY=your_openweathermap_api_key
WEATHER_API_URL=https://api.openweathermap.org/data/2.5
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
  console.log(`Weather API Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
```

### src/app.js
```javascript
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/authRoutes');
const weatherRoutes = require('./routes/weatherRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/favorites', favoriteRoutes);

// Health check route
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Weather API is running',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    success: false, 
    error: 'Something went wrong!',
    message: err.message 
  });
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

// Test connection
promisePool.query('SELECT 1')
  .then(() => console.log('Database connected successfully'))
  .catch(err => console.error('Database connection failed:', err));

module.exports = promisePool;
```

### src/models/userModel.js
```javascript
const db = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create(userData) {
    const { username, email, password } = userData;
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const [result] = await db.query(
      'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
      [username, email, hashedPassword]
    );
    return result.insertId;
  }

  static async findByEmail(email) {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0];
  }

  static async findByUsername(username) {
    const [rows] = await db.query('SELECT * FROM users WHERE username = ?', [username]);
    return rows[0];
  }

  static async findById(id) {
    const [rows] = await db.query('SELECT id, username, email, created_at FROM users WHERE id = ?', [id]);
    return rows[0];
  }

  static async comparePassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }
}

module.exports = User;
```

### src/models/favoriteModel.js
```javascript
const db = require('../config/database');

class Favorite {
  static async create(favoriteData) {
    const { user_id, city_name, country, lat, lon } = favoriteData;
    
    try {
      const [result] = await db.query(
        'INSERT INTO favorite_cities (user_id, city_name, country, lat, lon) VALUES (?, ?, ?, ?, ?)',
        [user_id, city_name, country, lat, lon]
      );
      return result.insertId;
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new Error('City already in favorites');
      }
      throw error;
    }
  }

  static async findByUserId(userId) {
    const [rows] = await db.query(
      'SELECT * FROM favorite_cities WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );
    return rows;
  }

  static async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM favorite_cities WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return rows[0];
  }

  static async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM favorite_cities WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows;
  }

  static async deleteByCity(cityName, userId) {
    const [result] = await db.query(
      'DELETE FROM favorite_cities WHERE city_name = ? AND user_id = ?',
      [cityName, userId]
    );
    return result.affectedRows;
  }
}

module.exports = Favorite;
```

### src/middleware/authMiddleware.js
```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const authMiddleware = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        success: false, 
        error: 'No token provided. Authorization denied.' 
      });
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        error: 'User not found. Authorization denied.' 
      });
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid token. Authorization denied.' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false, 
        error: 'Token expired. Please login again.' 
      });
    }
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = authMiddleware;
```

### src/services/weatherService.js
```javascript
const axios = require('axios');

class WeatherService {
  constructor() {
    this.apiKey = process.env.WEATHER_API_KEY;
    this.apiUrl = process.env.WEATHER_API_URL;
  }

  async getCurrentWeather(city) {
    try {
      const response = await axios.get(`${this.apiUrl}/weather`, {
        params: {
          q: city,
          appid: this.apiKey,
          units: 'metric'
        }
      });

      return this.formatWeatherData(response.data);
    } catch (error) {
      if (error.response && error.response.status === 404) {
        throw new Error('City not found');
      }
      throw new Error('Failed to fetch weather data');
    }
  }

  async getCurrentWeatherByCoords(lat, lon) {
    try {
      const response = await axios.get(`${this.apiUrl}/weather`, {
        params: {
          lat: lat,
          lon: lon,
          appid: this.apiKey,
          units: 'metric'
        }
      });

      return this.formatWeatherData(response.data);
    } catch (error) {
      throw new Error('Failed to fetch weather data');
    }
  }

  async getForecast(city, days = 5) {
    try {
      const response = await axios.get(`${this.apiUrl}/forecast`, {
        params: {
          q: city,
          appid: this.apiKey,
          units: 'metric',
          cnt: days * 8 // 8 data points per day (3-hour intervals)
        }
      });

      return this.formatForecastData(response.data);
    } catch (error) {
      if (error.response && error.response.status === 404) {
        throw new Error('City not found');
      }
      throw new Error('Failed to fetch forecast data');
    }
  }

  formatWeatherData(data) {
    return {
      city: data.name,
      country: data.sys.country,
      coordinates: {
        lat: data.coord.lat,
        lon: data.coord.lon
      },
      temperature: {
        current: Math.round(data.main.temp),
        feels_like: Math.round(data.main.feels_like),
        min: Math.round(data.main.temp_min),
        max: Math.round(data.main.temp_max)
      },
      weather: {
        main: data.weather[0].main,
        description: data.weather[0].description,
        icon: data.weather[0].icon
      },
      humidity: data.main.humidity,
      pressure: data.main.pressure,
      wind: {
        speed: data.wind.speed,
        direction: data.wind.deg
      },
      visibility: data.visibility,
      clouds: data.clouds.all,
      sunrise: new Date(data.sys.sunrise * 1000).toISOString(),
      sunset: new Date(data.sys.sunset * 1000).toISOString(),
      timestamp: new Date(data.dt * 1000).toISOString()
    };
  }

  formatForecastData(data) {
    return {
      city: data.city.name,
      country: data.city.country,
      coordinates: {
        lat: data.city.coord.lat,
        lon: data.city.coord.lon
      },
      forecast: data.list.map(item => ({
        timestamp: new Date(item.dt * 1000).toISOString(),
        temperature: {
          current: Math.round(item.main.temp),
          feels_like: Math.round(item.main.feels_like),
          min: Math.round(item.main.temp_min),
          max: Math.round(item.main.temp_max)
        },
        weather: {
          main: item.weather[0].main,
          description: item.weather[0].description,
          icon: item.weather[0].icon
        },
        humidity: item.main.humidity,
        wind: {
          speed: item.wind.speed,
          direction: item.wind.deg
        },
        clouds: item.clouds.all,
        pop: item.pop * 100 // Probability of precipitation
      }))
    };
  }
}

module.exports = new WeatherService();
```

### src/controllers/authController.js
```javascript
const User = require('../models/userModel');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validation
    if (!username || !email || !password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide username, email and password' 
      });
    }

    if (password.length < 6) {
      return res.status(400).json({ 
        success: false, 
        error: 'Password must be at least 6 characters' 
      });
    }

    // Check if user exists
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email already registered' 
      });
    }

    const existingUsername = await User.findByUsername(username);
    if (existingUsername) {
      return res.status(400).json({ 
        success: false, 
        error: 'Username already taken' 
      });
    }

    // Create user
    const userId = await User.create({ username, email, password });
    const user = await User.findById(userId);

    // Generate token
    const token = jwt.sign(
      { userId: user.id }, 
      process.env.JWT_SECRET, 
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email
        },
        token
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide email and password' 
      });
    }

    // Check if user exists
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid credentials' 
      });
    }

    // Check password
    const isMatch = await User.comparePassword(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid credentials' 
      });
    }

    // Generate token
    const token = jwt.sign(
      { userId: user.id }, 
      process.env.JWT_SECRET, 
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email
        },
        token
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getProfile = async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        user: req.user
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

### src/controllers/weatherController.js
```javascript
const weatherService = require('../services/weatherService');

exports.getCurrentWeather = async (req, res) => {
  try {
    const { city } = req.query;

    if (!city) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide a city name' 
      });
    }

    const weatherData = await weatherService.getCurrentWeather(city);

    res.json({
      success: true,
      data: weatherData
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getCurrentWeatherByCoords = async (req, res) => {
  try {
    const { lat, lon } = req.query;

    if (!lat || !lon) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide latitude and longitude' 
      });
    }

    const weatherData = await weatherService.getCurrentWeatherByCoords(lat, lon);

    res.json({
      success: true,
      data: weatherData
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getForecast = async (req, res) => {
  try {
    const { city, days } = req.query;

    if (!city) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide a city name' 
      });
    }

    const forecastData = await weatherService.getForecast(city, days || 5);

    res.json({
      success: true,
      data: forecastData
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

### src/controllers/favoriteController.js
```javascript
const Favorite = require('../models/favoriteModel');
const weatherService = require('../services/weatherService');

exports.addFavorite = async (req, res) => {
  try {
    const { city_name } = req.body;
    const userId = req.user.id;

    if (!city_name) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please provide a city name' 
      });
    }

    // Get weather data to validate city and get coordinates
    const weatherData = await weatherService.getCurrentWeather(city_name);

    // Add to favorites
    const favoriteId = await Favorite.create({
      user_id: userId,
      city_name: weatherData.city,
      country: weatherData.country,
      lat: weatherData.coordinates.lat,
      lon: weatherData.coordinates.lon
    });

    const favorite = await Favorite.findById(favoriteId, userId);

    res.status(201).json({
      success: true,
      data: favorite
    });
  } catch (error) {
    if (error.message === 'City already in favorites') {
      return res.status(400).json({ success: false, error: error.message });
    }
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const favorites = await Favorite.findByUserId(userId);

    res.json({
      success: true,
      data: favorites
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getFavoritesWithWeather = async (req, res) => {
  try {
    const userId = req.user.id;
    const favorites = await Favorite.findByUserId(userId);

    // Get current weather for all favorite cities
    const favoritesWithWeather = await Promise.all(
      favorites.map(async (favorite) => {
        try {
          const weather = await weatherService.getCurrentWeatherByCoords(
            favorite.lat, 
            favorite.lon
          );
          return {
            ...favorite,
            weather
          };
        } catch (error) {
          return {
            ...favorite,
            weather: null,
            error: 'Failed to fetch weather'
          };
        }
      })
    );

    res.json({
      success: true,
      data: favoritesWithWeather
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.deleteFavorite = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const affectedRows = await Favorite.delete(id, userId);

    if (affectedRows === 0) {
      return res.status(404).json({ 
        success: false, 
        error: 'Favorite not found' 
      });
    }

    res.json({
      success: true,
      message: 'Favorite removed successfully'
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

### src/routes/authRoutes.js
```javascript
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/profile', authMiddleware, authController.getProfile);

module.exports = router;
```

### src/routes/weatherRoutes.js
```javascript
const express = require('express');
const router = express.Router();
const weatherController = require('../controllers/weatherController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/current', authMiddleware, weatherController.getCurrentWeather);
router.get('/coords', authMiddleware, weatherController.getCurrentWeatherByCoords);
router.get('/forecast', authMiddleware, weatherController.getForecast);

module.exports = router;
```

### src/routes/favoriteRoutes.js
```javascript
const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, favoriteController.addFavorite);
router.get('/', authMiddleware, favoriteController.getFavorites);
router.get('/weather', authMiddleware, favoriteController.getFavoritesWithWeather);
router.delete('/:id', authMiddleware, favoriteController.deleteFavorite);

module.exports = router;
```

## API Endpoints

### Authentication
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login user | No |
| GET | `/api/auth/profile` | Get user profile | Yes |

### Weather
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/weather/current?city=London` | Get current weather by city | Yes |
| GET | `/api/weather/coords?lat=51.5&lon=-0.1` | Get weather by coordinates | Yes |
| GET | `/api/weather/forecast?city=London&days=5` | Get weather forecast | Yes |

### Favorites
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/favorites` | Add city to favorites | Yes |
| GET | `/api/favorites` | Get all favorite cities | Yes |
| GET | `/api/favorites/weather` | Get favorites with weather | Yes |
| DELETE | `/api/favorites/:id` | Remove favorite city | Yes |

## Sample API Requests

### 1. Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 3. Get Current Weather (with token)
```bash
curl http://localhost:3000/api/weather/current?city=London \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Add Favorite City
```bash
curl -X POST http://localhost:3000/api/favorites \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "city_name": "London"
  }'
```

### 5. Get Favorites with Weather
```bash
curl http://localhost:3000/api/favorites/weather \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Setup Instructions

1. **Get OpenWeatherMap API Key**
   - Sign up at https://openweathermap.org/api
   - Get your free API key
   - Add it to `.env` file

2. **Install Dependencies**
```bash
npm install
```

3. **Configure Database**
   - Update `.env` with your MySQL credentials
   - Run the SQL commands to create database and tables

4. **Start the Server**
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## Features

✅ User registration and authentication with JWT
✅ Real-time weather data from OpenWeatherMap API
✅ Current weather by city name or coordinates
✅ 5-day weather forecast
✅ Save favorite cities (unlimited)
✅ Get weather for all favorite cities at once
✅ Protected routes with JWT middleware
✅ Password hashing with bcrypt
✅ Comprehensive error handling
✅ RESTful API design