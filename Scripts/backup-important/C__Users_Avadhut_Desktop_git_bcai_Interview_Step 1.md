# Login, Register, Authentication & Authorization Flow

## 1. Login Page (`/auth/login`)

### Frontend Flow

**What User Sees:**
- Logo at the top
- Heading: "Start using Pixel Plus AI today!"
- Email input field with envelope icon
- Password input field with lock icon and show/hide toggle
- "Remember me" checkbox
- "Forgot password?" link
- "Login" button
- "Don't have an account? Sign up" link
- Social login options: Google and Microsoft buttons

**User Actions:**
1. User enters email and password
2. Clicks "Login" button or presses Enter
3. System validates credentials
4. On success: User redirected to `/create` page
5. On failure: Error notification displayed with specific message

**Error Messages:**
- "No account found with this email" - Email doesn't exist
- "Please verify your email before logging in" - Email not verified
- "Incorrect password" - Wrong password
- "Your account is not active" - Account status is Inactive
- "Please login using your [provider] account" - User registered with social provider

**Social Login:**
- Google: Opens Google OAuth popup, exchanges token with backend
- Microsoft: Opens Microsoft MSAL popup, exchanges token with backend
- Both redirect to `/create` on success

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

### Backend Flow

**Function Call Chain:**
1. `AuthController.login()` receives request
2. Calls `AuthService.validateLogin()`
3. `UsersService.findByEmail()` - Find user by email
4. Validations:
   - User exists
   - Provider is email (not social)
   - Password exists
   - Email is verified (`isEmailVerified: true`)
   - Status is Active (not Inactive)
   - Password matches (bcrypt.compare)
5. Generate session hash (SHA256)
6. `SessionService.create()` - Create session record
7. `AuthService.getTokensData()` - Generate JWT tokens
8. Return tokens and user data

### Database Queries

**User Lookup:**
```sql
SELECT * FROM "user" 
WHERE email = $1 
AND "deletedAt" IS NULL;
```

**Session Creation:**
```sql
INSERT INTO "session" (hash, "userId", "createdAt", "updatedAt")
VALUES ($1, $2, NOW(), NOW())
RETURNING *;
```

**Related Tables:**
- `user` table: Stores user credentials and status
- `session` table: Tracks active login sessions
- `role` table: User role (1=SuperAdmin, 2=Designer, 3=Admin, 4=Client)
- `status` table: User status (1=Active, 2=Inactive)
- `profile` table: User profile with credits

### JWT Token Generation

**Access Token Payload:**
```typescript
{
  id: number,           // User ID
  role: {               // User role
    id: number,
    name: string
  },
  sessionId: number     // Session ID for logout
}
```

**Access Token Details:**
- Secret: `auth.secret` from config
- Expires: `auth.expires` (e.g., "1d")
- Algorithm: HS256
- Extraction: From `Authorization: Bearer <token>` header
- Used for: Authenticating API requests

**Refresh Token Payload:**
```typescript
{
  sessionId: number,    // Session ID
  hash: string          // Session hash for validation
}
```

**Refresh Token Details:**
- Secret: `auth.refreshSecret` from config
- Expires: `auth.refreshExpires` (e.g., "7d")
- Algorithm: HS256
- Used for: Refreshing expired access tokens

### Access Token & Refresh Token - Detailed Explanation

#### Access Token

**What is Access Token:**
- Short-lived JWT token that proves user identity
- Contains user information (id, role, sessionId)
- Used to authenticate API requests
- Expires quickly (typically 1 day) for security

**Frontend Perspective:**

**Storage:**
- Stored in memory or localStorage/sessionStorage
- Example: `localStorage.setItem('accessToken', token)`
- Sent in every API request header: `Authorization: Bearer <accessToken>`

