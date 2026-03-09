# 2FA Login Flow - Implementation Guide

## Overview

This document describes the complete Two-Factor Authentication (2FA) login flow implementation. When a user has 2FA enabled on their account, they must verify their identity with an OTP sent to their email before completing the login process.

## Problem Statement

**Issue 1**: Database Error
```
Error: column "two_factor_enabled" does not exist
```
**Solution**: Added 2FA columns to the users table schema in `initDatabase.js`

**Issue 2**: 2FA Not Active During Login
When users enable 2FA, it wasn't being enforced during subsequent logins.
**Solution**: Implemented complete 2FA verification flow during login

## Implementation

### Database Schema Changes

**File**: `backend/src/config/initDatabase.js`

Added two columns to the users table:
- `two_factor_enabled BOOLEAN DEFAULT false` - Tracks if user has 2FA enabled
- `two_factor_secret VARCHAR(255)` - Stores encrypted 2FA secret

```sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  ...
  two_factor_enabled BOOLEAN DEFAULT false,
  two_factor_secret VARCHAR(255),
  ...
);
```

### Backend API Changes

#### 1. Modified Login Endpoint

**File**: `backend/src/controllers/authController.js`

The login function now checks if the user has 2FA enabled:

```javascript
// Check if 2FA is enabled
if (user.two_factor_enabled) {
  // Generate and send OTP
  const otp = generateOTP();
  storeOTP(user.email, otp, 10);
  
  // Send OTP via email
  await sendOTPEmail(user.email, otp, user.name);

  // Return requires2FA response (no token yet)
  return res.json({
    success: true,
    requires2FA: true,
    message: 'OTP sent to your email. Please verify to complete login.',
    data: {
      email: user.email.replace(/(.{2})(.*)(?=@)/, '$1***'),
      userId: user.id
    }
  });
}

// Normal login flow continues...
```

#### 2. New Verify Login OTP Endpoint

**Endpoint**: `POST /api/auth/verify-login-otp`

Verifies the OTP and completes the login by issuing a JWT token.

```javascript
export const verifyLoginOTP = async (req, res) => {
  const { email, otp } = req.body;
  
  // Verify OTP
  const verification = verifyOTP(email, otp);
  
  if (!verification.success) {
    return res.status(400).json({
      success: false,
      message: verification.message
    });
  }
  
  // Get user and issue token
  const user = await getUserByEmail(email);
  const token = generateToken(user.id, user.email, user.role);
  
  res.json({
    success: true,
    message: 'Login successful',
    data: { user, token }
  });
};
```

**Route**: Added to `backend/src/routes/authRoutes.js`
```javascript
router.post('/verify-login-otp', otpRateLimiter, verifyLoginOTP);
```

### Frontend Changes

#### 1. Auth Service Updates

**File**: `lib/services/auth_service.dart`

**Modified Login Method**:
```dart
static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final response = await http.post(...);
  final data = _safeJsonDecode(response);

  // Check if 2FA is required
  if (data['requires2FA'] == true) {
    return {
      'success': true,
      'requires2FA': true,
      'message': data['message'],
      'email': data['data']['email'],
      'userId': data['data']['userId'],
    };
  }
  
  // Normal login response...
}
```

**New Method**:
```dart
static Future<Map<String, dynamic>> verifyLoginOTP({
  required String email,
  required String otp,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.authUrl}/verify-login-otp'),
    body: jsonEncode({'email': email, 'otp': otp}),
  );
  
  final data = _safeJsonDecode(response);
  
  if (data['success'] == true) {
    // Save token and user data
    await StorageService.saveToken(data['data']['token']);
    await StorageService.saveUserData(...);
  }
  
  return data;
}
```

#### 2. Login UI Updates

**File**: `lib/screens/rideshare/auth_screen.dart`

**Updated Login Handler**:
```dart
if (_isLogin) {
  result = await AuthService.login(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
  
  // Check if 2FA is required
  if (result['success'] == true && result['requires2FA'] == true) {
    setState(() { _isLoading = false; });
    
    // Show OTP dialog
    await _show2FADialog(
      email: _emailController.text.trim(),
      maskedEmail: result['email'] ?? '',
    );
    return;
  }
}
```

**New OTP Dialog**:
```dart
Future<void> _show2FADialog({
  required String email,
  required String maskedEmail,
}) async {
  final otpController = TextEditingController();
  
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Two-Factor Authentication'),
      content: Column(
        children: [
          Text('An OTP has been sent to $maskedEmail'),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            // 6-digit OTP input
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await AuthService.verifyLoginOTP(
              email: email,
              otp: otpController.text.trim(),
            );
            
            if (result['success']) {
              // Navigate to home
              Navigator.pushReplacement(context, ...);
            }
          },
          child: Text('Verify'),
        ),
      ],
    ),
  );
}
```

## Complete User Flow

