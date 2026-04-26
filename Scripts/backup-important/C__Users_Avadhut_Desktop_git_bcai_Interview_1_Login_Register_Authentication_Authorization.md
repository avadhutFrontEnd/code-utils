# Login, Register, Authentication & Authorization Flow - Detailed Diagrams

## 1. Login Page (`/auth/login`)

### Backend API

**Endpoint:** POST `/api/v1/auth/email/login`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenExpires": 1234567890,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": { "id": 2, "name": "Designer" },
    "status": { "id": 1, "name": "Active" },
    "profile": { "name": "User Name", "credit": "100" }
  }
}
```

**Response (Error - 422):**
```json
{
  "status": 422,
  "errors": {
    "email": "notFound" | "emailNotVerified" | "needLoginViaProvider:google",
    "password": "incorrectPassword",
    "status": "notActive"
  }
}
```

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FRONTEND - Login Page                              │
└─────────────────────────────────────────────────────────────────────────────┘

User Action:
  ↓
User enters email & password
  ↓
User clicks "Login" button
  ↓
Frontend Validation:
  - Email format check
  - Password not empty
  ↓
Data Prepared:
  {
    email: "user@example.com",
    password: "password123"
  }
  ↓
API Call: POST /api/v1/auth/email/login
  Headers: { "Content-Type": "application/json" }
  Body: { email, password }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/auth/email/login
  ↓
Controller: AuthController.login()
  Input: loginDto (AuthEmailLoginDto)
    {
      email: "user@example.com",
      password: "password123"
    }
  ↓
  Calls: AuthService.validateLogin(loginDto)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.validateLogin()
  Input: loginDto { email, password }
  ↓
  Step 1: UsersService.findByEmail(email)
    Input: email = "user@example.com"
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - User Lookup                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "user" 
         WHERE email = $1 AND "deletedAt" IS NULL
         LEFT JOIN profile ON profile."userId" = "user".id
    
    Input: email = "user@example.com"
    ↓
    Output: User entity OR null
      If found:
      {
        id: 1,
        email: "user@example.com",
        password: "$2a$10$hashed...",
        provider: "email",
        roleId: 2,
        statusId: 1,
        isEmailVerified: true,
        profile: { name: "User Name", credit: "100" }
      }
    ↓
    Returns: User object OR null
  ↓
  Validation Check 1: if (!user)
    If true → Throw Error: { email: "notFound" }
    If false → Continue
  ↓
  Validation Check 2: if (user.provider !== "email")
    If true → Throw Error: { email: "needLoginViaProvider:google" }
    If false → Continue
  ↓
  Validation Check 3: if (!user.password)
    If true → Throw Error: { password: "incorrectPassword" }
    If false → Continue
  ↓
  Validation Check 4: if (!user.isEmailVerified)
    If true → Throw Error: { email: "emailNotVerified" }
    If false → Continue
  ↓
  Validation Check 5: if (user.status.name === "Inactive")
    If true → Throw Error: { status: "notActive" }
    If false → Continue
  ↓
  Step 2: bcrypt.compare(password, user.password)
    Input: 
      - Plain password: "password123"
      - Hashed password: "$2a$10$hashed..."
    ↓
    Output: boolean (true/false)
    ↓
    If false → Throw Error: { password: "incorrectPassword" }
    If true → Continue
  ↓
  Step 3: Generate Session Hash
    crypto.createHash('sha256')
      .update(randomStringGenerator())
      .digest('hex')
    ↓
    Output: hash = "a1b2c3d4e5f6..."
  ↓
  Step 4: SessionService.create({ user, hash })
    Input: { user, hash }
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Session Creation                 │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: INSERT INTO "session" (hash, "userId", "createdAt", "updatedAt")
         VALUES ($1, $2, NOW(), NOW())
         RETURNING *
    
    Input: 
      hash = "a1b2c3d4e5f6..."
      userId = 1
    ↓
    Output: Session entity
    {
      id: 123,
      hash: "a1b2c3d4e5f6...",
      userId: 1,
      createdAt: "2024-01-01T10:00:00Z",
      updatedAt: "2024-01-01T10:00:00Z"
    }
    ↓
    Returns: Session object
  ↓
  Step 5: AuthService.getTokensData({ user, session })
    Input: { user, session }
    ↓
    Generate Access Token:
      JwtService.signAsync({
        id: user.id,
        role: user.role,
        sessionId: session.id
      }, {
        secret: config.auth.secret,
        expiresIn: "1d"
      })
      ↓
      Output: token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ↓
    Generate Refresh Token:
      JwtService.signAsync({
        sessionId: session.id,
        hash: session.hash
      }, {
        secret: config.auth.refreshSecret,
        expiresIn: "7d"
      })
      ↓
      Output: refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ↓
    Calculate Token Expires:
      tokenExpires = Date.now() + ms("1d")
      ↓
      Output: tokenExpires = 1234567890
    ↓
    Returns: { token, refreshToken, tokenExpires }
  ↓
  Returns: LoginResponseDto
  {
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    tokenExpires: 1234567890,
    user: {
      id: 1,
      email: "user@example.com",
      role: { id: 2, name: "Designer" },
      status: { id: 1, name: "Active" },
      profile: { name: "User Name", credit: "100" }
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.login()
  Returns: LoginResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    token: "...",
    refreshToken: "...",
    tokenExpires: 1234567890,
    user: { ... }
  }
  ↓
Frontend Actions:
  1. Store tokens:
     - localStorage.setItem('accessToken', token)
     - localStorage.setItem('refreshToken', refreshToken)
  2. Update Redux state:
     - dispatch(setUserAuth(true))
     - dispatch(setUserProfile(user))
  3. Show success notification: "Login success."
  ↓
Post-Login Redirect Logic:
  - Check for redirect URL in state/localStorage
  - If exists → Navigate to redirect URL
  - If not → Default redirect to /create
  ↓
Navigate to: /create page
  ↓
User is now authenticated and on the create page
```

