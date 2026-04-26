# NestJS Libraries Documentation

This document provides detailed information about all the libraries and modules used in the `user-management-api` NestJS project.

---

## Table of Contents

### Foundation
- **0. Foundation: Understanding NestJS Architecture**
  - 0.1. What is NestJS?
  - 0.2. NestJS Core Concepts
  - 0.3. Dependency Injection (DI) System
  - 0.4. Module System
  - 0.5. Decorators in NestJS
  - 0.6. Understanding package.json in NestJS

### Core NestJS Libraries
- **1. @nestjs/core**
  - 1.1. NestFactory - Application Bootstrap
  - 1.2. Application Lifecycle
  - 1.3. Creating NestJS Application
- **2. @nestjs/common**
  - 2.1. Module Decorator
  - 2.2. Controller Decorator
  - 2.3. Injectable Decorator
  - 2.4. HTTP Method Decorators
  - 2.5. Request and Response Objects
  - 2.6. Exception Filters
  - 2.7. Pipes (Validation & Transformation)
  - 2.8. Guards (Authentication & Authorization)
  - 2.9. Interceptors
- **3. @nestjs/platform-express**
  - 3.1. Express Integration
  - 3.2. Request/Response Objects
  - 3.3. Middleware Support

### Configuration & Environment
- **4. @nestjs/config**
  - 4.1. ConfigModule Setup
  - 4.2. Environment Variables
  - 4.3. ConfigService Usage
  - 4.4. Configuration Validation

### Database & ORM
- **5. @nestjs/typeorm**
  - 5.1. TypeOrmModule Setup
  - 5.2. Database Connection
  - 5.3. Entity Registration
  - 5.4. Repository Pattern
- **6. TypeORM**
  - 6.1. Entity Definition
  - 6.2. Column Decorators
  - 6.3. Relationships
  - 6.4. Repository Methods
  - 6.5. Query Builder
  - 6.6. Migrations
- **7. pg (PostgreSQL Driver)**
  - 7.1. PostgreSQL Connection
  - 7.2. Connection Pooling

### Validation & Transformation
- **8. class-validator**
  - 8.1. Validation Decorators
  - 8.2. Built-in Validators
  - 8.3. Custom Validators
  - 8.4. Validation in DTOs
- **9. class-transformer**
  - 9.1. Transformation Decorators
  - 9.2. Exclude/Expose Properties
  - 9.3. Type Transformation
  - 9.4. Plain to Class Conversion

### Core Dependencies
- **10. reflect-metadata**
  - 10.1. Metadata Reflection
  - 10.2. Decorator Metadata
- **11. rxjs**
  - 11.1. Observables in NestJS
  - 11.2. Async Operations
  - 11.3. Error Handling

---

**Note:** Sections are organized by category for easier navigation. The numbering (0-11) follows the order of appearance in the document.

---

## 0. Foundation: Understanding NestJS Architecture

Before diving into specific libraries, it's essential to understand the fundamental architecture of NestJS and how it differs from traditional Express.js applications.

---

### 0.1. What is NestJS?

NestJS is a progressive Node.js framework for building efficient, reliable, and scalable server-side applications. It's built with TypeScript and uses modern JavaScript features.

#### Key Characteristics

1. **Modular Architecture**: Applications are organized into modules
2. **Dependency Injection**: Built-in DI container for managing dependencies
3. **Decorators**: Extensive use of TypeScript decorators
4. **Express Under the Hood**: Uses Express.js (or Fastify) as the HTTP server
5. **TypeScript First**: Designed for TypeScript, but supports JavaScript

#### Why NestJS?

- **Scalability**: Modular structure makes large applications manageable
- **Type Safety**: TypeScript provides compile-time error checking
- **Testability**: DI makes unit testing easier
- **Enterprise Ready**: Follows SOLID principles and design patterns
- **Rich Ecosystem**: Built-in support for GraphQL, WebSockets, microservices, etc.

---

### 0.2. NestJS Core Concepts

#### 1. Modules

Modules are the basic building blocks of a NestJS application. Each module encapsulates related functionality.

**Example:**
```typescript
@Module({
  imports: [OtherModule],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}
```

#### 2. Controllers

Controllers handle incoming HTTP requests and return responses to the client.

**Example:**
```typescript
@Controller('users')
export class UserController {
  @Get()
  findAll() {
    return 'This returns all users';
  }
}
```

#### 3. Providers

Providers are classes that can be injected as dependencies. Services, repositories, factories, helpers, etc., can all be providers.

**Example:**
```typescript
@Injectable()
export class UserService {
  findAll() {
    return [];
  }
}
```

#### 4. Dependency Injection

NestJS uses dependency injection to manage dependencies between classes.

**Example:**
```typescript
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}
  // UserService is automatically injected
}
```

---

### 0.3. Dependency Injection (DI) System

Dependency Injection is a design pattern where objects receive their dependencies from an external source rather than creating them internally.

#### How DI Works in NestJS

1. **Provider Registration**: Providers are registered in modules
2. **Token Resolution**: NestJS uses tokens to resolve dependencies
3. **Injection**: Dependencies are injected via constructor parameters

**Example:**
```typescript
// 1. Define a provider
@Injectable()
export class UserService {
  getUsers() {
    return ['user1', 'user2'];
  }
}

// 2. Register in module
@Module({
  providers: [UserService],
})
export class UserModule {}

// 3. Inject in controller
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}
  
  @Get()
  getUsers() {
    return this.userService.getUsers();
  }
}
```

#### DI Benefits

- **Loose Coupling**: Classes don't create their own dependencies
- **Testability**: Easy to mock dependencies in tests
- **Reusability**: Services can be shared across modules
- **Maintainability**: Changes to dependencies don't require changes to dependent classes

---

### 0.4. Module System

Modules organize your application into cohesive blocks of functionality.

#### Module Structure