**Usage:**
```typescript
// After login, store token
const { token, refreshToken } = response;
localStorage.setItem('accessToken', token);
localStorage.setItem('refreshToken', refreshToken);

// Use in API requests
apiClient.get('/api/v1/users/me', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('accessToken')}`
  }
});
```

**Token Expiration Handling:**
- Frontend detects 401 Unauthorized response
- Automatically calls refresh token endpoint
- Gets new access token
- Retries original request with new token

**Backend Perspective:**

**Generation (During Login):**
```typescript
// In AuthService.getTokensData()
const token = await this.jwtService.signAsync(
  {
    id: user.id,
    role: user.role,
    sessionId: session.id
  },
  {
    secret: configService.get('auth.secret'),
    expiresIn: configService.get('auth.expires') // e.g., "1d"
  }
);
```

**Validation (On Protected Routes):**
```typescript
// JWT Strategy validates token
@UseGuards(AuthGuard('jwt'))
@Get('me')
getProfile(@Request() req) {
  // req.user contains decoded token payload
  // { id: 1, role: {...}, sessionId: 123 }
  return this.usersService.findById(req.user.id);
}
```

**Validation Steps:**
1. Extract token from `Authorization: Bearer <token>` header
2. Verify signature using `auth.secret`
3. Check expiration time
4. Extract payload (id, role, sessionId)
5. Attach to `request.user` for use in controllers

**Database Interaction:**
- Access token does NOT query database on each request
- Stateless authentication (no DB lookup needed)
- Only validates token signature and expiration
- Session ID in token used for logout (to identify which session to delete)

**Security Features:**
- Short expiration (1 day) limits damage if stolen
- Signed with secret key (cannot be tampered)
- Contains sessionId for session invalidation
- Stateless (no database lookup = faster)

#### Refresh Token

**What is Refresh Token:**
- Long-lived JWT token used to get new access tokens
- Contains sessionId and session hash
- Used only for refreshing access tokens
- Expires slowly (typically 7 days) for convenience

**Frontend Perspective:**

**Storage:**
- Stored securely (localStorage/sessionStorage or httpOnly cookie)
- Example: `localStorage.setItem('refreshToken', refreshToken)`
- Only sent to refresh endpoint, NOT in regular API requests

**Usage:**
```typescript
// When access token expires (401 error)
async function refreshAccessToken() {
  const refreshToken = localStorage.getItem('refreshToken');
  
  const response = await apiClient.post('/api/v1/auth/refresh', {}, {
    headers: {
      'Authorization': `Bearer ${refreshToken}`
    }
  });
  
  // Update stored tokens
  localStorage.setItem('accessToken', response.token);
  localStorage.setItem('refreshToken', response.refreshToken);
  
  return response.token; // Return new access token
}

// Automatic token refresh interceptor
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      const newToken = await refreshAccessToken();
      // Retry original request with new token
      error.config.headers['Authorization'] = `Bearer ${newToken}`;
      return apiClient.request(error.config);
    }
    return Promise.reject(error);
  }
);
```

**Token Expiration Handling:**
- If refresh token also expired → User must login again
- Frontend redirects to login page
- Clears stored tokens

**Backend Perspective:**

**Generation (During Login):**
```typescript
// In AuthService.getTokensData()
const refreshToken = await this.jwtService.signAsync(
  {
    sessionId: session.id,
    hash: session.hash // SHA256 hash stored in database
  },
  {
    secret: configService.get('auth.refreshSecret'),
    expiresIn: configService.get('auth.refreshExpires') // e.g., "7d"
  }
);
```

**Validation (On Refresh Endpoint):**
```typescript
// POST /api/v1/auth/refresh
@UseGuards(AuthGuard('jwt-refresh'))
@Post('refresh')
async refresh(@Request() req) {
  // req.user contains decoded refresh token payload
  // { sessionId: 123, hash: "abc123..." }
  
  // Find session in database
  const session = await this.sessionService.findById(req.user.sessionId);
  
  // Verify session hash matches token hash
  if (session.hash !== req.user.hash) {
    throw new UnauthorizedException();
  }
  
  // Generate new session hash
  const newHash = crypto.createHash('sha256')
    .update(randomStringGenerator())
    .digest('hex');
  
  // Update session in database
  await this.sessionService.update(session.id, { hash: newHash });
  
  // Generate new tokens with new hash
  return this.getTokensData({
    id: session.user.id,
    role: session.user.role,
    sessionId: session.id,
    hash: newHash
  });
}
```

**Validation Steps:**
1. Extract refresh token from `Authorization: Bearer <token>` header
2. Verify signature using `auth.refreshSecret`
3. Check expiration time
4. Extract payload (sessionId, hash)
5. Query database to find session by sessionId
6. Verify session hash matches token hash (prevents reuse of revoked tokens)
7. Generate new session hash
8. Update session in database
9. Generate new access and refresh tokens

**Database Interaction:**
- Refresh token REQUIRES database lookup
- Validates session exists and is active
- Verifies session hash matches (security check)
- Updates session hash on each refresh (prevents token reuse)

**Security Features:**
- Long expiration (7 days) for user convenience
- Contains session hash for validation
- Database lookup prevents use of revoked tokens
- Session hash updated on refresh (old tokens become invalid)
- Separate secret from access token (if one compromised, other is safe)

#### Token Flow Comparison

**Access Token Flow:**
```
Frontend Request → Backend
  ↓
Extract token from header
  ↓