### Database Table Structure

**User Table:**
```sql
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password VARCHAR,                    -- Bcrypt hashed (null for social logins)
  provider VARCHAR NOT NULL DEFAULT 'email',  -- 'email', 'google', 'microsoft'
  socialId VARCHAR,                   -- OAuth provider user ID
  roleId INTEGER REFERENCES role(id),  -- 1=SuperAdmin, 2=Designer, 3=Admin, 4=Client
  statusId INTEGER REFERENCES status(id),    -- 1=Active, 2=Inactive
  isEmailVerified BOOLEAN DEFAULT false,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP                 -- Soft delete (null = active)
);
```

**Session Table:**
```sql
CREATE TABLE "session" (
  id SERIAL PRIMARY KEY,
  hash VARCHAR NOT NULL,              -- SHA256 hash for refresh token validation
  userId INTEGER REFERENCES "user"(id),
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP                 -- Soft delete (null = active)
);
```

**Role Table:**
```sql
CREATE TABLE role (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
-- Values: 1=SuperAdmin, 2=Designer, 3=Admin, 4=Client
```

**Status Table:**
```sql
CREATE TABLE status (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
-- Values: 1=Active, 2=Inactive
```

**Profile Table:**
```sql
CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  credit VARCHAR DEFAULT '0',
  userId INTEGER UNIQUE REFERENCES "user"(id),
  resetCode TEXT,                     -- For password reset
  resetCodeExpires TIMESTAMP,         -- Password reset code expiration
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

---

## 2. Registration Page (`/auth/sign-up`)

### Backend API

**Endpoint:** POST `/api/v1/auth/email/register`

**Request:**
```json
{
  "email": "user@example.com",
  "name": "User Name",
  "password": "Password123!@#",
  "role": 2,
  "status": 2
}
```

**Response (Success):**
```json
{
  "message": "Registration successful. Please check your email to verify your account before logging in.",
  "email": "user@example.com"
}
```

**Response (Error - 422):**
```json
{
  "status": 422,
  "errors": {
    "email": "emailAlreadyExists" | "emailSendFailed",
    "role": "roleNotExists",
    "status": "statusNotExists"
  }
}
```

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Registration Page                           │
└─────────────────────────────────────────────────────────────────────────────┘

User Action:
  ↓
User fills registration form:
  - Email: "user@example.com"
  - Name: "User Name"
  - Password: "Password123!@#"
  - Confirm Password: "Password123!@#"
  - Terms checkbox: checked
  ↓
Frontend Validation:
  - Email format check
  - Password strength check (12-20 chars, uppercase, lowercase, number, special)
  - Password match check
  - Terms checkbox checked
  ↓
User clicks "Create Account" button
  ↓
Data Prepared:
  {
    email: "user@example.com",
    name: "User Name",
    password: "Password123!@#",
    role: 2,        // Default: Designer
    status: 2       // Default: Inactive
  }
  ↓
API Call: POST /api/v1/auth/email/register
  Headers: { "Content-Type": "application/json" }
  Body: { email, name, password, role, status }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/auth/email/register
  ↓
Controller: AuthController.register()
  Input: registerDto (AuthRegisterLoginDto)
    {
      email: "user@example.com",
      name: "User Name",
      password: "Password123!@#",
      role: 2,
      status: 2
    }
  ↓
  Calls: AuthService.register(registerDto)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.register()
  Input: registerDto { email, name, password, role, status }
  ↓
  Step 1: Check if email already exists
    UsersService.findByEmail(email)
    Input: email = "user@example.com"
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - Email Check                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "user" 
         WHERE email = $1 AND "deletedAt" IS NULL
    
    Input: email = "user@example.com"
    ↓
    Output: User entity OR null
    ↓
    If user exists → Throw Error: { email: "emailAlreadyExists" }
    If null → Continue
  ↓
  Step 2: Hash Password
    bcrypt.hash(password, saltRounds)
    Input: password = "Password123!@#"
    ↓
    Output: hashedPassword = "$2a$10$hashed..."
  ↓
  Step 3: UsersService.create(userData)
    Input: {
      email: "user@example.com",
      password: "$2a$10$hashed...",
      provider: "email",
      roleId: 2,              // Designer
      statusId: 2,            // Inactive
      isEmailVerified: false
    }
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │              DATABASE TRANSACTION - User Creation                    │
    └─────────────────────────────────────────────────────────────────────┘
    
    BEGIN TRANSACTION;
    
    SQL 1: INSERT INTO "user" 
           (email, password, provider, "roleId", "statusId", "isEmailVerified", "createdAt", "updatedAt")
           VALUES ($1, $2, 'email', $3, $4, false, NOW(), NOW())
           RETURNING *
    
    Input: 
      email = "user@example.com"
      password = "$2a$10$hashed..."
      roleId = 2
      statusId = 2
    ↓
    Output: User entity
    {
      id: 1,
      email: "user@example.com",
      password: "$2a$10$hashed...",
      provider: "email",
      roleId: 2,
      statusId: 2,
      isEmailVerified: false,
      createdAt: "2024-01-01T10:00:00Z",
      updatedAt: "2024-01-01T10:00:00Z"
    }
    ↓
    SQL 2: INSERT INTO profile 
           (name, credit, "userId", "createdAt", "updatedAt")
           VALUES ($1, '100', $2, NOW(), NOW())
           RETURNING *
    
    Input:
      name = "User Name"
      userId = 1
    ↓
    Output: Profile entity
    {
      id: "uuid-1234...",
      name: "User Name",
      credit: "100",
      userId: 1,
      createdAt: "2024-01-01T10:00:00Z",
      updatedAt: "2024-01-01T10:00:00Z"
    }
    ↓
    COMMIT;
    ↓
    Returns: User object with profile
  ↓
  Step 4: Generate Email Confirmation Hash
    JwtService.signAsync({
      confirmEmailUserId: user.id
    }, {
      secret: config.auth.confirmEmailSecret,
      expiresIn: "24h"
    })
    ↓
    Output: hash = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  ↓
  Step 5: MailService.userSignUp({ to: email, data: { hash, userName } })
    Input: {
      to: "user@example.com",
      data: {
        hash: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        userName: "User Name"
      }
    }
    ↓
    Build Verification URL:
      url = "https://frontend.com/auth/confirm-email?hash=..."
    ↓
    Send Email via SMTP:
      - Template: activation.hbs
      - Subject: "Email Verification"
      - To: "user@example.com"
      - Contains: Verification link with hash
    ↓
    If email send fails → Rollback: Delete user
      SQL: DELETE FROM "user" WHERE id = $1
      Throw Error: { email: "emailSendFailed" }
    ↓
    If email send succeeds → Continue
  ↓
  Step 6: AuthService.notifySuperAdminsOfNewUser(user)
    Input: user object
    ↓
    Find all SuperAdmin users:
      SQL: SELECT * FROM "user" 
           WHERE "roleId" = 1 AND "deletedAt" IS NULL
    ↓
    For each SuperAdmin:
      MailService.sendNewUserNotification({
        to: superAdmin.email,
        data: {
          adminName: superAdmin.profile.name,
          newUserName: user.profile.name,
          newUserEmail: user.email,
          newUserRole: user.role.name,
          newUserStatus: user.status.name,
          userId: user.id,
          registrationDate: user.createdAt
        }
      })
      ↓
      Send Email via SMTP:
        - Template: new-user-notification.hbs
        - Subject: "New User Registration"
        - To: superAdmin.email
    ↓
    Returns: void (non-blocking, errors logged but not thrown)
  ↓
  Returns: RegistrationResponseDto
  {
    message: "Registration successful. Please check your email to verify your account before logging in.",
    email: "user@example.com"
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                             │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.register()
  Returns: RegistrationResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    message: "Registration successful...",
    email: "user@example.com"
  }
  ↓
Frontend Actions:
  1. Show success notification: "Registration successful! A verification email has been sent..."
  2. User stays on registration page (NOT authenticated)
  3. User must check email and verify account
  ↓
User receives verification email
  ↓
User clicks verification link
  ↓
Navigate to: /auth/email-confirm?hash=...
  ↓
(Continues to Email Confirmation flow)
```