### Step 1: Enable 2FA (One-time Setup)
1. User logs in normally
2. Goes to Profile → Two-Factor Authentication toggle
3. Clicks toggle ON
4. Receives OTP via email
5. Enters OTP to enable 2FA
6. 2FA is now enabled (`two_factor_enabled = true`)

### Step 2: Login with 2FA (Every Login)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User enters email and password                               │
│    └─> POST /api/auth/login                                     │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. Backend checks user.two_factor_enabled                       │
│    └─> If TRUE: Generate OTP, send email                        │
│    └─> Response: { requires2FA: true, email: "j***@email.com" }│
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Flutter app shows OTP dialog                                 │
│    └─> Displays masked email                                    │
│    └─> 6-digit OTP input field                                  │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. User checks email and enters OTP                             │
│    └─> Example: 395847                                          │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. App sends OTP for verification                               │
│    └─> POST /api/auth/verify-login-otp                         │
│    └─> Body: { email: "user@email.com", otp: "395847" }        │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. Backend verifies OTP                                         │
│    └─> Check expiry (10 minutes)                                │
│    └─> Check attempts (max 5)                                   │
│    └─> Validate OTP matches                                     │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. On success: Issue JWT token                                  │
│    └─> Response: { success: true, token: "jwt...", user: {...} }│
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. App saves token and navigates to home                        │
│    └─> User is now logged in                                    │
└─────────────────────────────────────────────────────────────────┘
```

## API Reference

### POST /api/auth/login

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (2FA Disabled)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (2FA Enabled)**:
```json
{
  "success": true,
  "requires2FA": true,
  "message": "OTP sent to your email. Please verify to complete login.",
  "data": {
    "email": "us***@example.com",
    "userId": 123
  }
}
```

### POST /api/auth/verify-login-otp

**Request**:
```json
{
  "email": "user@example.com",
  "otp": "395847"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (Invalid OTP)**:
```json
{
  "success": false,
  "message": "Invalid OTP. 4 attempts remaining."
}
```

**Response (Expired)**:
```json
{
  "success": false,
  "message": "OTP has expired. Please request a new one."
}
```

## Security Features

1. **OTP Expiration**: OTPs expire after 10 minutes
2. **Attempt Limiting**: Maximum 5 attempts per OTP
3. **Rate Limiting**: OTP endpoints are rate-limited (3 requests per 15 minutes)
4. **Email Masking**: Email addresses are masked in responses (e.g., "us***@example.com")
5. **Secure Generation**: OTPs generated using crypto.randomBytes()
6. **Input Validation**: 
   - OTP must be exactly 6 digits
   - OTP must contain only numeric characters

## Testing

### Manual Testing Steps

1. **Enable 2FA**:
   ```bash
   # Login to app
   # Go to Profile > Two-Factor Authentication
   # Toggle ON
   # Check email for OTP
   # Enter OTP to enable
   ```

2. **Test Login with 2FA**:
   ```bash
   # Logout
   # Login with email/password
   # Should see OTP dialog
   # Check email for OTP
   # Enter OTP
   # Should login successfully
   ```

3. **Test Invalid OTP**:
   ```bash
   # Login with email/password
   # Enter wrong OTP
   # Should show error message
   # Should count attempts
   ```

4. **Test Expired OTP**:
   ```bash
   # Login with email/password
   # Wait 11 minutes
   # Enter OTP
   # Should show "expired" message
   ```

### API Testing with curl

**Login with 2FA**:
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Verify OTP**:
```bash
curl -X POST http://localhost:5000/api/auth/verify-login-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","otp":"395847"}'
```

## Troubleshooting

### Issue: "column two_factor_enabled does not exist"

**Cause**: Database schema doesn't have 2FA columns

**Solution**: 
1. Drop and recreate database:
   ```bash
   cd backend
   npm run init-db
   ```
2. Or run migration:
   ```bash
   node src/config/migrate2FA.js
   ```

### Issue: OTP dialog doesn't appear

**Check**:
1. Backend response contains `requires2FA: true`
2. Console logs show "OTP sent to your email"
3. User has 2FA enabled in database
4. Email service is configured correctly

### Issue: OTP email not received

**Check**:
1. Email service configuration in `.env`:
   ```
   EMAIL_SERVICE=gmail
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASSWORD=your-app-password
   ```
2. Check spam folder
3. Check backend logs for email errors

## Files Modified

- `backend/src/config/initDatabase.js` - Added 2FA columns
- `backend/src/controllers/authController.js` - Login + verifyLoginOTP
- `backend/src/routes/authRoutes.js` - Added verify-login-otp route
- `lib/services/auth_service.dart` - Handle 2FA + verifyLoginOTP
- `lib/screens/rideshare/auth_screen.dart` - OTP dialog

## Future Enhancements

1. **SMS OTP**: Add SMS as alternative to email
2. **TOTP Apps**: Support authenticator apps (Google Authenticator, Authy)
3. **Backup Codes**: Generate backup codes for account recovery
4. **Remember Device**: Option to skip 2FA on trusted devices
5. **2FA During Password Reset**: Require 2FA for password resets