Verify signature (no DB query)
  ↓
Check expiration (no DB query)
  ↓
Extract payload (no DB query)
  ↓
Attach to request.user
  ↓
Process request
```
**Performance:** Fast (stateless, no database)

**Refresh Token Flow:**
```
Frontend Request → Backend
  ↓
Extract refresh token from header
  ↓
Verify signature (no DB query)
  ↓
Check expiration (no DB query)
  ↓
Extract payload (sessionId, hash)
  ↓
Query database for session (DB query)
  ↓
Verify session hash matches (security check)
  ↓
Generate new session hash
  ↓
Update session in database (DB update)
  ↓
Generate new tokens
  ↓
Return new tokens
```
**Performance:** Slower (requires database operations)

#### Why Two Tokens?

**Security Benefits:**
1. **Access Token (Short-lived):**
   - If stolen, expires quickly (1 day)
   - Limited damage window
   - No database lookup = faster API calls

2. **Refresh Token (Long-lived):**
   - Stored securely, rarely sent
   - Requires database validation
   - Can be revoked by deleting session
   - Allows seamless user experience (no frequent logins)

**User Experience Benefits:**
- User stays logged in for 7 days (refresh token)
- Access token refreshes automatically in background
- No interruption to user workflow
- Only login again if refresh token expires

**Example Scenario:**
```
Day 1: User logs in → Gets access token (expires in 1 day) + refresh token (expires in 7 days)
Day 1-2: User makes API calls with access token
Day 2: Access token expires → Frontend automatically uses refresh token to get new access token
Day 2-3: User continues using app with new access token
...
Day 7: Refresh token expires → User must login again
```

### JWT Authentication Strategy

**Implementation:**
- **Strategy Type:** JWT (JSON Web Token)
- **Library:** Passport JWT Strategy (`@nestjs/passport`, `passport-jwt`)
- **Token Extraction:** From `Authorization: Bearer <token>` header

**JWT Strategy Flow (How tokens are validated):**
1. Request includes `Authorization: Bearer <token>` header
2. `JwtStrategy.validate()` extracts token from header
3. Verifies token signature with secret (`auth.secret`)
4. Validates token expiration
5. Extracts payload (id, role, sessionId)
6. Returns payload to NestJS guards
7. `AuthGuard('jwt')` attaches payload to `request.user`
8. Controller/Service can access `request.user.id`, `request.user.role`, etc.

**Session Management:**
- Each login creates a new session record in database
- Session hash stored in database and refresh token
- Logout deletes session record (soft delete)
- Refresh token validates against session hash
- Multiple sessions allowed (user can login from multiple devices)

### User Flow Diagram

```
User → Login Page
  ↓
Enter Credentials → Submit
  ↓
POST /auth/email/login
  ↓
Backend Validations:
  - User exists?
  - Provider is email?
  - Password exists?
  - Email verified? (isEmailVerified: true)
  - Status is Active?
  - Password matches?
  ↓
Create Session (session table)
  ↓
Generate JWT Tokens (Access + Refresh)
  ↓
Return Tokens + User Data
  ↓
Frontend: Store Tokens
  ↓
Redirect to /create
```

---

## 2. Registration Page (`/auth/sign-up`)

### Frontend Flow

**What User Sees:**
- Logo at the top
- Heading: "Start using PixelPlusAI today!"
- Email input field (pre-filled if client invitation)
- Full Name or Organization Name input (hidden for client invitations)
- Password input with strength requirements
- Confirm Password input
- Password requirements displayed:
  - 12-20 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character
- Terms and Privacy checkbox (required)
- "Create Account" button
- "Already have an account? Login" link
- Social registration options: Google and Microsoft buttons

**User Actions:**
1. User fills all required fields
2. Checks Terms and Privacy agreement
3. Clicks "Create Account"
4. System validates password strength and matching
5. Registration request sent to backend

**Registration Outcomes:**

**Regular Email Registration:**
- Account created with `isEmailVerified: false` and `status: Inactive`
- Verification email sent to user
- Success message: "Registration successful! A verification email has been sent..."
- User stays on registration page (NOT authenticated)
- User must verify email before login

**Client Invitation Registration:**
- Account created with `role: 4` (Client) and `status: Active`
- User immediately authenticated
- Redirected to home page `/`
- No email verification required

**Social Registration (Google/Microsoft):**
- Account created with `isEmailVerified: true` and `status: Active`
- User immediately authenticated
- Redirected to `/create` page
- No email verification required

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

### Backend Flow

**Function Call Chain:**
1. `AuthController.register()` receives request
2. Calls `AuthService.register()`
3. `UsersService.create()` - Create user with:
   - `isEmailVerified: false`
   - `status: Inactive` (statusId: 2)
   - `role: Designer` (roleId: 2) by default
   - Password hashed with bcrypt
   - Profile created with default credit: 100
4. Generate email confirmation hash (JWT with `confirmEmailUserId`)
5. `MailService.userSignUp()` - Send verification email
6. If email send fails: Delete user (rollback)
7. `AuthService.notifySuperAdminsOfNewUser()` - Send notification to all SuperAdmins
8. Return success message (NO tokens - user must verify email first)

### Database Queries

**User Creation (Transaction):**
```sql
BEGIN TRANSACTION;