```typescript
@Module({
  imports: [],        // Other modules to import
  controllers: [],    // Controllers in this module
  providers: [],      // Services/providers in this module
  exports: [],        // Providers to export to other modules
})
export class FeatureModule {}
```

#### Module Types

1. **Feature Modules**: Encapsulate a specific feature (e.g., UserModule)
2. **Shared Modules**: Provide common functionality (e.g., DatabaseModule)
3. **Global Modules**: Available everywhere without importing (use @Global())
4. **Dynamic Modules**: Configure modules at runtime

**Example - Global Module:**
```typescript
@Global()
@Module({
  providers: [ConfigService],
  exports: [ConfigService],
})
export class ConfigModule {}
```

---

### 0.5. Decorators in NestJS

Decorators are special functions that modify classes, methods, or properties. NestJS uses decorators extensively.

#### Common Decorators

**Class Decorators:**
- `@Module()` - Defines a module
- `@Controller()` - Defines a controller
- `@Injectable()` - Marks a class as injectable
- `@Entity()` - Defines a TypeORM entity

**Method Decorators:**
- `@Get()` - HTTP GET handler
- `@Post()` - HTTP POST handler
- `@Put()` - HTTP PUT handler
- `@Delete()` - HTTP DELETE handler
- `@Patch()` - HTTP PATCH handler

**Parameter Decorators:**
- `@Body()` - Extract request body
- `@Param()` - Extract route parameters
- `@Query()` - Extract query parameters
- `@Headers()` - Extract headers
- `@Req()` - Access Express request object
- `@Res()` - Access Express response object

**Property Decorators:**
- `@Column()` - TypeORM column
- `@PrimaryGeneratedColumn()` - Primary key
- `@IsEmail()` - Validation decorator
- `@IsString()` - Validation decorator

**Example:**
```typescript
@Controller('users')
export class UserController {
  @Get(':id')
  findOne(
    @Param('id') id: string,
    @Query('include') include?: string,
  ) {
    return { id, include };
  }
}
```

---

### 0.6. Understanding package.json in NestJS

The `package.json` file defines your project's dependencies and scripts.

#### Key Sections

**Dependencies:**
```json
{
  "dependencies": {
    "@nestjs/common": "^11.0.1",      // Core NestJS functionality
    "@nestjs/core": "^11.0.1",        // NestJS core framework
    "@nestjs/platform-express": "^11.0.1",  // Express adapter
    "@nestjs/config": "^4.0.2",       // Configuration management
    "@nestjs/typeorm": "^11.0.0",     // TypeORM integration
    "typeorm": "^0.3.28",             // TypeORM ORM
    "pg": "^8.16.3",                  // PostgreSQL driver
    "class-validator": "^0.14.3",     // Validation
    "class-transformer": "^0.5.1",    // Object transformation
    "reflect-metadata": "^0.2.2",     // Metadata reflection
    "rxjs": "^7.8.1"                  // Reactive programming
  }
}
```

**Scripts:**
```json
{
  "scripts": {
    "build": "nest build",                    // Build for production
    "start": "nest start",                    // Start application
    "start:dev": "nest start --watch",        // Start with hot reload
    "start:debug": "nest start --debug --watch",  // Start with debugging
    "start:prod": "node dist/main",           // Start production build
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",                           // Run unit tests
    "test:e2e": "jest --config ./test/jest-e2e.json"  // Run e2e tests
  }
}
```

---

## 1. @nestjs/core

The core NestJS framework that provides the foundation for building applications.

---

### 1.1. NestFactory - Application Bootstrap

`NestFactory` is used to create a NestJS application instance.

#### Basic Usage

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
```

#### What Happens When You Call `NestFactory.create()`?

1. **Module Resolution**: NestJS reads the AppModule and all its imports
2. **Dependency Graph**: Builds a dependency injection graph
3. **Provider Instantiation**: Creates instances of all providers
4. **Controller Registration**: Registers all route handlers
5. **HTTP Server**: Creates an Express (or Fastify) HTTP server
6. **Application Ready**: Returns an application instance

#### Application Instance Methods

```typescript
const app = await NestFactory.create(AppModule);

// Start listening on a port
await app.listen(3000);

// Get underlying HTTP server
const server = app.getHttpServer();

// Enable CORS
app.enableCors();

// Set global prefix
app.setGlobalPrefix('api');

// Use global filters
app.useGlobalFilters(new HttpExceptionFilter());

// Use global pipes
app.useGlobalPipes(new ValidationPipe());

// Use global guards
app.useGlobalGuards(new AuthGuard());

// Use global interceptors
app.useGlobalInterceptors(new LoggingInterceptor());

// Close application gracefully
await app.close();
```

---

### 1.2. Application Lifecycle

NestJS applications have a lifecycle with hooks you can use.

#### Lifecycle Events

```typescript
@Injectable()
export class AppService implements OnModuleInit, OnModuleDestroy {
  onModuleInit() {
    // Called once the module has been initialized
    console.log('Module initialized');
  }

  onModuleDestroy() {
    // Called when the module is being destroyed
    console.log('Module destroyed');
  }
}
```

**Available Lifecycle Hooks:**
- `OnModuleInit` - Called when module is initialized
- `OnModuleDestroy` - Called when module is destroyed
- `BeforeApplicationShutdown` - Called before app shutdown
- `OnApplicationShutdown` - Called during app shutdown
- `OnApplicationBootstrap` - Called after app is fully bootstrapped

---

### 1.3. Creating NestJS Application

#### Complete Bootstrap Example

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Global configuration
  app.setGlobalPrefix('api');
  app.enableCors();
  
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // Strip unknown properties
      forbidNonWhitelisted: true, // Throw error for unknown properties
      transform: true,           // Transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  await app.listen(process.env.PORT ?? 3000);
  console.log(`Application is running on: ${await app.getUrl()}`);
}

bootstrap();
```

---

## 2. @nestjs/common

Provides core decorators, classes, and utilities used throughout NestJS applications.

