# 1. Authentication APIs

## 🔐 **Authentication System Overview**

The ZbInnovation platform uses JWT-based authentication with refresh tokens, email verification, and comprehensive security measures. The authentication system supports 8 different user types with role-based access control.

## 🔑 **Authentication Flow**

### **Registration and Login Flow**
1. **User Registration** → Email verification required
2. **Email Verification** → Account activation
3. **Login** → JWT token generation
4. **Token Refresh** → Maintain session without re-login
5. **Logout** → Token invalidation

### **Security Features**
- **JWT Tokens**: Stateless authentication with 24-hour expiration
- **Refresh Tokens**: 30-day expiration for session maintenance
- **Email Verification**: Required for account activation
- **Password Security**: bcrypt hashing with salt
- **Rate Limiting**: Protection against brute force attacks

## 📋 **Authentication Endpoints**

### **1. User Registration**
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "firstName": "John",
  "lastName": "Doe",
  "profileType": "innovator",
  "agreeToTerms": true
}
```

**Response (201 Created)**:
```json
{
  "success": true,
  "message": "Registration successful. Please check your email for verification.",
  "data": {
    "userId": "uuid-string",
    "email": "user@example.com",
    "profileType": "innovator",
    "isVerified": false,
    "verificationEmailSent": true
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Validation Rules**:
- Email must be valid format and unique
- Password minimum 8 characters with mixed case, numbers, symbols
- Profile type must be one of 8 valid types
- Terms agreement required

### **2. User Login**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "userId": "uuid-string",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "profileType": "innovator",
      "profileCompletion": 75,
      "isVerified": true
    },
    "tokens": {
      "accessToken": "jwt-access-token",
      "refreshToken": "jwt-refresh-token",
      "expiresIn": 86400,
      "tokenType": "Bearer"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **3. Token Refresh**
```http
POST /api/v1/auth/refresh
Content-Type: application/json
Authorization: Bearer {refresh-token}

{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "new-jwt-access-token",
    "refreshToken": "new-jwt-refresh-token",
    "expiresIn": 86400,
    "tokenType": "Bearer"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **4. User Logout**
```http
POST /api/v1/auth/logout
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Logout successful",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **5. Email Verification**
```http
POST /api/v1/auth/verify-email
Content-Type: application/json

{
  "token": "email-verification-token"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Email verified successfully",
  "data": {
    "userId": "uuid-string",
    "email": "user@example.com",
    "isVerified": true,
    "verifiedAt": "2024-01-15T10:30:00Z"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **6. Resend Verification Email**
```http
POST /api/v1/auth/resend-verification
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Verification email sent successfully",
  "data": {
    "email": "user@example.com",
    "emailSent": true,
    "expiresIn": 86400
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **7. Forgot Password**
```http
POST /api/v1/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Password reset email sent if account exists",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **8. Reset Password**
```http
POST /api/v1/auth/reset-password
Content-Type: application/json

{
  "token": "password-reset-token",
  "newPassword": "NewSecurePassword123!",
  "confirmPassword": "NewSecurePassword123!"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Password reset successful",
  "data": {
    "userId": "uuid-string",
    "passwordResetAt": "2024-01-15T10:30:00Z"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🛡️ **Security Implementation**

### **JWT Token Structure**
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-uuid",
    "email": "user@example.com",
    "profileType": "innovator",
    "roles": ["USER"],
    "iat": 1642248600,
    "exp": 1642335000,
    "iss": "zbinnovation-platform"
  }
}
```

### **Password Security**
- **Hashing**: bcrypt with salt rounds (12)
- **Validation**: Minimum 8 characters, mixed case, numbers, symbols
- **History**: Prevent reuse of last 5 passwords
- **Expiration**: Optional password expiration policy

### **Rate Limiting**
- **Login Attempts**: 5 attempts per 15 minutes per IP
- **Registration**: 3 registrations per hour per IP
- **Password Reset**: 3 requests per hour per email
- **Email Verification**: 5 requests per hour per email

### **Account Security**
- **Account Lockout**: After 5 failed login attempts
- **Suspicious Activity**: Monitor for unusual login patterns
- **Session Management**: Track active sessions and devices
- **Security Notifications**: Email alerts for security events

## 🔍 **Error Handling**

### **Common Error Responses**

**Invalid Credentials (401)**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password",
    "details": "Authentication failed"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Account Not Verified (403)**:
```json
{
  "success": false,
  "error": {
    "code": "ACCOUNT_NOT_VERIFIED",
    "message": "Please verify your email address",
    "details": "Account verification required"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Rate Limit Exceeded (429)**:
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "details": "Rate limit: 5 requests per 15 minutes",
    "retryAfter": 900
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 📊 **Authentication Middleware**

### **JWT Validation Middleware**
- **Token Extraction**: From Authorization header
- **Token Validation**: Signature and expiration verification
- **User Context**: Inject user information into request context
- **Role Verification**: Check user permissions for protected routes

### **Protected Route Examples**
```http
# Requires valid JWT token
GET /api/v1/profiles/me
Authorization: Bearer {access-token}

# Requires specific role
POST /api/v1/admin/users
Authorization: Bearer {admin-access-token}
```

---

## 📚 **Reference Documents**

**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Frontend Integration**: See `/5_frontend_implementation/3_form_handling_and_validation.md`

*This authentication system provides secure, scalable user management for the ZbInnovation platform.*