-- Create user
INSERT INTO "user" (email, password, provider, "roleId", "statusId", "isEmailVerified", "createdAt", "updatedAt")
VALUES ($1, $2, 'email', $3, $4, false, NOW(), NOW())
RETURNING *;

-- Create profile
INSERT INTO profile (name, credit, "userId", "createdAt", "updatedAt")
VALUES ($5, '100', $6, NOW(), NOW());

COMMIT;
```

**Email Uniqueness Check:**
```sql
SELECT * FROM "user" WHERE email = $1;
```

**Related Tables:**
- `user` table: Stores new user record
- `profile` table: Creates profile with default 100 credits
- `role` table: References role (default: Designer = 2)
- `status` table: References status (default: Inactive = 2)

### User Flow Diagram

```
User → Register Page
  ↓
Fill Form → Submit
  ↓
POST /auth/email/register
  ↓
Backend: Create User (isEmailVerified: false, status: Inactive)
  ↓
Create Profile (credit: 100)
  ↓
Generate Email Confirmation Hash (JWT)
  ↓
Send Verification Email
  ↓
Notify SuperAdmins
  ↓
Return Success (NO tokens)
  ↓
User Receives Email
  ↓
Click Verification Link
  ↓
POST /auth/email/confirm
  ↓
Backend: Set isEmailVerified: true
  ↓
Notify SuperAdmins (Email Confirmed)
  ↓
User Status: Inactive (Pending Approval)
  ↓
SuperAdmin Approves (Status → Active)
  ↓
User Receives Approval Email
  ↓
User Can Login
```

---

## 3. Email Confirmation (`/auth/email-confirm`)

### Frontend Flow

**What User Sees:**
- Confirmation status (loading/success/error)
- Loading: Spinner with "Confirming Email..." message
- Success: Green checkmark with "Email Confirmed!" message
- Error: Red X with "Confirmation Failed" message

**User Actions:**
1. User clicks verification link from email
2. Link contains `hash` parameter
3. System validates hash and confirms email
4. On success: Shows "Your account is now pending admin approval" message
5. Redirects to login page after 2 seconds

**Important:** After email confirmation, user account status remains `Inactive` until SuperAdmin approves.

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

### Backend Flow

**Function Call Chain:**
1. `AuthController.confirmEmail()` receives request
2. Calls `AuthService.confirmEmail()`
3. Verify JWT hash with `confirmEmailSecret`
4. Extract `confirmEmailUserId` from token
5. `UsersService.findById()` - Find user
6. Check user not soft-deleted
7. Update `isEmailVerified: true`
8. `UsersService.update()` - Save changes
9. `AuthService.notifySuperAdminsOfEmailConfirmation()` - Notify SuperAdmins
10. Return success (user status still Inactive - needs SuperAdmin approval)

### Database Queries

**User Update:**
```sql
UPDATE "user"
SET "isEmailVerified" = true, "updatedAt" = NOW()
WHERE id = $1 AND "deletedAt" IS NULL
RETURNING *;
```

**Email Confirmation Hash Payload:**
```typescript
{
  confirmEmailUserId: number  // User ID to confirm
}
```

**Token Details:**
- Secret: `auth.confirmEmailSecret` from config
- Expires: `auth.confirmEmailExpires` (e.g., "24h")
- Algorithm: HS256

### User Flow Diagram

```
User Receives Verification Email
  ↓
Click Verification Link (contains hash)
  ↓
POST /auth/email/confirm
  ↓
Backend: Verify JWT Hash
  ↓
Extract User ID from Token
  ↓
Find User by ID
  ↓
Update isEmailVerified: true
  ↓
Notify SuperAdmins (Email Confirmed)
  ↓
User Status: Inactive (Still Pending Approval)
  ↓