---

### 2.1. Module Decorator

The `@Module()` decorator defines a module.

#### Module Options

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User])],  // Import other modules
  controllers: [UserController],                 // Controllers in this module
  providers: [UserService, UserRepository],      // Services/providers
  exports: [UserService],                        // Export to other modules
})
export class UserModule {}
```

**Options Explained:**
- `imports`: Modules that export providers this module needs
- `controllers`: Controllers that belong to this module
- `providers`: Services/classes that can be injected
- `exports`: Providers that other modules can use

---

### 2.2. Controller Decorator

The `@Controller()` decorator defines a controller and its base route.

#### Basic Controller

```typescript
@Controller('users')
export class UserController {
  @Get()
  findAll() {
    return 'Get all users';
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return `Get user ${id}`;
  }

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return 'Create user';
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return `Update user ${id}`;
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return `Delete user ${id}`;
  }
}
```

#### Controller Options

```typescript
@Controller({
  path: 'users',
  version: '1',  // API versioning
})
export class UserController {}
```

---

### 2.3. Injectable Decorator

The `@Injectable()` decorator marks a class as a provider that can be injected.

#### Service Example

```typescript
@Injectable()
export class UserService {
  private users = [];

  findAll() {
    return this.users;
  }

  findOne(id: string) {
    return this.users.find(user => user.id === id);
  }

  create(createUserDto: CreateUserDto) {
    const user = { id: Date.now().toString(), ...createUserDto };
    this.users.push(user);
    return user;
  }
}
```

**Key Points:**
- Without `@Injectable()`, the class cannot be injected
- Services are singletons by default
- Services can inject other services

---

### 2.4. HTTP Method Decorators

NestJS provides decorators for all HTTP methods.

#### Available Decorators

```typescript
@Controller('users')
export class UserController {
  @Get()                    // GET /users
  @Get(':id')               // GET /users/:id
  @Post()                   // POST /users
  @Put(':id')               // PUT /users/:id
  @Patch(':id')             // PATCH /users/:id
  @Delete(':id')            // DELETE /users/:id
  @Options()                // OPTIONS /users
  @Head()                   // HEAD /users
  @All('*')                 // All methods matching pattern
}
```

#### Route Patterns

```typescript
@Controller('users')
export class UserController {
  @Get('profile')           // GET /users/profile
  getProfile() {}

  @Get('*')                 // GET /users/* (wildcard)
  catchAll() {}

  @Get('ab*cd')            // GET /users/ab*cd (pattern)
  pattern() {}
}
```

---

### 2.5. Request and Response Objects

NestJS provides decorators to extract data from requests.

#### Parameter Decorators

```typescript
@Controller('users')
export class UserController {
  // Extract route parameter
  @Get(':id')
  findOne(@Param('id') id: string) {
    return { id };
  }

  // Extract all route parameters
  @Get(':id/posts/:postId')
  findPost(@Param() params: { id: string; postId: string }) {
    return params;
  }

  // Extract query parameters
  @Get()
  findAll(@Query('page') page: number, @Query('limit') limit: number) {
    return { page, limit };
  }

  // Extract all query parameters
  @Get()
  findAll(@Query() query: { page?: number; limit?: number }) {
    return query;
  }

  // Extract request body
  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return createUserDto;
  }

  // Extract specific body property
  @Post()
  create(@Body('email') email: string) {
    return { email };
  }

  // Extract headers
  @Get()
  findAll(@Headers('authorization') auth: string) {
    return { auth };
  }

  // Extract all headers
  @Get()
  findAll(@Headers() headers: Record<string, string>) {
    return headers;
  }

  // Access full Express request object
  @Get()
  findAll(@Req() req: Request) {
    return { url: req.url, method: req.method };
  }

  // Access full Express response object
  @Get()
  findAll(@Res() res: Response) {
    return res.status(200).json({ message: 'Hello' });
  }
}
```

**Important Notes:**
- When using `@Res()`, you must handle the response manually
- Don't mix `@Res()` with returning values from handlers
- Use DTOs with `@Body()` for type safety

---

### 2.6. Exception Filters

Exception filters handle exceptions thrown by your application.

#### Built-in HTTP Exceptions

```typescript
import { 
  BadRequestException,
  UnauthorizedException,
  ForbiddenException,
  NotFoundException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';

@Controller('users')
export class UserController {
  @Get(':id')
  findOne(@Param('id') id: string) {
    if (!id) {
      throw new BadRequestException('ID is required');
    }
    
    const user = this.userService.findOne(id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    
    return user;
  }
}
```

#### Custom Exception Filter

```typescript
import { ExceptionFilter, Catch, ArgumentsHost, HttpException } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message: exceptionResponse,
    });
  }
}

// Use it
@Controller('users')
@UseFilters(HttpExceptionFilter)
export class UserController {}
```

---

### 2.7. Pipes (Validation & Transformation)

Pipes transform input data and validate it.

#### Built-in Pipes

```typescript
import { 
  ParseIntPipe,
  ParseFloatPipe,
  ParseBoolPipe,
  ParseArrayPipe,
  ParseUUIDPipe,
  DefaultValuePipe,
  ValidationPipe,
} from '@nestjs/common';

@Controller('users')
export class UserController {
  // Parse string to number
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return { id, type: typeof id };
  }

  // Parse with default value
  @Get()
  findAll(@Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number) {
    return { page };
  }

  // Parse array
  @Get()
  findAll(@Query('ids', ParseArrayPipe) ids: string[]) {
    return { ids };
  }

  // Parse UUID
  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return { id };
  }
}
```

#### ValidationPipe

The `ValidationPipe` uses `class-validator` to validate DTOs.

```typescript
// DTO
import { IsEmail, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(3)
  username: string;
}

