# Two-Factor Authentication (2FA) Implementation

This document describes the implementation of Two-Factor Authentication (2FA) feature in the SePro application.

## Overview

The 2FA feature adds an extra layer of security to user accounts by requiring email verification with a One-Time Password (OTP) when enabling the feature.

## Features

- ✅ Toggle 2FA on/off from user profile settings
- ✅ Email-based OTP verification using crypto for secure generation
- ✅ OTP expiration (10 minutes)
- ✅ Attempt limiting (5 attempts per OTP)
- ✅ Password confirmation required to disable 2FA
- ✅ Email notifications for 2FA status changes

## Backend Implementation

### Database Schema

Two new fields added to the `users` table:
- `two_factor_enabled` (BOOLEAN): Whether 2FA is enabled for the user
- `two_factor_secret` (VARCHAR): Encrypted secret for 2FA (base64 encoded)

### API Endpoints

All endpoints require authentication (Bearer token).

#### Get 2FA Status
```
GET /api/auth/2fa/status
Response: { success: true, data: { two_factor_enabled: boolean } }
```

#### Request OTP
```
POST /api/auth/2fa/request-otp
Response: { success: true, message: "OTP sent to your email address" }
```

#### Enable 2FA
```
POST /api/auth/2fa/enable
Body: { otp: "123456" }
Response: { success: true, message: "Two-factor authentication enabled successfully" }
```

#### Disable 2FA
```
POST /api/auth/2fa/disable
Body: { password: "user_password" }
Response: { success: true, message: "Two-factor authentication disabled successfully" }
```

### Core Services

#### OTP Service (`backend/src/utils/otpService.js`)
- `generateOTP()`: Generates 6-digit OTP using Node.js crypto module
- `storeOTP(email, otp, expiryMinutes)`: Stores OTP with expiration
- `verifyOTP(email, otp)`: Verifies OTP with attempt limiting
- `generate2FASecret()`: Generates secure random secret for 2FA

#### Email Service (`backend/src/utils/emailService.js`)
- `sendOTPEmail(to, otp, userName)`: Sends formatted OTP email
- `send2FAStatusEmail(to, userName, enabled)`: Sends 2FA status notification
- Uses nodemailer (compatible with emailjs and other SMTP services)

## Frontend Implementation (Flutter)

### Auth Service Updates

New methods added to `lib/services/auth_service.dart`:
- `get2FAStatus()`: Fetch current 2FA status
- `request2FAOTP()`: Request OTP via email
- `enable2FA(otp)`: Enable 2FA with OTP verification
- `disable2FA(password)`: Disable 2FA with password confirmation

### UI Components

#### User Profile Screen (`lib/screens/rideshare/user_profile_screen.dart`)
- 2FA toggle switch with status indicator
- OTP verification dialog
- Password confirmation dialog for disabling 2FA
- Loading states and error handling

## Setup Instructions

### Backend Setup

1. Install dependencies (already done):
   ```bash
   cd backend
   npm install
   ```

2. Configure email service in `.env`:
   ```env
   # Email Configuration for 2FA
   EMAIL_SERVICE=gmail
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASSWORD=your_app_specific_password
   EMAIL_FROM_NAME=SePro App
   
   # SMTP Configuration (if not using Gmail)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_SECURE=false
   ```

3. Run database migration:
   ```bash
   cd backend
   node src/config/migrate2FA.js
   ```

4. Restart the backend server:
   ```bash
   npm run dev
   ```

### Gmail App Password Setup (Recommended)

For Gmail users:
1. Go to Google Account settings
2. Enable 2-Step Verification
3. Go to "App passwords" section
4. Generate a new app password for "Mail"
5. Use this password in `EMAIL_PASSWORD` environment variable

### Frontend Setup

No additional setup required. The Flutter app will automatically use the new 2FA endpoints.

## Security Features

1. **Crypto-based OTP Generation**: Uses Node.js crypto module for secure random number generation
2. **Time-limited OTPs**: OTPs expire after 10 minutes
3. **Attempt Limiting**: Maximum 5 attempts per OTP
4. **Password Verification**: Requires password to disable 2FA
5. **Email Notifications**: Users receive email notifications when 2FA status changes
6. **Secure Storage**: 2FA secrets are stored encrypted in the database

## User Flow

### Enabling 2FA
1. User toggles 2FA switch in profile settings
2. System generates and sends OTP to user's email
3. User enters 6-digit OTP in verification dialog
4. System validates OTP and enables 2FA
5. User receives confirmation email

### Disabling 2FA
1. User toggles 2FA switch off in profile settings
2. System prompts for password confirmation
3. User enters password
4. System validates password and disables 2FA
5. User receives confirmation email

## Testing

### Manual Testing Checklist

Backend:
- [ ] Database migration runs successfully
- [ ] OTP generation produces valid 6-digit codes
- [ ] Email sending works with configured SMTP
- [ ] OTP verification validates correctly
- [ ] OTP expiration works after 10 minutes
- [ ] Attempt limiting blocks after 5 failed attempts
- [ ] Password verification works for disabling 2FA

Frontend:
- [ ] 2FA toggle displays current status
- [ ] Request OTP shows loading and success message
- [ ] OTP dialog accepts 6-digit input
- [ ] OTP verification shows success/error messages
- [ ] Password dialog validates input
- [ ] 2FA status updates immediately after enable/disable

Integration:
- [ ] End-to-end enable 2FA flow
- [ ] End-to-end disable 2FA flow
- [ ] Email delivery (check inbox and spam)
- [ ] Error handling for network issues
- [ ] Error handling for invalid OTP
- [ ] Error handling for expired OTP

## Known Limitations

1. **OTP Storage**: Currently stored in memory (Map). In production, use Redis or database for persistence across server restarts.
2. **Rate Limiting**: No rate limiting on OTP requests. Consider adding rate limiting in production.
3. **Login Flow**: 2FA is enabled but not yet integrated into the login flow. This would require additional implementation.

## Future Enhancements

1. Integrate 2FA verification into login flow
2. Add SMS-based OTP as alternative to email
3. Implement TOTP (Time-based One-Time Password) apps support
4. Add backup codes for account recovery
5. Implement Redis for OTP storage in production
6. Add rate limiting for OTP requests
7. Add audit logging for 2FA events

## Troubleshooting

### Email Not Sending
- Verify `EMAIL_USER` and `EMAIL_PASSWORD` in `.env`
- Check if Gmail app password is correct
- Verify SMTP settings
- Check server logs for email errors

### OTP Not Verifying
- Ensure OTP is entered within 10 minutes
- Check for typos in OTP
- Verify email contains correct OTP
- Check server logs for verification attempts

### 2FA Toggle Not Working
- Verify backend is running
- Check network connectivity
- Verify JWT token is valid
- Check console logs for API errors

## Support

For issues or questions, please check:
1. Server logs: `backend/` directory
2. Flutter debug console
3. Network tab in browser/app inspector
4. Email service logs