Redirect to Login Page
```

---

## 4. SuperAdmin Approval & Revoke

### Frontend Flow

**Super Admin Actions (User Management Page):**
1. SuperAdmin navigates to User Management page
2. Views list of all users with their status (Active/Inactive)
3. For Inactive users: Sees "Approve" button (green)
4. For Active users: Sees "Revoke" button (orange)
5. Clicks "Approve" to activate user account
6. System changes user status from `Inactive` to `Active`
7. Approval email sent to user with login link
8. User can now login successfully

**Super Admin Actions (Revoke):**
1. SuperAdmin clicks "Revoke" button for Active user
2. System changes user status from `Active` to `Inactive`
3. User cannot login (status check fails)

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

### Backend Flow

**Function Call Chain (Approve):**
1. SuperAdmin updates user status from Inactive (id: 2) to Active (id: 1)
2. `UsersService.update()` - Update user status
3. Check if status changed from Inactive to Active
4. If status change to Active:
   - `MailService.sendUserApprovalNotification()` - Send approval email
   - Email contains login URL
5. User can now login successfully

**Function Call Chain (Revoke):**
1. SuperAdmin updates user status from Active (id: 1) to Inactive (id: 2)
2. `UsersService.update()` - Update user status
3. User cannot login (status check fails on next login attempt)

### Database Queries

**Status Update:**
```sql
UPDATE "user"
SET "statusId" = $1, "updatedAt" = NOW()
WHERE id = $2 AND "deletedAt" IS NULL
RETURNING *;
```

**Check Status Change:**
```sql
SELECT "statusId" FROM "user" WHERE id = $1;
-- Compare old statusId (2 = Inactive) with new statusId (1 = Active)
```

**Related Tables:**
- `user` table: Updates statusId field
- `status` table: References status (1=Active, 2=Inactive)

### User Flow Diagram (Approve)

```
SuperAdmin → User Management Page
  ↓
View User List (Status: Inactive)
  ↓
Click "Approve" Button
  ↓
PATCH /api/v1/users/:id (status: Active)
  ↓
Backend: Update User Status (statusId: 2 → 1)
  ↓
Check: Status changed from Inactive → Active?
  ↓
Send Approval Email to User
  ↓
User Receives Email with Login Link
  ↓
User Can Now Login Successfully
```

### User Flow Diagram (Revoke)

```
SuperAdmin → User Management Page
  ↓
View User List (Status: Active)
  ↓
Click "Revoke" Button
  ↓
PATCH /api/v1/users/:id (status: Inactive)
  ↓
Backend: Update User Status (statusId: 1 → 2)
  ↓
User Cannot Login (Status Check Fails)
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

### Backend Flow

**Function Call Chain:**
1. `AuthController.refresh()` receives request
2. JWT Refresh Strategy validates refresh token (see JWT Strategy in Login section)
3. Extract `sessionId` and `hash` from token payload
4. `SessionService.findById()` - Find session
5. Verify session hash matches token hash
6. Generate new session hash (SHA256)
7. `SessionService.update()` - Update session hash
8. `AuthService.getTokensData()` - Generate new access and refresh tokens
9. Return new tokens

### Database Queries

**Session Lookup:**
```sql
SELECT * FROM "session"
WHERE id = $1 AND "deletedAt" IS NULL;
```

**Session Update:**
```sql
UPDATE "session"
SET hash = $1, "updatedAt" = NOW()
WHERE id = $2
RETURNING *;
```

**Related Tables:**
- `session` table: Validates and updates session hash

---

## 6. Logout

### Backend API

**Endpoint:** POST `/api/v1/auth/logout`

**Request:** Bearer access token in Authorization header

**Response:** 204 No Content

### Backend Flow

**Function Call Chain:**
1. `AuthController.logout()` receives request
2. JWT Strategy validates access token (see JWT Strategy in Login section)
3. Extract `sessionId` from JWT payload (`request.user.sessionId`)
4. `SessionService.deleteById()` - Delete session (soft delete)
5. User logged out (token invalid, session removed)

### Database Queries

**Session Deletion:**
```sql
UPDATE "session"
SET "deletedAt" = NOW()
WHERE id = $1;
```

**Related Tables:**
- `session` table: Soft deletes session record

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

### Backend Flow

**Function Call Chain:**
1. `AuthController.me()` receives request
2. JWT Strategy validates access token (see JWT Strategy in Login section)
3. Extract user `id` from JWT payload (`request.user.id`)
4. `UsersService.findById()` - Get user with relations
5. Check user not soft-deleted
6. Return user data

### Database Queries

**User Lookup with Relations:**
```sql
SELECT u.*, r.*, s.*, p.*
FROM "user" u
LEFT JOIN role r ON u."roleId" = r.id
LEFT JOIN status s ON u."statusId" = s.id
LEFT JOIN profile p ON p."userId" = u.id
WHERE u.id = $1 AND u."deletedAt" IS NULL;
```