// Controller
@Controller('users')
export class UserController {
  @Post()
  create(@Body(ValidationPipe) createUserDto: CreateUserDto) {
    return createUserDto;
  }
}
```

**Global ValidationPipe:**
```typescript
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,                    // Strip unknown properties
    forbidNonWhitelisted: true,         // Throw error for unknown properties
    transform: true,                    // Transform to DTO instance
    transformOptions: {
      enableImplicitConversion: true,   // Auto-convert types
    },
  }),
);
```

---

### 2.8. Guards (Authentication & Authorization)

Guards determine whether a request should be handled by the route handler.

#### Guard Example

```typescript
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';

@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const token = request.headers.authorization;

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    // Validate token logic here
    return true; // or false
  }
}

// Use it
@Controller('users')
@UseGuards(AuthGuard)
export class UserController {}
```

#### ExecutionContext

Provides access to request/response objects:

```typescript
canActivate(context: ExecutionContext): boolean {
  // HTTP context
  const ctx = context.switchToHttp();
  const request = ctx.getRequest<Request>();
  const response = ctx.getResponse<Response>();

  // WebSocket context
  // const ctx = context.switchToWs();
  // const client = ctx.getClient();

  return true;
}
```

---

### 2.9. Interceptors

Interceptors can transform responses, add extra logic, or handle errors.

#### Response Transformation Interceptor

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map(data => ({
        success: true,
        data,
        timestamp: new Date().toISOString(),
      })),
    );
  }
}

// Use it
@Controller('users')
@UseInterceptors(TransformInterceptor)
export class UserController {}
```

#### Logging Interceptor

```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        console.log(`${method} ${url} ${Date.now() - now}ms`);
      }),
    );
  }
}
```

---

## 3. @nestjs/platform-express

Provides Express.js integration for NestJS.

---

### 3.1. Express Integration

NestJS uses Express.js under the hood by default (via `@nestjs/platform-express`).

#### How It Works

```typescript
// When you create an app
const app = await NestFactory.create(AppModule);
// NestJS internally uses Express

// You can access the Express instance
const expressApp = app.getHttpAdapter().getInstance();
// Now you can use Express middleware directly
expressApp.use(express.json());
```

---

### 3.2. Request/Response Objects

NestJS provides access to Express request and response objects.

```typescript
import { Request, Response } from 'express';

@Controller('users')
export class UserController {
  @Get()
  findAll(@Req() req: Request, @Res() res: Response) {
    // Access Express request properties
    console.log(req.ip);
    console.log(req.hostname);
    console.log(req.protocol);

    // Use Express response methods
    res.status(200).json({ message: 'Hello' });
  }
}
```

**Note:** When using `@Res()`, you must handle the response manually. Don't return a value from the handler.

---

### 3.3. Middleware Support

You can use Express middleware in NestJS.

#### Functional Middleware

```typescript
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(`Request: ${req.method} ${req.url}`);
    next();
  }
}

// Apply in module
@Module({
  // ...
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(LoggerMiddleware)
      .forRoutes('users');
  }
}
```

---

## 4. @nestjs/config

Manages application configuration and environment variables.

---

### 4.1. ConfigModule Setup

#### Basic Setup

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,              // Make ConfigService available globally
      envFilePath: '.env',          // Path to .env file
      ignoreEnvFile: false,         // Don't ignore .env file
    }),
  ],
})
export class AppModule {}
```

#### Configuration Options

```typescript
ConfigModule.forRoot({
  isGlobal: true,                  // Global module
  envFilePath: ['.env.local', '.env'],  // Multiple env files
  ignoreEnvFile: false,            // Use .env file
  expandVariables: true,           // Expand ${VAR} in .env
  cache: true,                     // Cache config values
  validationSchema: Joi.object({  // Validate env variables
    PORT: Joi.number().required(),
    DB_HOST: Joi.string().required(),
  }),
})
```

---

### 4.2. Environment Variables

#### .env File

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_DATABASE=user_management_db

# Application
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key
```

---

### 4.3. ConfigService Usage

#### Injecting ConfigService

```typescript
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class DatabaseService {
  constructor(private configService: ConfigService) {}

  getConnectionString() {
    return {
      host: this.configService.get<string>('DB_HOST'),
      port: this.configService.get<number>('DB_PORT'),
      username: this.configService.get<string>('DB_USERNAME'),
      password: this.configService.get<string>('DB_PASSWORD'),
      database: this.configService.get<string>('DB_DATABASE'),
    };
  }

  // With default value
  getPort() {
    return this.configService.get<number>('PORT', 3000);
  }

  // Type-safe getter
  get<T extends keyof any>(key: string): T {
    return this.configService.get<T>(key);
  }
}
```

#### Typed Configuration

```typescript
// config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
  },
});

// app.module.ts
ConfigModule.forRoot({
  load: [configuration],
});

// Usage
constructor(private configService: ConfigService) {
  const dbConfig = this.configService.get('database');
}
```

---

### 4.4. Configuration Validation

#### Using Joi

```typescript
import * as Joi from 'joi';

ConfigModule.forRoot({
  validationSchema: Joi.object({
    NODE_ENV: Joi.string()
      .valid('development', 'production', 'test')
      .default('development'),
    PORT: Joi.number().default(3000),
    DB_HOST: Joi.string().required(),
    DB_PORT: Joi.number().default(5432),
    DB_USERNAME: Joi.string().required(),
    DB_PASSWORD: Joi.string().required(),
    DB_DATABASE: Joi.string().required(),
  }),
  validationOptions: {
    allowUnknown: true,
    abortEarly: true,
  },
})
```

---

## 5. @nestjs/typeorm

NestJS integration for TypeORM, a powerful ORM for TypeScript and JavaScript.

---

### 5.1. TypeOrmModule Setup

