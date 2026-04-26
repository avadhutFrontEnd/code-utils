# Project 1: User Management API

## 🚀 Quick Start

This is a complete User Management API built with NestJS, TypeORM, and PostgreSQL.

### Prerequisites

- Node.js (v18+)
- PostgreSQL (v14+)
- NestJS CLI (`npm i -g @nestjs/cli`)

### Installation

1. **Create NestJS Project**
   ```bash
   nest new user-management-api
   cd user-management-api
   ```

2. **Install Dependencies**
   ```bash
   npm install @nestjs/typeorm typeorm pg class-validator class-transformer @nestjs/config @nestjs/mapped-types
   npm install --save-dev @types/pg
   ```

3. **Set Up Database**
   ```bash
   # Create PostgreSQL database
   psql -U postgres
   CREATE DATABASE user_management_db;
   \q
   ```

4. **Configure Environment**
   ```bash
   # Create .env file
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   DB_DATABASE=user_management_db
   PORT=3000
   NODE_ENV=development
   ```

5. **Follow Implementation Guide**
   - Read `IMPLEMENTATION-GUIDE.md` for step-by-step instructions
   - Or read `PROJECT-OVERVIEW.md` for requirements

6. **Run Application**
   ```bash
   npm run start:dev
   ```

### API Endpoints

- `POST /users` - Create user
- `GET /users` - Get all users
- `GET /users/:id` - Get user by ID
- `PATCH /users/:id` - Update user
- `DELETE /users/:id` - Delete user

### Testing

```bash
# Create User
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","firstName":"Test","lastName":"User","age":25}'
```

## 📚 Concepts Covered

- NestJS Project Setup
- TypeORM Integration
- Entity Definition
- DTOs & Validation
- Controllers & Services
- Dependency Injection
- Error Handling
- Database Migrations

## 📖 Documentation

- `PROJECT-OVERVIEW.md` - Complete project requirements
- `IMPLEMENTATION-GUIDE.md` - Step-by-step implementation guide

## ✅ Project Status

- [x] Project structure created
- [ ] Implementation in progress
- [ ] Testing completed
- [ ] Documentation reviewed

---

**Ready to start?** Follow the `IMPLEMENTATION-GUIDE.md`!