**Related Tables:**
- `user` table: Main user record
- `role` table: User role information
- `status` table: User status information
- `profile` table: User profile and credits

---

## 8. Email System Implementation

### Overview

The application uses **Nodemailer** with **Handlebars templates** to send emails to users. Emails are sent for various events like registration, email verification, password reset, user approval, and notifications.

### Architecture

**Components:**
1. **MailerService** - Low-level email sending using Nodemailer
2. **MailService** - High-level service with email templates and business logic
3. **Email Templates** - Handlebars (.hbs) templates for HTML emails
4. **SMTP Configuration** - Environment-based email server settings

### Backend Implementation

#### MailerService (Low-Level)

**Location:** `src/mailer/mailer.service.ts`

**Purpose:** Handles SMTP connection and email delivery using Nodemailer

**Configuration:**
```typescript
// Creates Nodemailer transporter with SMTP settings
this.transporter = nodemailer.createTransport({
  host: configService.get('mail.host'),        // e.g., smtp.gmail.com
  port: configService.get('mail.port'),        // e.g., 587
  secure: configService.get('mail.secure'),    // false for TLS
  requireTLS: configService.get('mail.requireTLS'), // true
  auth: {
    user: configService.get('mail.user'),      // SMTP username
    pass: configService.get('mail.password'),  // SMTP password
  },
});
```

**Key Method:**
```typescript
async sendMail({
  templatePath,      // Path to Handlebars template
  context,           // Data to inject into template
  attachments,       // Inline images (logo, etc.)
  ...mailOptions     // Standard nodemailer options
}): Promise<void>
```

**Process:**
1. Reads Handlebars template file from `templatePath`
2. Compiles template with `context` data
3. Processes attachments (images with CID for inline display)
4. Sends email via Nodemailer transporter

#### MailService (High-Level)

**Location:** `src/mail/mail.service.ts`

**Purpose:** Provides business logic methods for different email types

**Email Types Implemented:**

1. **User Sign Up (Email Verification)**
   - Method: `userSignUp()`
   - Template: `activation.hbs`
   - Data: `{ hash, userName }`
   - Purpose: Send email verification link after registration

2. **Forgot Password**
   - Method: `forgotPassword()`
   - Template: `verification-code.hbs`
   - Data: `{ code }`
   - Purpose: Send 6-digit verification code for password reset

3. **Email Confirmation (New Email)**
   - Method: `confirmNewEmail()`
   - Template: `confirm-new-email.hbs`
   - Data: `{ hash }`
   - Purpose: Confirm new email address change

4. **Client Invitation**
   - Method: `clientInvitation()`
   - Template: `client-invitation.hbs`
   - Data: `{ queryString }`
   - Purpose: Invite client users with pre-filled registration

5. **User Approval Notification**
   - Method: `sendUserApprovalNotification()`
   - Template: `user-approval-notification.hbs`
   - Data: `{ userName, userEmail, approvedBy, approvalDate, loginUrl }`
   - Purpose: Notify user when SuperAdmin approves account

6. **New User Notification (to SuperAdmin)**
   - Method: `sendNewUserNotification()`
   - Template: `new-user-notification.hbs`
   - Data: `{ adminName, newUserName, newUserEmail, newUserRole, newUserStatus, userId, registrationDate }`
   - Purpose: Notify SuperAdmins when new user registers

7. **Email Confirmation Notification (to SuperAdmin)**
   - Method: `sendEmailConfirmationNotification()`
   - Template: `email-confirmation-notification.hbs`
   - Data: `{ adminName, confirmedUserName, confirmedUserEmail, confirmedUserRole, confirmedUserStatus, userId, confirmationDate }`
   - Purpose: Notify SuperAdmins when user confirms email

8. **Credit Exhausted Notification**
   - Method: `sendCreditExhaustedNotification()`
   - Template: `credit-exhausted.hbs`
   - Data: `{ userName, userEmail, accountStatus, lastActivity, dashboardUrl, currentPlan, creditsUsed, totalCredits, upgradeUrl, supportEmail, endpoint, creditsDeducted }`
   - Purpose: Notify user when credits are exhausted