#### Root Module Configuration

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: true, // Only for development!
        logging: true,
      }),
      inject: [ConfigService],
    }),
  ],
})
export class AppModule {}
```

#### Synchronous Configuration

```typescript
TypeOrmModule.forRoot({
  type: 'postgres',
  host: 'localhost',
  port: 5432,
  username: 'postgres',
  password: 'password',
  database: 'user_management_db',
  entities: [User],
  synchronize: true,
})
```

---

### 5.2. Database Connection

#### Connection Options

```typescript
{
  type: 'postgres',                    // Database type
  host: 'localhost',                   // Database host
  port: 5432,                          // Database port
  username: 'postgres',                // Username
  password: 'password',                // Password
  database: 'mydb',                    // Database name
  entities: [User, Post],              // Entity classes
  synchronize: false,                  // Auto-sync schema (dev only!)
  logging: true,                       // Log SQL queries
  migrations: ['dist/migrations/*.js'], // Migration files
  migrationsRun: true,                 // Run migrations on startup
  ssl: false,                          // SSL connection
  extra: {                             // Extra connection options
    max: 10,                           // Connection pool size
  },
}
```

---

### 5.3. Entity Registration

#### Feature Module Registration

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { UserService } from './user.service';
import { UserController } from './user.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService],
})
export class UserModule {}
```

**What `forFeature()` does:**
- Registers entities for this module
- Makes `Repository<User>` available for injection
- Scopes repositories to this module

---

### 5.4. Repository Pattern

#### Injecting Repository

```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  async findOne(id: string): Promise<User> {
    return this.userRepository.findOne({ where: { id } });
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    await this.userRepository.update(id, updateUserDto);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.userRepository.delete(id);
  }
}
```

---

## 6. TypeORM

TypeORM is an ORM that can run in Node.js and supports many databases.

---

### 6.1. Entity Definition

#### Basic Entity

```typescript
import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  email: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ type: 'int' })
  age: number;

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @Column({ type: 'timestamp', onUpdate: 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}
```

---

### 6.2. Column Decorators

#### Column Types

```typescript
@Entity()
export class User {
  @Column('varchar', { length: 100 })
  name: string;

  @Column('int')
  age: number;

  @Column('decimal', { precision: 10, scale: 2 })
  salary: number;

  @Column('text')
  description: string;

  @Column('boolean', { default: true })
  isActive: boolean;

  @Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @Column('json')
  metadata: object;

  @Column('array')
  tags: string[];
}
```

#### Column Options

```typescript
@Column({
  type: 'varchar',
  length: 255,
  nullable: false,
  unique: true,
  default: 'default value',
  comment: 'User email address',
  name: 'email_address',  // Custom column name
})
email: string;
```

---

### 6.3. Relationships

#### One-to-Many

```typescript
@Entity()
export class User {
  @OneToMany(() => Post, post => post.user)
  posts: Post[];
}

@Entity()
export class Post {
  @ManyToOne(() => User, user => user.posts)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
```

#### Many-to-Many

```typescript
@Entity()
export class User {
  @ManyToMany(() => Role)
  @JoinTable()
  roles: Role[];
}

@Entity()
export class Role {
  @ManyToMany(() => User, user => user.roles)
  users: User[];
}
```

#### One-to-One

```typescript
@Entity()
export class User {
  @OneToOne(() => Profile)
  @JoinColumn()
  profile: Profile;
}

@Entity()
export class Profile {
  @OneToOne(() => User, user => user.profile)
  user: User;
}
```

---

### 6.4. Repository Methods

#### Common Repository Methods

```typescript
// Find methods
await repository.find();                           // Find all
await repository.findOne({ where: { id: 1 } });   // Find one
await repository.findBy({ email: 'test@test.com' }); // Find by criteria
await repository.findOneBy({ id: 1 });            // Find one by criteria
await repository.findAndCount();                  // Find with count
await repository.count();                          // Count records
await repository.exists({ where: { id: 1 } });    // Check existence

// Create/Update
const user = repository.create({ email: 'test@test.com' });
await repository.save(user);                       // Save (insert or update)
await repository.insert({ email: 'test@test.com' }); // Insert
await repository.update({ id: 1 }, { email: 'new@test.com' }); // Update
await repository.upsert({ id: 1, email: 'test@test.com' }, ['id']); // Upsert

// Delete
await repository.delete({ id: 1 });               // Delete
await repository.remove(user);                    // Remove entity
await repository.softDelete({ id: 1 });           // Soft delete
await repository.restore({ id: 1 });             // Restore soft deleted

// Relations
await repository.find({ relations: ['posts'] });  // Load relations
await repository.findOne({ where: { id: 1 }, relations: ['posts'] });
```

---

### 6.5. Query Builder

#### Using Query Builder

```typescript
// Basic query
const users = await repository
  .createQueryBuilder('user')
  .where('user.age > :age', { age: 18 })
  .andWhere('user.isActive = :isActive', { isActive: true })
  .orderBy('user.createdAt', 'DESC')
  .take(10)
  .skip(0)
  .getMany();

// With relations
const users = await repository
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.posts', 'post')
  .where('user.id = :id', { id: userId })
  .getOne();

// Aggregations
const result = await repository
  .createQueryBuilder('user')
  .select('AVG(user.age)', 'avgAge')
  .addSelect('COUNT(user.id)', 'count')
  .getRawOne();
```

---

### 6.6. Migrations

#### Creating Migrations

```bash
# Generate migration
npm run typeorm migration:generate -- -n CreateUserTable

# Run migrations
npm run typeorm migration:run

# Revert migration
npm run typeorm migration:revert
```

#### Migration File

```typescript
import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateUserTable1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'users',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'email',
            type: 'varchar',
            length: '255',
            isUnique: true,
          },
          {
            name: 'firstName',
            type: 'varchar',
            length: '100',
          },
        ],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('users');
  }
}
```

---

## 7. pg (PostgreSQL Driver)

The official PostgreSQL client for Node.js.

---

### 7.1. PostgreSQL Connection

TypeORM uses `pg` under the hood when you specify `type: 'postgres'`.

#### Direct pg Usage (Not Recommended with TypeORM)

