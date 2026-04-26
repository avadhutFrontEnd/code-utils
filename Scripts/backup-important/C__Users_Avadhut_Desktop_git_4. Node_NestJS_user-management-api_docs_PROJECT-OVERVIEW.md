# Project 1: User Management API

## 🎯 Project Overview

Build a complete User Management API using NestJS with full CRUD operations. This project covers the foundational concepts of NestJS including controllers, services, DTOs, validation, error handling, and TypeORM entities.

**Project Type**: REST API  
**Database**: PostgreSQL (TypeORM)  
**Difficulty**: Beginner  
**Estimated Time**: 2-3 hours

---

## 📚 Learning Objectives

By completing this project, you will practice:

1. ✅ **NestJS Project Setup** - Creating a new NestJS project
2. ✅ **TypeORM Integration** - Setting up database connection
3. ✅ **Entity Definition** - Creating TypeORM entities
4. ✅ **DTOs & Validation** - Using class-validator for input validation
5. ✅ **Controllers** - Creating REST API endpoints
6. ✅ **Services** - Implementing business logic
7. ✅ **Dependency Injection** - Using NestJS DI container
8. ✅ **Error Handling** - Proper HTTP exception handling
9. ✅ **Database Migrations** - Creating and running migrations

---

## 🗄️ Database Schema

### User Entity

```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ nullable: true })
  age: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

**Fields:**
- `id` - UUID primary key
- `email` - Unique email address
- `firstName` - User's first name
- `lastName` - User's last name
- `age` - Optional age
- `createdAt` - Auto-managed creation timestamp
- `updatedAt` - Auto-managed update timestamp

---

## 🔌 API Endpoints

### 1. Create User
- **Method**: `POST`
- **Path**: `/users`
- **Body**: 
  ```json
  {
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "age": 30
  }
  ```
- **Response**: `201 Created` with user object
- **Validation**: Email must be valid, firstName/lastName required, age must be positive number

### 2. Get All Users
- **Method**: `GET`
- **Path**: `/users`
- **Query Parameters**: None
- **Response**: `200 OK` with array of users

### 3. Get User by ID
- **Method**: `GET`
- **Path**: `/users/:id`
- **Params**: `id` (UUID)
- **Response**: `200 OK` with user object
- **Error**: `404 Not Found` if user doesn't exist

### 4. Update User
- **Method**: `PATCH`
- **Path**: `/users/:id`
- **Params**: `id` (UUID)
- **Body**: Partial user data (all fields optional)
  ```json
  {
    "firstName": "Jane",
    "age": 25
  }
  ```
- **Response**: `200 OK` with updated user object
- **Error**: `404 Not Found` if user doesn't exist

### 5. Delete User
- **Method**: `DELETE`
- **Path**: `/users/:id`
- **Params**: `id` (UUID)
- **Response**: `200 OK` with success message
- **Error**: `404 Not Found` if user doesn't exist

---

## ✅ Validation Rules

### Create User DTO
- `email`: Required, must be valid email format, unique
- `firstName`: Required, string, min 2 characters, max 50
- `lastName`: Required, string, min 2 characters, max 50
- `age`: Optional, number, min 1, max 150

### Update User DTO
- All fields optional
- Same validation rules as Create DTO when provided

---

## 📁 Project Structure

```
src/
├── main.ts                    # Application entry point
├── app.module.ts              # Root module
├── users/
│   ├── users.module.ts        # Users module
│   ├── users.controller.ts   # REST API endpoints
│   ├── users.service.ts       # Business logic
│   ├── dto/
│   │   ├── create-user.dto.ts
│   │   └── update-user.dto.ts
│   └── entities/
│       └── user.entity.ts     # TypeORM entity
├── database/
│   ├── database.module.ts     # Database module
│   └── data-source.ts         # TypeORM configuration
└── config/
    └── database.config.ts     # Database config
```

---

## 📦 Required Dependencies

### Core Dependencies
```json
{
  "@nestjs/common": "^10.0.0",
  "@nestjs/core": "^10.0.0",
  "@nestjs/platform-express": "^10.0.0",
  "@nestjs/typeorm": "^10.0.0",
  "typeorm": "^0.3.17",
  "pg": "^8.11.0",
  "class-validator": "^0.14.0",
  "class-transformer": "^0.5.1",
  "reflect-metadata": "^0.1.13",
  "rxjs": "^7.8.1"
}
```

### Dev Dependencies
```json
{
  "@nestjs/cli": "^10.0.0",
  "@nestjs/schematics": "^10.0.0",
  "@types/express": "^4.17.17",
  "@types/node": "^20.3.1",
  "typescript": "^5.1.3",
  "ts-loader": "^9.4.3",
  "ts-node": "^10.9.1",
  "tsconfig-paths": "^4.2.0"
}
```

---

## 🔧 Prerequisites

Before starting, you should:

1. ✅ Have Node.js (v18+) installed
2. ✅ Have PostgreSQL installed and running
3. ✅ Have basic TypeScript knowledge
4. ✅ Understand REST API concepts
5. ✅ Have NestJS CLI installed globally: `npm i -g @nestjs/cli`

---

## 🎯 Success Criteria

Your project is complete when:

- [ ] All 5 API endpoints work correctly
- [ ] Validation works for all inputs
- [ ] Error handling returns proper HTTP status codes
- [ ] Database migrations run successfully
- [ ] All endpoints return correct response formats
- [ ] Code follows NestJS best practices
- [ ] No TypeScript errors

---

## 🧪 Testing Endpoints

### Using cURL

```bash
# Create User
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","firstName":"Test","lastName":"User","age":25}'

# Get All Users
curl http://localhost:3000/users

# Get User by ID
curl http://localhost:3000/users/{user-id}

# Update User
curl -X PATCH http://localhost:3000/users/{user-id} \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Updated"}'

# Delete User
curl -X DELETE http://localhost:3000/users/{user-id}
```

### Using Postman

Import the endpoints into Postman and test each one.

---

## 📝 Notes

- Use UUID for user IDs (better for distributed systems)
- Email must be unique (database constraint)
- Use proper HTTP status codes (201 for create, 200 for success, 404 for not found)
- Validate all inputs using DTOs
- Handle errors gracefully with proper messages

---

## 🔗 Next Steps

After completing this project:
- Move to **Project 2: Blog System** to learn about relationships
- Or practice with **Project 3: Todo App** for more CRUD practice

---

**Ready to start?** Follow the `IMPLEMENTATION-GUIDE.md` step by step!