**Example Implementation:**
```typescript
async userSignUp(mailData: MailData<{ hash: string; userName?: string }>): Promise<void> {
  // Build verification URL
  const url = new URL(
    configService.get('app.frontendDomain') + '/auth/confirm-email'
  );
  url.searchParams.set('hash', mailData.data.hash);
  
  // Create logo attachment (inline image)
  const logoAttachment = await this.createLogoAttachment();
  
  // Send email using MailerService
  await this.mailerService.sendMail({
    to: mailData.to,
    subject: 'Email Verification',
    templatePath: path.join('src/mail/mail-templates/activation.hbs'),
    context: {
      title: 'Email Verification',
      url: url.toString(),
      userName: mailData.data.userName || 'there',
      logoCid: 'logo-cid', // For inline logo image
    },
    attachments: [logoAttachment],
  });
}
```

### Email Templates

**Location:** `src/mail/mail-templates/*.hbs`

**Template Engine:** Handlebars

**Template Structure:**
- HTML email templates with inline CSS
- Uses Handlebars syntax: `{{variableName}}`
- Supports inline images using CID (Content-ID)
- Responsive design for mobile devices

**Example Template Usage:**
```handlebars
<!-- activation.hbs -->
<img src="cid:{{logoCid}}" alt="Logo" />
<h1>{{title}}</h1>
<p>Hi {{userName}},</p>
<p>{{text1}}</p>
<a href="{{url}}">Verify Email</a>
```

**Available Templates:**
- `activation.hbs` - Email verification
- `verification-code.hbs` - Password reset code
- `user-approval-notification.hbs` - Account approval
- `new-user-notification.hbs` - New user alert (SuperAdmin)
- `email-confirmation-notification.hbs` - Email confirmed alert (SuperAdmin)
- `client-invitation.hbs` - Client invitation
- `credit-exhausted.hbs` - Credit exhaustion warning
- `reset-password.hbs` - Password reset
- `confirm-new-email.hbs` - New email confirmation
- And more...

### SMTP Configuration

**Environment Variables:**
```bash
MAIL_HOST=smtp.gmail.com          # SMTP server hostname
MAIL_PORT=587                      # SMTP port (587 for TLS)
MAIL_USER=your-email@gmail.com     # SMTP username
MAIL_PASSWORD=your-app-password    # SMTP password (App Password for Gmail)
MAIL_DEFAULT_EMAIL=your-email@gmail.com  # Default sender email
MAIL_DEFAULT_NAME=PixelPlus AI     # Default sender name
MAIL_IGNORE_TLS=false              # Use TLS
MAIL_SECURE=false                  # false for port 587, true for 465
MAIL_REQUIRE_TLS=true              # Require TLS encryption
```

**Supported SMTP Providers:**
- Gmail (smtp.gmail.com:587)
- Office 365 (smtp.office365.com:587)
- Custom SMTP servers

**Gmail Setup:**
1. Enable 2-Factor Authentication
2. Generate App Password (Security → App passwords)
3. Use App Password in `MAIL_PASSWORD` (not regular password)

### Email Flow

**Complete Email Sending Flow:**
```
Business Logic (e.g., AuthService)
  ↓
MailService Method (e.g., userSignUp())
  ↓
Prepare Email Data:
  - Build URL with hash/parameters
  - Create logo attachment
  - Prepare template context
  ↓
MailerService.sendMail()
  ↓
Read Handlebars Template File
  ↓
Compile Template with Context Data
  ↓
Process Attachments (inline images)
  ↓
Nodemailer Transporter
  ↓
SMTP Server (Gmail/Office365/etc.)
  ↓
Email Delivered to User
```

### Inline Images (Attachments)

**Logo Attachment:**
- Logo file: `src/mail/mail-templates/Group 1.png`
- Method: `createLogoAttachment()`
- Returns: `{ filename, content: Buffer, contentType: 'image/png', cid: 'logo-cid' }`
- Usage: Logo displayed inline in email using `cid:logo-cid`

**Custom Images:**
- Can attach custom images with CID
- Images embedded inline in email HTML
- Not sent as separate attachments

### Error Handling

**Email Send Failures:**
- Try-catch blocks around email sending
- Logs errors with detailed information
- Does NOT throw errors (non-blocking)
- Continues execution even if email fails

**Example Error Handling:**
```typescript
try {
  await this.mailService.userSignUp({ to: email, data: { hash } });
  console.log('✅ Email sent successfully');
} catch (emailError) {
  console.error('❌ Failed to send email:', emailError);
  // Continue execution - don't block user registration
}
```

### Email Usage in Authentication Flow

**1. Registration Email:**
- Triggered: After user registration
- Method: `MailService.userSignUp()`
- Template: `activation.hbs`
- Contains: Email verification link with hash

**2. SuperAdmin Notification (New User):**
- Triggered: After user registration
- Method: `MailService.sendNewUserNotification()`
- Template: `new-user-notification.hbs`
- Recipients: All SuperAdmin users
- Contains: New user details