```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'password',
  database: 'mydb',
  max: 20,                    // Maximum pool size
  idleTimeoutMillis: 30000,   // Close idle clients after 30s
  connectionTimeoutMillis: 2000, // Return error after 2s if connection fails
});

// Query
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
```

**Note:** With TypeORM, you don't need to use `pg` directly. TypeORM handles the connection.

---

### 7.2. Connection Pooling

TypeORM automatically manages connection pooling when using `@nestjs/typeorm`.

#### Pool Configuration

```typescript
TypeOrmModule.forRoot({
  // ... other options
  extra: {
    max: 10,                    // Maximum pool size
    min: 2,                     // Minimum pool size
    idleTimeoutMillis: 30000,   // Idle timeout
    connectionTimeoutMillis: 2000,
  },
})
```

---

## 8. class-validator

Provides decorator-based validation for classes.

---

### 8.1. Validation Decorators

#### Common Validators

```typescript
import {
  IsString,
  IsEmail,
  IsNumber,
  IsBoolean,
  IsOptional,
  IsNotEmpty,
  MinLength,
  MaxLength,
  Min,
  Max,
  IsArray,
  IsEnum,
  IsUUID,
  IsDateString,
  Matches,
  ValidateNested,
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(50)
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsNumber()
  @Min(18)
  @Max(100)
  age: number;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsEnum(['admin', 'user', 'guest'])
  role: string;

  @IsUUID()
  companyId: string;

  @IsDateString()
  birthDate: string;

  @Matches(/^[A-Z0-9]+$/, { message: 'Code must be uppercase alphanumeric' })
  code: string;
}
```

---

### 8.2. Built-in Validators

#### Validation Decorators Reference

**String Validators:**
- `@IsString()` - Must be a string
- `@IsNotEmpty()` - Must not be empty
- `@MinLength(n)` - Minimum length
- `@MaxLength(n)` - Maximum length
- `@Length(min, max)` - Length range
- `@Matches(regex)` - Match regex pattern
- `@IsEmail()` - Valid email format
- `@IsUrl()` - Valid URL format
- `@IsUUID()` - Valid UUID format

**Number Validators:**
- `@IsNumber()` - Must be a number
- `@Min(n)` - Minimum value
- `@Max(n)` - Maximum value
- `@IsInt()` - Must be an integer
- `@IsPositive()` - Must be positive
- `@IsNegative()` - Must be negative

**Array Validators:**
- `@IsArray()` - Must be an array
- `@ArrayMinSize(n)` - Minimum array size
- `@ArrayMaxSize(n)` - Maximum array size
- `@ArrayUnique()` - All elements must be unique

**Other Validators:**
- `@IsBoolean()` - Must be boolean
- `@IsDate()` - Must be a date
- `@IsDateString()` - Must be a date string
- `@IsEnum()` - Must be enum value
- `@IsOptional()` - Field is optional
- `@IsDefined()` - Field must be defined
- `@ValidateNested()` - Validate nested object
- `@IsObject()` - Must be an object

---

### 8.3. Custom Validators

#### Creating Custom Validator

```typescript
import { registerDecorator, ValidationOptions, ValidationArguments } from 'class-validator';

export function IsStrongPassword(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isStrongPassword',
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      validator: {
        validate(value: any, args: ValidationArguments) {
          // At least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
          const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
          return typeof value === 'string' && regex.test(value);
        },
        defaultMessage(args: ValidationArguments) {
          return 'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
        },
      },
    });
  };
}

// Usage
export class CreateUserDto {
  @IsStrongPassword()
  password: string;
}
```

---

### 8.4. Validation in DTOs

#### Complete DTO Example

```typescript
import { IsEmail, IsString, MinLength, IsOptional, ValidateNested, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';

class AddressDto {
  @IsString()
  @IsNotEmpty()
  street: string;

  @IsString()
  @IsNotEmpty()
  city: string;

  @IsString()
  @IsNotEmpty()
  country: string;

  @IsString()
  @IsOptional()
  zipCode?: string;
}

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ValidateNested()
  @Type(() => AddressDto)
  address: AddressDto;

  @IsOptional()
  @IsString()
  phone?: string;
}
```

#### Using DTOs in Controllers

```typescript
import { Controller, Post, Body } from '@nestjs/common';
import { ValidationPipe } from '@nestjs/common';

@Controller('users')
export class UsersController {
  @Post()
  create(@Body(ValidationPipe) createUserDto: CreateUserDto) {
    // createUserDto is automatically validated
    return this.usersService.create(createUserDto);
  }
}
```

#### Global Validation Pipe

```typescript
// main.ts
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable validation globally
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip properties that don't have decorators
      forbidNonWhitelisted: true, // Throw error if non-whitelisted properties exist
      transform: true, // Automatically transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Enable implicit type conversion
      },
    }),
  );
  
  await app.listen(3000);
}
```

#### Validation Error Response

When validation fails, NestJS automatically returns a 400 Bad Request with error details:

```json
{
  "statusCode": 400,
  "message": [
    "firstName must be longer than or equal to 3 characters",
    "email must be an email",
    "address must be an object"
  ],
  "error": "Bad Request"
}
```

---

## 9. class-transformer

`class-transformer` is a library that transforms plain JavaScript objects to class instances and vice versa. It's essential for converting JSON data to DTOs and transforming data for responses.

---

### 9.1. Transformation Decorators

#### Common Transformation Decorators

**@Expose()** - Include property in transformation:
```typescript
import { Expose } from 'class-transformer';

export class UserDto {
  @Expose()
  id: number;

  @Expose()
  email: string;
}
```

**@Exclude()** - Exclude property from transformation:
```typescript
import { Exclude } from 'class-transformer';

export class UserDto {
  @Expose()
  id: number;

  @Exclude()
  password: string; // Won't be included in response
}
```

