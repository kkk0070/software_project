# 2FA Implementation - Quick Start Guide

## What Was Implemented

✅ **Backend (Node.js)**
- 4 new API endpoints for 2FA management
- Email service using nodemailer (compatible with Gmail, emailjs, etc.)
- Crypto-based OTP generation (secure 6-digit codes)
- Database schema migration for 2FA fields
- Complete error handling and validation

✅ **Frontend (Flutter)**
- 2FA toggle in user profile screen
- OTP verification dialog
- Password confirmation for disabling 2FA
- Real-time status updates
- Beautiful UI with loading states

✅ **Security Features**
- OTP expires in 10 minutes
- Maximum 5 verification attempts per OTP
- Password required to disable 2FA
- Email notifications on status changes
- Crypto-based random generation

## User Flow Diagram

```
ENABLING 2FA:
┌─────────────────────────────────────────────────────────────┐
│ 1. User Profile Screen                                      │
│    └─> Toggle 2FA switch ON                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Backend generates OTP                                    │
│    └─> 6-digit code using crypto.randomBytes()             │
│    └─> Stores OTP with 10-min expiry                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Email sent via nodemailer                                │
│    └─> Formatted HTML email with OTP                        │
│    └─> Security warnings included                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. User receives email                                      │
│    └─> Opens OTP dialog in app                             │
│    └─> Enters 6-digit code                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Backend verifies OTP                                     │
│    └─> Checks expiry (10 minutes)                          │
│    └─> Validates code                                       │
│    └─> Updates user.two_factor_enabled = true              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Confirmation                                             │
│    └─> Success message shown                                │
│    └─> Confirmation email sent                              │
│    └─> Toggle shows ON                                      │
└─────────────────────────────────────────────────────────────┘

DISABLING 2FA:
┌─────────────────────────────────────────────────────────────┐
│ 1. User Profile Screen                                      │
│    └─> Toggle 2FA switch OFF                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Password dialog appears                                  │
│    └─> User enters account password                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Backend verifies password                                │
│    └─> Uses bcrypt.compare()                                │
│    └─> Updates user.two_factor_enabled = false             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Confirmation                                             │
│    └─> Success message shown                                │
│    └─> Notification email sent                              │
│    └─> Toggle shows OFF                                     │
└─────────────────────────────────────────────────────────────┘
```

## Setup (5 Minutes)

### Step 1: Configure Email (Backend)

Create `backend/.env` file:
```bash
# Copy from .env.example
cp backend/.env.example backend/.env
```

Edit `backend/.env` and set:
```env
# For Gmail (recommended for testing)
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password  # Generate from Google Account Settings
EMAIL_FROM_NAME=SePro App

# Database and JWT (if not already set)
JWT_SECRET=your_jwt_secret_here
DB_PASSWORD=your_db_password
```

**Getting Gmail App Password:**
1. Go to https://myaccount.google.com/security
2. Enable "2-Step Verification"
3. Go to "App passwords"
4. Generate password for "Mail"
5. Copy and paste into EMAIL_PASSWORD

### Step 2: Run Database Migration

```bash
cd backend
node src/config/migrate2FA.js
```

This adds `two_factor_enabled` and `two_factor_secret` columns to users table.

### Step 3: Start Backend

```bash
cd backend
npm run dev
```

### Step 4: Test the App

1. Open the Flutter app
2. Navigate to User Profile
3. Look for "Two-Factor Authentication" toggle
4. Toggle it ON
5. Check your email for OTP
6. Enter OTP in the dialog
7. See confirmation!

## API Endpoints Reference

All endpoints require Bearer token authentication.

### Get 2FA Status
```bash
curl -X GET http://localhost:5000/api/auth/2fa/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Request OTP
```bash
curl -X POST http://localhost:5000/api/auth/2fa/request-otp \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Enable 2FA
```bash
curl -X POST http://localhost:5000/api/auth/2fa/enable \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"otp": "123456"}'
```

### Disable 2FA
```bash
curl -X POST http://localhost:5000/api/auth/2fa/disable \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"password": "your_password"}'
```

## Testing Checklist

Backend Tests:
- [x] OTP generation creates 6-digit codes
- [x] OTP verification works correctly
- [x] Attempt limiting blocks after 5 tries
- [x] 2FA secret generation is unique

Manual Tests:
- [ ] Email configuration works
- [ ] OTP email is received
- [ ] Enable 2FA flow completes
- [ ] OTP verification works
- [ ] Disable 2FA with password works
- [ ] UI updates correctly

## Files Modified/Created

**Backend:**
- `src/utils/emailService.js` - Email sending with nodemailer
- `src/utils/otpService.js` - OTP generation with crypto
- `src/controllers/authController.js` - 2FA endpoints
- `src/routes/authRoutes.js` - 2FA routes
- `src/config/migrate2FA.js` - Database migration
- `.env.example` - Email configuration template
- `test/testOTPService.js` - Unit tests

**Frontend:**
- `lib/services/auth_service.dart` - 2FA API methods
- `lib/screens/rideshare/user_profile_screen.dart` - 2FA UI
- `lib/screens/settings_screen.dart` - Settings updates

**Documentation:**
- `2FA_IMPLEMENTATION.md` - Comprehensive guide
- `2FA_QUICKSTART.md` - This file

## Troubleshooting

**Email not sending?**
- Check EMAIL_USER and EMAIL_PASSWORD in .env
- Verify Gmail app password is correct
- Check spam folder
- Look at backend console for errors

**OTP not verifying?**
- Make sure you enter it within 10 minutes
- Check for typos
- Request a new OTP if needed

**Toggle not working?**
- Check backend is running
- Verify network connection
- Check browser/app console for errors
- Verify JWT token is valid

## Next Steps

The 2FA feature is now ready! Consider:

1. **Test thoroughly** with real email addresses
2. **Configure production email** service (SendGrid, AWS SES, etc.)
3. **Add 2FA to login flow** (future enhancement)
4. **Monitor email delivery** rates
5. **Consider SMS OTP** as alternative option

For detailed technical documentation, see `2FA_IMPLEMENTATION.md`.