### Database Table Structure

**User Table:**
```sql
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password VARCHAR,                    -- Bcrypt hashed
  provider VARCHAR NOT NULL DEFAULT 'email',
  socialId VARCHAR,
  roleId INTEGER REFERENCES role(id),  -- Default: 2 (Designer)
  statusId INTEGER REFERENCES status(id), -- Default: 2 (Inactive)
  isEmailVerified BOOLEAN DEFAULT false,  -- Starts as false
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP
);
```

**Profile Table:**
```sql
CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  credit VARCHAR DEFAULT '100',        -- Default 100 credits
  userId INTEGER UNIQUE REFERENCES "user"(id),
  resetCode TEXT,
  resetCodeExpires TIMESTAMP,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

---

## 3. Email Confirmation (`/auth/email-confirm`)

### Backend API

**Endpoint:** POST `/api/v1/auth/email/confirm`

**Request:**
```json
{
  "hash": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:** 204 No Content (success)

**Response (Error - 422):**
```json
{
  "status": 422,
  "errors": {
    "hash": "invalidHash"
  }
}
```

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FRONTEND - Email Confirmation Page                       │
└─────────────────────────────────────────────────────────────────────────────┘

User Action:
  ↓
User receives verification email
  ↓
User clicks verification link in email
  ↓
URL: /auth/email-confirm?hash=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  ↓
Frontend extracts hash from URL query parameter
  ↓
Frontend shows loading state: "Confirming Email..."
  ↓
Data Prepared:
  {
    hash: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ↓
API Call: POST /api/v1/auth/email/confirm
  Headers: { "Content-Type": "application/json" }
  Body: { hash }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/auth/email/confirm
  ↓
Controller: AuthController.confirmEmail()
  Input: confirmEmailDto { hash }
    {
      hash: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  ↓
  Calls: AuthService.confirmEmail(confirmEmailDto)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.confirmEmail()
  Input: confirmEmailDto { hash }
  ↓
  Step 1: Verify JWT Hash
    JwtService.verifyAsync(hash, {
      secret: config.auth.confirmEmailSecret
    })
    Input: hash = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ↓
    If invalid/expired → Throw Error: { hash: "invalidHash" }
    If valid → Extract payload
    ↓
    Output: Decoded token payload
    {
      confirmEmailUserId: 1,
      iat: 1234567890,
      exp: 1234654290
    }
  ↓
  Step 2: UsersService.findById(userId)
    Input: userId = 1
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - User Lookup                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "user" 
         WHERE id = $1 AND "deletedAt" IS NULL
         LEFT JOIN role ON "user"."roleId" = role.id
         LEFT JOIN status ON "user"."statusId" = status.id
         LEFT JOIN profile ON profile."userId" = "user".id
    
    Input: userId = 1
    ↓
    Output: User entity OR null
      If found:
      {
        id: 1,
        email: "user@example.com",
        isEmailVerified: false,
        statusId: 2,
        role: { id: 2, name: "Designer" },
        status: { id: 2, name: "Inactive" },
        profile: { name: "User Name", credit: "100" }
      }
    ↓
    If null → Throw Error: { hash: "invalidHash" }
    If found → Continue
  ↓
  Step 3: Check if already verified
    if (user.isEmailVerified === true)
      → Already verified, return success (idempotent)
    if (user.isEmailVerified === false)
      → Continue to update
  ↓
  Step 4: UsersService.update(userId, { isEmailVerified: true })
    Input: 
      userId = 1
      updateData = { isEmailVerified: true }
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - User Update                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "user"
         SET "isEmailVerified" = true, "updatedAt" = NOW()
         WHERE id = $1 AND "deletedAt" IS NULL
         RETURNING *
    
    Input: userId = 1
    ↓
    Output: Updated User entity
    {
      id: 1,
      email: "user@example.com",
      isEmailVerified: true,        // Updated to true
      statusId: 2,                  // Still Inactive
      updatedAt: "2024-01-01T10:05:00Z"
    }
    ↓
    Returns: Updated User object
  ↓
  Step 5: AuthService.notifySuperAdminsOfEmailConfirmation(user)
    Input: user object (with isEmailVerified: true)
    ↓
    Find all SuperAdmin users:
      SQL: SELECT * FROM "user" 
           WHERE "roleId" = 1 AND "deletedAt" IS NULL
    ↓
    For each SuperAdmin:
      MailService.sendEmailConfirmationNotification({
        to: superAdmin.email,
        data: {
          adminName: superAdmin.profile.name,
          confirmedUserName: user.profile.name,
          confirmedUserEmail: user.email,
          confirmedUserRole: user.role.name,
          confirmedUserStatus: user.status.name,
          userId: user.id,
          confirmationDate: user.updatedAt
        }
      })
      ↓
      Send Email via SMTP:
        - Template: email-confirmation-notification.hbs
        - Subject: "Email Confirmation Notification"
        - To: superAdmin.email
    ↓
    Returns: void (non-blocking, errors logged but not thrown)
  ↓
  Returns: void (HTTP 204 No Content)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.confirmEmail()
  Returns: HTTP 204 No Content (success)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  HTTP 204 No Content
  ↓
Frontend Actions:
  1. Show success state: Green checkmark with "Email Confirmed!" message
  2. Show message: "Your account is now pending admin approval"
  3. Wait 2 seconds
  4. Redirect to: /auth/login
  ↓
User is on login page
  ↓
User status: Inactive (still needs SuperAdmin approval)
  ↓
User cannot login yet (status check will fail)
```

### Database Table Structure

**User Table (Updated):**
```sql
-- After email confirmation, isEmailVerified changes:
UPDATE "user"
SET "isEmailVerified" = true, "updatedAt" = NOW()
WHERE id = $1;

-- User status remains Inactive (statusId = 2) until SuperAdmin approval
```

---

## 4. SuperAdmin Approval & Revoke

### Backend API

**Endpoint:** PATCH `/api/v1/users/:id` (SuperAdmin only)

**Request (Approve):**
```json
{
  "status": { "id": 1 }
}
```

**Request (Revoke):**
```json
{
  "status": { "id": 2 }
}
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "status": { "id": 1, "name": "Active" },
  ...
}
```

### User Flow Diagram - Approve

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - SuperAdmin User Management Page                     │
└─────────────────────────────────────────────────────────────────────────────┘

SuperAdmin Action:
  ↓
SuperAdmin navigates to User Management page
  ↓
Frontend fetches user list:
  API Call: GET /api/v1/users
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  Response: List of users with status
  [
    {
      id: 1,
      email: "user@example.com",
      status: { id: 2, name: "Inactive" },
      isEmailVerified: true,
      ...
    },
    ...
  ]
  ↓
SuperAdmin sees user with status: "Inactive"
  ↓
SuperAdmin clicks "Approve" button (green button)
  ↓
Data Prepared:
  {
    status: { id: 1 }  // Active
  }
  ↓
API Call: PATCH /api/v1/users/1
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: { status: { id: 1 } }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: PATCH /api/v1/users/:id
  ↓
Guard: @UseGuards(AuthGuard('jwt'), RolesGuard)
  Role Check: Must be SuperAdmin (roleId = 1)
  ↓
Controller: UsersController.update()
  Input: 
    id = 1 (from URL parameter)
    updateUserDto = { status: { id: 1 } }
  ↓
  Calls: UsersService.update(id, updateUserDto)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: UsersService.update()
  Input: 
    id = 1
    updateData = { status: { id: 1 } }
  ↓
  Step 1: Get current user data
    UsersService.findById(id)
    Input: id = 1
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - User Lookup                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "user" 
         WHERE id = $1 AND "deletedAt" IS NULL
         LEFT JOIN role ON "user"."roleId" = role.id
         LEFT JOIN status ON "user"."statusId" = status.id
         LEFT JOIN profile ON profile."userId" = "user".id
    
    Input: id = 1
    ↓
    Output: User entity
    {
      id: 1,
      email: "user@example.com",
      statusId: 2,              // Current: Inactive
      status: { id: 2, name: "Inactive" },
      profile: { name: "User Name", credit: "100" }
    }
    ↓
    Returns: User object
  ↓
  Step 2: Check status change
    oldStatusId = user.statusId  // 2 (Inactive)
    newStatusId = updateData.status.id  // 1 (Active)
    ↓
    statusChanged = (oldStatusId !== newStatusId)  // true
    statusChangedToActive = (oldStatusId === 2 && newStatusId === 1)  // true
  ↓
  Step 3: Update user status
    UsersService.updateStatus(id, newStatusId)
    Input: id = 1, statusId = 1
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Status Update                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "user"
         SET "statusId" = $1, "updatedAt" = NOW()
         WHERE id = $2 AND "deletedAt" IS NULL
         RETURNING *
    
    Input: 
      statusId = 1 (Active)
      id = 1
    ↓
    Output: Updated User entity
    {
      id: 1,
      email: "user@example.com",
      statusId: 1,              // Updated to Active
      status: { id: 1, name: "Active" },
      updatedAt: "2024-01-01T10:10:00Z"
    }
    ↓
    Returns: Updated User object
  ↓
  Step 4: If status changed to Active, send approval email
    if (statusChangedToActive) {
      MailService.sendUserApprovalNotification({
        to: user.email,
        data: {
          userName: user.profile.name,
          userEmail: user.email,
          approvedBy: superAdmin.profile.name,
          approvalDate: user.updatedAt,
          loginUrl: "https://frontend.com/auth/login"
        }
      })
      ↓
      Send Email via SMTP:
        - Template: user-approval-notification.hbs
        - Subject: "Your Account Has Been Approved"
        - To: user.email
        - Contains: Login URL and approval details
    }
  ↓
  Returns: Updated User object with relations
  {
    id: 1,
    email: "user@example.com",
    status: { id: 1, name: "Active" },
    role: { id: 2, name: "Designer" },
    profile: { name: "User Name", credit: "100" }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: UsersController.update()
  Returns: User object (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    id: 1,
    email: "user@example.com",
    status: { id: 1, name: "Active" },
    ...
  }
  ↓
Frontend Actions:
  1. Update user in list (status changed to "Active")
  2. Show success notification: "User approved successfully"
  3. Button changes from "Approve" to "Revoke"
  ↓
User receives approval email
  ↓
User can now login successfully
```

### User Flow Diagram - Revoke

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - SuperAdmin User Management Page                     │
└─────────────────────────────────────────────────────────────────────────────┘

SuperAdmin Action:
  ↓
SuperAdmin sees user with status: "Active"
  ↓
SuperAdmin clicks "Revoke" button (orange button)
  ↓
Data Prepared:
  {
    status: { id: 2 }  // Inactive
  }
  ↓
API Call: PATCH /api/v1/users/1
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: { status: { id: 2 } }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: UsersService.update()
  (Same flow as Approve, but with statusId = 2)
  ↓
  Step 1: Get current user data
    UsersService.findById(id)
    Output: User with statusId = 1 (Active)
  ↓
  Step 2: Check status change
    oldStatusId = 1 (Active)
    newStatusId = 2 (Inactive)
    statusChangedToInactive = true
  ↓
  Step 3: Update user status
    SQL: UPDATE "user"
         SET "statusId" = 2, "updatedAt" = NOW()
         WHERE id = 1
    ↓
    Output: User with statusId = 2 (Inactive)
  ↓
  Step 4: No email sent (revoke doesn't trigger email)
  ↓
  Returns: Updated User object
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    id: 1,
    status: { id: 2, name: "Inactive" },
    ...
  }
  ↓
Frontend Actions:
  1. Update user in list (status changed to "Inactive")
  2. Show success notification: "User revoked successfully"
  3. Button changes from "Revoke" to "Approve"
  ↓
User cannot login (status check will fail on next login attempt)
```

---

## 5. Token Refresh

### Backend API

**Endpoint:** POST `/api/v1/auth/refresh`

**Request:** Bearer refresh token in Authorization header

**Response:**
```json
{
  "token": "new_access_token",
  "refreshToken": "new_refresh_token",
  "tokenExpires": 1234567890
}
```

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Token Refresh Flow                          │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario: Access token expired (401 Unauthorized)
  ↓
Frontend API Interceptor detects 401 error
  ↓
Frontend gets refreshToken from localStorage
  ↓
API Call: POST /api/v1/auth/refresh
  Headers: {
    "Authorization": "Bearer <refreshToken>",
    "Content-Type": "application/json"
  }
  Body: {} (empty)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/auth/refresh
  ↓
Guard: @UseGuards(AuthGuard('jwt-refresh'))
  ↓
JWT Refresh Strategy validates refresh token:
  1. Extract token from Authorization header
  2. Verify signature with auth.refreshSecret
  3. Check expiration
  4. Extract payload: { sessionId, hash }
  5. Attach to request.user
  ↓
Controller: AuthController.refresh()
  Input: request.user (from JWT payload)
    {
      sessionId: 123,
      hash: "a1b2c3d4e5f6..."
    }
  ↓
  Calls: AuthService.refresh(request.user)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.refresh()
  Input: refreshPayload { sessionId, hash }
  ↓
  Step 1: SessionService.findById(sessionId)
    Input: sessionId = 123
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - Session Lookup                 │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "session"
         WHERE id = $1 AND "deletedAt" IS NULL
         LEFT JOIN "user" ON "session"."userId" = "user".id
         LEFT JOIN role ON "user"."roleId" = role.id
    
    Input: sessionId = 123
    ↓
    Output: Session entity OR null
      If found:
      {
        id: 123,
        hash: "a1b2c3d4e5f6...",
        userId: 1,
        user: {
          id: 1,
          email: "user@example.com",
          role: { id: 2, name: "Designer" }
        }
      }
    ↓
    If null → Throw Error: Unauthorized
    If found → Continue
  ↓
  Step 2: Verify session hash matches token hash
    if (session.hash !== refreshPayload.hash)
      → Throw Error: Unauthorized (token reuse detected)
    if (session.hash === refreshPayload.hash)
      → Continue
  ↓
  Step 3: Generate new session hash
    crypto.createHash('sha256')
      .update(randomStringGenerator())
      .digest('hex')
    ↓
    Output: newHash = "x9y8z7w6v5u4..."
  ↓
  Step 4: SessionService.update(sessionId, { hash: newHash })
    Input: 
      sessionId = 123
      updateData = { hash: "x9y8z7w6v5u4..." }
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Session Update                   │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "session"
         SET hash = $1, "updatedAt" = NOW()
         WHERE id = $2
         RETURNING *
    
    Input:
      hash = "x9y8z7w6v5u4..."
      id = 123
    ↓
    Output: Updated Session entity
    {
      id: 123,
      hash: "x9y8z7w6v5u4...",  // New hash
      userId: 1,
      updatedAt: "2024-01-01T10:15:00Z"
    }
    ↓
    Returns: Updated Session object
  ↓
  Step 5: AuthService.getTokensData({ user, session })
    Input: { user, session }
    ↓
    Generate new Access Token:
      JwtService.signAsync({
        id: user.id,
        role: user.role,
        sessionId: session.id
      }, {
        secret: config.auth.secret,
        expiresIn: "1d"
      })
      ↓
      Output: newToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ↓
    Generate new Refresh Token:
      JwtService.signAsync({
        sessionId: session.id,
        hash: session.hash  // New hash
      }, {
        secret: config.auth.refreshSecret,
        expiresIn: "7d"
      })
      ↓
      Output: newRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ↓
    Calculate Token Expires:
      tokenExpires = Date.now() + ms("1d")
      ↓
      Output: tokenExpires = 1234567890
    ↓
    Returns: { token, refreshToken, tokenExpires }
  ↓
  Returns: LoginResponseDto
  {
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    tokenExpires: 1234567890
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.refresh()
  Returns: LoginResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    token: "new_access_token",
    refreshToken: "new_refresh_token",
    tokenExpires: 1234567890
  }
  ↓
Frontend Actions:
  1. Update stored tokens:
     - localStorage.setItem('accessToken', newToken)
     - localStorage.setItem('refreshToken', newRefreshToken)
  2. Retry original API request with new access token
  3. User continues using app seamlessly
  ↓
Original request succeeds with new token
```

---

## 6. Logout

### Backend API

**Endpoint:** POST `/api/v1/auth/logout`

**Request:** Bearer access token in Authorization header

**Response:** 204 No Content

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Logout Flow                                 │
└─────────────────────────────────────────────────────────────────────────────┘

User Action:
  ↓
User clicks "Logout" button
  ↓
API Call: POST /api/v1/auth/logout
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: {} (empty)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/auth/logout
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
JWT Strategy validates access token:
  1. Extract token from Authorization header
  2. Verify signature with auth.secret
  3. Check expiration
  4. Extract payload: { id, role, sessionId }
  5. Attach to request.user
  ↓
Controller: AuthController.logout()
  Input: request.user (from JWT payload)
    {
      id: 1,
      role: { id: 2, name: "Designer" },
      sessionId: 123
    }
  ↓
  Calls: AuthService.logout(request.user)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.logout()
  Input: userPayload { sessionId }
  ↓
  Step 1: SessionService.deleteById(sessionId)
    Input: sessionId = 123
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Session Deletion                 │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "session"
         SET "deletedAt" = NOW()
         WHERE id = $1
    
    Input: sessionId = 123
    ↓
    Output: Session soft-deleted
    {
      id: 123,
      hash: "a1b2c3d4e5f6...",
      userId: 1,
      deletedAt: "2024-01-01T10:20:00Z"
    }
    ↓
    Returns: void
  ↓
  Returns: void (HTTP 204 No Content)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.logout()
  Returns: HTTP 204 No Content (success)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  HTTP 204 No Content
  ↓
Frontend Actions:
  1. Clear stored tokens:
     - localStorage.removeItem('accessToken')
     - localStorage.removeItem('refreshToken')
  2. Clear Redux state:
     - dispatch(setUserAuth(false))
     - dispatch(setUserProfile(null))
  3. Show success notification: "Logged out successfully"
  4. Redirect to: /auth/login
  ↓
User is logged out and on login page
  ↓
Session is invalidated (refresh token will fail if used)
```

### Database Table Structure

**Session Table (After Logout):**
```sql
-- Session is soft-deleted:
UPDATE "session"
SET "deletedAt" = NOW()
WHERE id = $1;

-- Session still exists in database but marked as deleted
-- Refresh token validation will fail because session.deletedAt IS NOT NULL
```

---

## 7. Get Current User

### Backend API

**Endpoint:** GET `/api/v1/auth/me`

**Request:** Bearer access token in Authorization header

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "role": { "id": 2, "name": "Designer" },
  "status": { "id": 1, "name": "Active" },
  "profile": { "name": "User Name", "credit": "100" }
}
```

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Get Current User Flow                       │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario: App loads or user navigates to protected page
  ↓
Frontend needs to check if user is authenticated
  ↓
Frontend gets accessToken from localStorage
  ↓
API Call: GET /api/v1/auth/me
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                           │
└─────────────────────────────────────────────────────────────────────────────┘

Route: GET /api/v1/auth/me
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
JWT Strategy validates access token:
  1. Extract token from Authorization header
  2. Verify signature with auth.secret
  3. Check expiration
  4. Extract payload: { id, role, sessionId }
  5. Attach to request.user
  ↓
Controller: AuthController.me()
  Input: request.user (from JWT payload)
    {
      id: 1,
      role: { id: 2, name: "Designer" },
      sessionId: 123
    }
  ↓
  Calls: AuthService.me(request.user)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: AuthService.me()
  Input: userPayload { id }
  ↓
  Step 1: UsersService.findById(id)
    Input: id = 1
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - User Lookup                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT u.*, r.*, s.*, p.*
         FROM "user" u
         LEFT JOIN role r ON u."roleId" = r.id
         LEFT JOIN status s ON u."statusId" = s.id
         LEFT JOIN profile p ON p."userId" = u.id
         WHERE u.id = $1 AND u."deletedAt" IS NULL
    
    Input: id = 1
    ↓
    Output: User entity with relations OR null
      If found:
      {
        id: 1,
        email: "user@example.com",
        roleId: 2,
        statusId: 1,
        role: {
          id: 2,
          name: "Designer"
        },
        status: {
          id: 1,
          name: "Active"
        },
        profile: {
          id: "uuid-1234...",
          name: "User Name",
          credit: "100",
          userId: 1
        }
      }
    ↓
    If null → Throw Error: NotFoundException
    If found → Continue
  ↓
  Step 2: Serialize user data (exclude sensitive fields)
    - Exclude: password, deletedAt
    - Include: id, email, role, status, profile
  ↓
  Returns: User object with relations
  {
    id: 1,
    email: "user@example.com",
    role: { id: 2, name: "Designer" },
    status: { id: 1, name: "Active" },
    profile: { name: "User Name", credit: "100" }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: AuthController.me()
  Returns: User object (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    id: 1,
    email: "user@example.com",
    role: { id: 2, name: "Designer" },
    status: { id: 1, name: "Active" },
    profile: { name: "User Name", credit: "100" }
  }
  ↓
Frontend Actions:
  1. Update Redux state:
     - dispatch(setUserAuth(true))
     - dispatch(setUserProfile(user))
  2. User is authenticated and can access protected pages
  3. Display user information in UI (name, email, credits, etc.)
  ↓
User session is validated and active
```

### Database Table Structure

**User Table (with Relations):**
```sql
-- Query includes joins to get related data:
SELECT u.*, r.*, s.*, p.*
FROM "user" u
LEFT JOIN role r ON u."roleId" = r.id
LEFT JOIN status s ON u."statusId" = s.id
LEFT JOIN profile p ON p."userId" = u.id
WHERE u.id = $1 AND u."deletedAt" IS NULL;
```

---

## 8. Complete Database Schema

### User Table
```sql
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password VARCHAR,                    -- Bcrypt hashed (null for social logins)
  provider VARCHAR NOT NULL DEFAULT 'email',  -- 'email', 'google', 'microsoft'
  socialId VARCHAR,                   -- OAuth provider user ID
  roleId INTEGER REFERENCES role(id),  -- 1=SuperAdmin, 2=Designer, 3=Admin, 4=Client
  statusId INTEGER REFERENCES status(id),    -- 1=Active, 2=Inactive
  isEmailVerified BOOLEAN DEFAULT false,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP                 -- Soft delete (null = active)
);
```

### Session Table
```sql
CREATE TABLE "session" (
  id SERIAL PRIMARY KEY,
  hash VARCHAR NOT NULL,              -- SHA256 hash for refresh token validation
  userId INTEGER REFERENCES "user"(id),
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP                 -- Soft delete (null = active)
);
```

### Profile Table
```sql
CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  credit VARCHAR DEFAULT '0',
  userId INTEGER UNIQUE REFERENCES "user"(id),
  resetCode TEXT,                     -- For password reset
  resetCodeExpires TIMESTAMP,         -- Password reset code expiration
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

### Role Table
```sql
CREATE TABLE role (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
-- Values: 1=SuperAdmin, 2=Designer, 3=Admin, 4=Client
```

### Status Table
```sql
CREATE TABLE status (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
-- Values: 1=Active, 2=Inactive
```

### Table Relationships

```
user (1) ────── (1) profile
  │
  │ (many)
  │
  └─────── (many) session

user (many) ──── (1) role
user (many) ──── (1) status
```

---

## 9. Key Business Rules Summary

### Registration Flow
1. **Email Registration:**
   - User creates account → `isEmailVerified: false`, `status: Inactive`
   - Verification email sent
   - User verifies email → `isEmailVerified: true`, `status: Inactive` (still)
   - SuperAdmin approves → `status: Active`
   - User can login

2. **Social Registration (Google/Microsoft):**
   - User registers via OAuth → `isEmailVerified: true`, `status: Active`
   - User can login immediately (no approval needed)

3. **Client Invitation Registration:**
   - User registers via invitation link → `role: Client (4)`, `status: Active`
   - User can login immediately (no approval needed)

### Login Requirements
- Email login requires:
  1. User exists
  2. Provider is 'email'
  3. Password exists
  4. `isEmailVerified: true`
  5. `status: Active`
  6. Password matches

### Session Management
- Each login creates a new session record
- Session hash stored in database and refresh token
- Logout soft-deletes session (sets `deletedAt`)
- Multiple sessions allowed (multi-device support)
- Refresh token validates against session hash

### Token System
- **Access Token:** Short-lived (1 day), stateless, no DB lookup
- **Refresh Token:** Long-lived (7 days), requires DB lookup, validates session hash
- Token refresh updates session hash (prevents token reuse)

### Security Features
- Bcrypt password hashing
- JWT token signing with secrets
- Session hash validation
- Soft delete for users and sessions
- Email verification required
- SuperAdmin approval required for email registrations