**@Type()** - Specify nested object type:
```typescript
import { Type } from 'class-transformer';

class AddressDto {
  street: string;
  city: string;
}

export class UserDto {
  @Type(() => AddressDto)
  address: AddressDto;
}
```

**@Transform()** - Custom transformation:
```typescript
import { Transform } from 'class-transformer';

export class UserDto {
  @Transform(({ value }) => value.toUpperCase())
  name: string; // Will be transformed to uppercase
}
```

---

### 9.2. Exclude/Expose Properties

#### Excluding Sensitive Data

```typescript
import { Exclude, Expose } from 'class-transformer';

export class User {
  id: number;
  email: string;
  
  @Exclude()
  password: string; // Never exposed

  @Exclude()
  internalNotes: string; // Never exposed
}

// Transform to plain object
const user = new User();
user.id = 1;
user.email = 'user@example.com';
user.password = 'secret123';
user.internalNotes = 'Admin notes';

const plain = instanceToPlain(user);
// Result: { id: 1, email: 'user@example.com' }
// password and internalNotes are excluded
```

#### Conditional Expose

```typescript
import { Expose } from 'class-transformer';

export class UserDto {
  @Expose()
  id: number;

  @Expose()
  email: string;

  @Expose({ groups: ['admin'] })
  role: string; // Only exposed when 'admin' group is used
}

// Usage
const plain = instanceToPlain(user, { groups: ['admin'] });
```

---

### 9.3. Type Transformation

#### Converting Plain Objects to Class Instances

```typescript
import { plainToInstance } from 'class-transformer';

// Plain JavaScript object from API
const userData = {
  id: 1,
  email: 'user@example.com',
  createdAt: '2024-01-01T00:00:00Z'
};

// Transform to User class instance
const user = plainToInstance(User, userData);
// user is now an instance of User class
```

#### Handling Nested Objects

```typescript
import { Type, plainToInstance } from 'class-transformer';

class AddressDto {
  street: string;
  city: string;
}

class UserDto {
  id: number;
  
  @Type(() => AddressDto)
  address: AddressDto;
}

// Plain object with nested data
const userData = {
  id: 1,
  address: {
    street: '123 Main St',
    city: 'New York'
  }
};

// Transform with nested type
const user = plainToInstance(UserDto, userData);
// user.address is now an instance of AddressDto
```

#### Date Transformation

```typescript
import { Transform } from 'class-transformer';

export class UserDto {
  @Transform(({ value }) => new Date(value))
  createdAt: Date; // String will be converted to Date
}
```

---

### 9.4. Plain to Class Conversion

#### Complete Example

```typescript
import { Exclude, Expose, Type, Transform, plainToInstance, instanceToPlain } from 'class-transformer';

// Entity class
export class User {
  id: number;
  email: string;
  
  @Exclude()
  password: string;

  @Transform(({ value }) => value.toUpperCase())
  firstName: string;

  @Type(() => Date)
  createdAt: Date;
}

// DTO for response
export class UserResponseDto {
  @Expose()
  id: number;

  @Expose()
  email: string;

  @Expose()
  firstName: string;

  @Expose()
  @Transform(({ value }) => value.toISOString())
  createdAt: Date;
}

// Usage in service
export class UsersService {
  async findOne(id: number) {
    const user = await this.userRepository.findOne({ where: { id } });
    
    // Convert entity to DTO
    const userDto = plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true, // Only include @Expose() properties
    });
    
    return userDto;
  }
}
```

#### Using in Controllers

```typescript
import { Controller, Get, UseInterceptors, ClassSerializerInterceptor } from '@nestjs/common';

@Controller('users')
@UseInterceptors(ClassSerializerInterceptor) // Automatically uses class-transformer
export class UsersController {
  @Get()
  findAll() {
    // Response will automatically exclude @Exclude() properties
    return this.usersService.findAll();
  }
}
```

#### Manual Transformation

```typescript
import { plainToInstance, instanceToPlain } from 'class-transformer';

// From JSON to class
const jsonData = '{"id": 1, "email": "user@example.com"}';
const user = plainToInstance(User, JSON.parse(jsonData));

// From class to plain object
const plainObject = instanceToPlain(user);
const jsonString = JSON.stringify(plainObject);
```

---

## 10. reflect-metadata

`reflect-metadata` is a polyfill library that adds support for metadata reflection API. It's essential for NestJS decorators and dependency injection to work properly.

---

### 10.1. Metadata Reflection

#### What is Metadata?

Metadata is "data about data" - additional information stored about classes, methods, and properties. NestJS uses metadata to understand:

- Which class is a module, controller, or service
- What dependencies a class needs
- What HTTP routes are defined
- What validation rules apply

#### Why It's Needed

TypeScript decorators can attach metadata to classes, but JavaScript doesn't natively support reading this metadata at runtime. `reflect-metadata` provides this capability.

```typescript
// Without reflect-metadata, this wouldn't work:
@Injectable()
export class UsersService {
  constructor(
    @Inject('USER_REPOSITORY')
    private userRepository: Repository<User>,
  ) {}
}
```

---

### 10.2. Decorator Metadata

#### How NestJS Uses Metadata

**1. Module Metadata:**
```typescript
@Module({
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
```

NestJS stores:
- `controllers`: Array of controller classes
- `providers`: Array of provider classes
- `imports`: Array of imported modules

**2. Injectable Metadata:**
```typescript
@Injectable()
export class UsersService {}
```

Marks the class as injectable into other classes.

**3. Controller Metadata:**
```typescript
@Controller('users')
export class UsersController {
  @Get()
  findAll() {}
}
```

NestJS stores:
- Route path: `'users'`
- HTTP method: `GET`
- Handler method: `findAll`

**4. Parameter Metadata:**
```typescript
@Get(':id')
findOne(@Param('id') id: string) {}
```

NestJS stores:
- Parameter name: `'id'`
- Parameter type: `string`
- Decorator type: `@Param()`

#### Custom Metadata Example

