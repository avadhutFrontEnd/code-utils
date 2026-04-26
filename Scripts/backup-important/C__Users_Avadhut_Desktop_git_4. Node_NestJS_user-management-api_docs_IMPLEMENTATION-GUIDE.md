# Project 1: User Management API - Implementation Guide

## 📋 Step-by-Step Implementation

Follow these steps to build the complete User Management API.

---

## Step 1: Create NestJS Project

### 1.1 Install NestJS CLI (if not already installed)
```bash
npm i -g @nestjs/cli
```

### 1.2 Create New Project
```bash
nest new user-management-api
cd user-management-api
```

### 1.3 Project Structure
Your project should have this structure:
```
user-management-api/
├── src/
│   ├── app.controller.ts
│   ├── app.module.ts
│	├── app.service.ts
│   └── main.ts
├── test/
├── package.json
├── tsconfig.json
└── nest-cli.json
```

---

## Step 2: Install Required Dependencies

### 2.1 Install TypeORM and PostgreSQL Driver
```bash
npm install @nestjs/typeorm typeorm pg
npm install --save-dev @types/pg
```

### 2.2 Install Validation Packages
```bash
npm install class-validator class-transformer
```

---

## Step 3: Configure Environment Variables

### 3.1 Install dotenv
```bash
npm install @nestjs/config
```

### 3.2 Create `.env` file in root
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=user_management_db

# Application
PORT=3000
NODE_ENV=development
```

### 3.3 Create `.env.example` file
```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=
DB_DATABASE=user_management_db
PORT=3000
NODE_ENV=development
```

---

## Step 4: Set Up Database Module

### 4.1 Create Database Module
```bash
nest g module database
```

### 4.2 Update `src/database/database.module.ts`
```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: +configService.get('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [User],
        synchronize: configService.get('NODE_ENV') === 'development',
        logging: configService.get('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
```

---

## Step 5: Create Users Module

### 5.1 Generate Users Module
```bash
nest g module users
nest g controller users
nest g service users
```

### 5.2 Create Entity Directory
```bash
mkdir src/users/entities
mkdir src/users/dto
```

---

## Step 6: Create User Entity

### 6.1 Create `src/users/entities/user.entity.ts`
```typescript
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

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

  @Column({ nullable: true, type: 'int' })
  age: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

---

## Step 7: Create DTOs

### 7.1 Create `src/users/dto/create-user.dto.ts`
```typescript
import {
  IsEmail,
  IsString,
  IsOptional,
  IsInt,
  Min,
  Max,
  MinLength,
  MaxLength,
} from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(2)
  @MaxLength(50)
  firstName: string;

  @IsString()
  @MinLength(2)
  @MaxLength(50)
  lastName: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(150)
  age?: number;
}
```

### 7.2 Create `src/users/dto/update-user.dto.ts`
```typescript
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

**Note**: Install `@nestjs/mapped-types` if needed:
```bash
npm install @nestjs/mapped-types
```

---

## Step 8: Update Users Service

### 8.1 Update `src/users/users.service.ts`
```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return await this.userRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);
    Object.assign(user, updateUserDto);
    return await this.userRepository.save(user);
  }

  async remove(id: string): Promise<{ message: string }> {
    const user = await this.findOne(id);
    await this.userRepository.remove(user);
    return { message: `User with ID ${id} has been deleted` };
  }
}
```

---

## Step 9: Update Users Controller

### 9.1 Update `src/users/users.controller.ts`
```typescript
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }
}
```

---

## Step 10: Update Users Module

### 10.1 Update `src/users/users.module.ts`
```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

---

## Step 11: Update App Module

### 11.1 Update `src/app.module.ts`
```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    DatabaseModule,
    UsersModule,
  ],
})
export class AppModule {}
```

---

## Step 12: Update Main.ts

### 12.1 Update `src/main.ts`
```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable validation globally
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip properties that don't have decorators
      forbidNonWhitelisted: true, // Throw error if non-whitelisted properties are sent
      transform: true, // Automatically transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Enable implicit type conversion
      },
    }),
  );

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
```

---

## Step 13: Create Database

### 13.1 Create PostgreSQL Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE user_management_db;

# Exit
\q
```

---

## Step 14: Run the Application

### 14.1 Start the Application
```bash
npm run start:dev
```

### 14.2 Verify It's Running
You should see:
```
Application is running on: http://localhost:3000
```

---

## Step 15: Test the API

### 15.1 Create a User
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "age": 30
  }'
```

**Expected Response:**
```json
{
  "id": "uuid-here",
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "age": 30,
  "createdAt": "2024-01-15T10:00:00.000Z",
  "updatedAt": "2024-01-15T10:00:00.000Z"
}
```

### 15.2 Get All Users
```bash
curl http://localhost:3000/users
```

### 15.3 Get User by ID
```bash
curl http://localhost:3000/users/{user-id}
```

### 15.4 Update User
```bash
curl -X PATCH http://localhost:3000/users/{user-id} \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane"
  }'
```

### 15.5 Delete User
```bash
curl -X DELETE http://localhost:3000/users/{user-id}
```

---

## Step 16: Test Validation

### 16.1 Test Invalid Email
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

**Expected Response:** `400 Bad Request` with validation errors

### 16.2 Test Missing Required Fields
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

**Expected Response:** `400 Bad Request` with validation errors

---

## Step 17: Test Error Handling

### 17.1 Test Non-Existent User
```bash
curl http://localhost:3000/users/non-existent-id
```

**Expected Response:** `404 Not Found` with error message

---

## ✅ Final Checklist

- [ ] All 5 endpoints work correctly
- [ ] Validation works for all inputs
- [ ] Error handling returns proper HTTP status codes
- [ ] Database connection is working
- [ ] All endpoints return correct response formats
- [ ] No TypeScript errors
- [ ] Code follows NestJS best practices

---

## 🐛 Troubleshooting

### Issue: Database Connection Error
**Solution**: 
- Check PostgreSQL is running
- Verify `.env` file has correct credentials
- Ensure database exists

### Issue: Validation Not Working
**Solution**:
- Ensure `ValidationPipe` is added in `main.ts`
- Check DTOs have proper decorators
- Verify `class-validator` is installed

### Issue: Entity Not Found
**Solution**:
- Ensure entity is added to `TypeOrmModule.forRootAsync` entities array
- Check entity file path is correct

### Issue: UUID Not Working
**Solution**:
- Ensure `@PrimaryGeneratedColumn('uuid')` is used
- PostgreSQL must have `uuid-ossp` extension enabled

---

## 🎉 Congratulations!

You've successfully built a complete User Management API with NestJS! 

**Next Steps:**
- Move to **Project 2: Blog System** to learn about relationships
- Or review the code and understand each concept deeply

---

**Project Complete!** ✅