**3. Email Confirmation Notification (SuperAdmin):**
- Triggered: After user confirms email
- Method: `MailService.sendEmailConfirmationNotification()`
- Template: `email-confirmation-notification.hbs`
- Recipients: All SuperAdmin users
- Contains: Confirmed user details

**4. User Approval Email:**
- Triggered: When SuperAdmin approves user
- Method: `MailService.sendUserApprovalNotification()`
- Template: `user-approval-notification.hbs`
- Recipient: Approved user
- Contains: Login URL and approval details

**5. Password Reset Email:**
- Triggered: When user requests password reset
- Method: `MailService.forgotPassword()`
- Template: `verification-code.hbs`
- Contains: 6-digit verification code

### Database Interaction

**No Email Storage:**
- Emails are NOT stored in database
- Sent directly via SMTP
- No email queue system
- Synchronous sending (awaits completion)

**Email Logging:**
- Console logs for email sending
- Logs include: recipient, subject, success/failure
- No persistent email history table

### Security Considerations

**Email Verification:**
- Hash-based verification links (JWT tokens)
- Expires after 24 hours
- One-time use (status updated after verification)

**Password Reset:**
- 6-digit code stored temporarily in profile table
- Expires after 10 minutes
- Code cleared after successful reset

**SMTP Credentials:**
- Stored in environment variables
- Never hardcoded in source code
- Use App Passwords for Gmail (more secure)

---

## Database Schema Overview

### User Table
```sql
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password VARCHAR,
  provider VARCHAR NOT NULL DEFAULT 'email',
  socialId VARCHAR,
  roleId INTEGER REFERENCES role(id),
  statusId INTEGER REFERENCES status(id),
  isEmailVerified BOOLEAN DEFAULT false,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP -- Soft delete
);
```

**Key Fields:**
- `email`: Unique identifier for email login
- `password`: Bcrypt hashed password (null for social logins)
- `provider`: 'email', 'google', or 'microsoft'
- `socialId`: OAuth provider user ID (for social logins)
- `roleId`: Foreign key to role table (1=SuperAdmin, 2=Designer, 3=Admin, 4=Client)
- `statusId`: Foreign key to status table (1=Active, 2=Inactive)
- `isEmailVerified`: Must be true for email login
- `deletedAt`: Soft delete timestamp (null = active)

### Session Table
```sql
CREATE TABLE "session" (
  id SERIAL PRIMARY KEY,
  hash VARCHAR NOT NULL,
  userId INTEGER REFERENCES "user"(id),
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP
);
```

**Purpose:** Tracks active user sessions for JWT refresh and logout

### Profile Table
```sql
CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  credit VARCHAR DEFAULT '0',
  userId INTEGER UNIQUE REFERENCES "user"(id),
  resetCode TEXT,
  resetCodeExpires TIMESTAMP,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

**Purpose:** Stores user profile data including credits and password reset codes

### Role Table
```sql
CREATE TABLE role (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
```

**Roles:**
- 1: SuperAdmin
- 2: Designer
- 3: Admin
- 4: Client

### Status Table
```sql
CREATE TABLE status (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL
);
```

**Statuses:**
- 1: Active (can login)
- 2: Inactive (cannot login, pending approval)

---

## Security Features

### Password Security
- Bcrypt hashing with salt
- Minimum 12 characters, maximum 20 characters
- Requires: uppercase, lowercase, number, special character

### Email Verification
- Required for email-based registrations
- JWT-based confirmation link (expires in 24h)
- Prevents unverified users from logging in

### Account Status Control
- SuperAdmin approval required for all new accounts
- Status check on every login attempt
- Inactive users cannot login even with correct credentials

### Session Security
- Unique session hash per login
- Session validation on token refresh
- Logout invalidates session immediately
- Multiple sessions allowed (multi-device support)

### Token Security
- Access tokens expire (short-lived)
- Refresh tokens expire (longer-lived)
- Separate secrets for access, refresh, and email confirmation
- Session hash validation prevents token reuse after logout

---

## Key Business Rules

1. **Email Registration:** User must verify email → SuperAdmin must approve → User can login
2. **Social Registration:** User immediately verified and active → Can login immediately
3. **Client Invitation:** User immediately active → Can login immediately (no approval needed)
4. **Login Requirements:** Email verified + Status Active + Correct password
5. **SuperAdmin Approval:** Required for all email-based registrations
6. **Status Management:** Only SuperAdmin can approve/revoke accounts
7. **Soft Delete:** Users marked as deleted cannot login (deletedAt check)