```typescript
import 'reflect-metadata';

const METADATA_KEY = Symbol('custom-metadata');

// Define decorator
function CustomDecorator(value: string) {
  return function (target: any, propertyKey: string) {
    Reflect.defineMetadata(METADATA_KEY, value, target, propertyKey);
  };
}

// Use decorator
class MyClass {
  @CustomDecorator('my-value')
  myMethod() {}
}

// Read metadata
const value = Reflect.getMetadata(METADATA_KEY, MyClass.prototype, 'myMethod');
console.log(value); // 'my-value'
```

#### Required Import

**Important:** `reflect-metadata` must be imported at the top of your main file:

```typescript
// main.ts - MUST be first import
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
```

Without this import, NestJS decorators won't work properly.

---

## 11. rxjs

RxJS (Reactive Extensions for JavaScript) is a library for reactive programming using Observables. NestJS uses RxJS extensively for handling asynchronous operations, especially in HTTP handlers.

---

### 11.1. Observables in NestJS

#### What are Observables?

Observables represent a stream of values over time. They're similar to Promises but can emit multiple values.

**Promise (single value):**
```typescript
const promise = fetch('/api/users');
promise.then(data => console.log(data));
```

**Observable (multiple values):**
```typescript
const observable = new Observable(observer => {
  observer.next('value1');
  observer.next('value2');
  observer.complete();
});
```

#### Observable in NestJS Controllers

```typescript
import { Controller, Get } from '@nestjs/common';
import { Observable } from 'rxjs';

@Controller('users')
export class UsersController {
  @Get()
  findAll(): Observable<User[]> {
    // Return Observable directly
    return this.usersService.findAll();
  }
}
```

NestJS automatically subscribes to the Observable and sends the result as HTTP response.

---

### 11.2. Async Operations

#### Returning Observables from Services

```typescript
import { Injectable } from '@nestjs/common';
import { Observable, of } from 'rxjs';

@Injectable()
export class UsersService {
  findAll(): Observable<User[]> {
    // Create Observable from array
    return of([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' },
    ]);
  }
}
```

#### Converting Promises to Observables

```typescript
import { from } from 'rxjs';

@Injectable()
export class UsersService {
  async findAll(): Promise<User[]> {
    return await this.userRepository.find();
  }

  // Convert Promise to Observable
  findAllObservable(): Observable<User[]> {
    return from(this.findAll());
  }
}
```

#### Combining Multiple Async Operations

```typescript
import { forkJoin, Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class UsersService {
  getUserData(userId: number): Observable<any> {
    // Run multiple async operations in parallel
    return forkJoin({
      user: this.userRepository.findOne({ where: { id: userId } }),
      posts: this.postRepository.find({ where: { userId } }),
      comments: this.commentRepository.find({ where: { userId } }),
    });
  }
}
```

---

### 11.3. Error Handling

#### Catching Errors in Observables

```typescript
import { catchError, throwError } from 'rxjs';
import { HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class UsersService {
  findOne(id: number): Observable<User> {
    return from(this.userRepository.findOne({ where: { id } })).pipe(
      catchError(error => {
        if (error.code === 'NOT_FOUND') {
          return throwError(() => 
            new HttpException('User not found', HttpStatus.NOT_FOUND)
          );
        }
        return throwError(() => 
          new HttpException('Internal server error', HttpStatus.INTERNAL_SERVER_ERROR)
        );
      }),
    );
  }
}
```

#### Using Operators

```typescript
import { map, filter, tap } from 'rxjs/operators';

@Injectable()
export class UsersService {
  getActiveUsers(): Observable<User[]> {
    return from(this.userRepository.find()).pipe(
      map(users => users.filter(user => user.isActive)),
      tap(users => console.log(`Found ${users.length} active users`)),
    );
  }
}
```

#### Common RxJS Operators in NestJS

**map** - Transform values:
```typescript
.pipe(map(user => user.email))
```

**filter** - Filter values:
```typescript
.pipe(filter(user => user.isActive))
```

**catchError** - Handle errors:
```typescript
.pipe(catchError(error => throwError(() => new Error('Failed'))))
```

**tap** - Side effects (logging, etc.):
```typescript
.pipe(tap(user => console.log(user)))
```

**switchMap** - Switch to new Observable:
```typescript
.pipe(switchMap(user => this.getUserDetails(user.id)))
```

#### Complete Example

```typescript
import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { Observable, from, throwError } from 'rxjs';
import { map, catchError, switchMap } from 'rxjs/operators';

@Injectable()
export class UsersService {
  getUserWithDetails(id: number): Observable<any> {
    return from(this.userRepository.findOne({ where: { id } })).pipe(
      switchMap(user => {
        if (!user) {
          return throwError(() => 
            new HttpException('User not found', HttpStatus.NOT_FOUND)
          );
        }
        return from(this.getUserDetails(user.id)).pipe(
          map(details => ({ ...user, details })),
        );
      }),
      catchError(error => {
        if (error instanceof HttpException) {
          return throwError(() => error);
        }
        return throwError(() => 
          new HttpException('Internal error', HttpStatus.INTERNAL_SERVER_ERROR)
        );
      }),
    );
  }
}
```

---

## Summary

This documentation covers all the major libraries and concepts used in the NestJS `user-management-api` project:

1. **NestJS Core** - Framework foundation, modules, controllers, services
2. **Configuration** - Environment variables and configuration management
3. **Database** - TypeORM integration with PostgreSQL
4. **Validation** - Input validation with class-validator
5. **Transformation** - Data transformation with class-transformer
6. **Metadata** - Reflection API for decorators
7. **Reactive Programming** - RxJS for async operations

Each library plays a crucial role in building a robust, scalable NestJS application. Understanding these concepts will help you build efficient and maintainable backend APIs.

---

**Note:** This documentation is based on the libraries used in the `user-management-api` project. For the most up-to-date information, refer to the official documentation of each library.
