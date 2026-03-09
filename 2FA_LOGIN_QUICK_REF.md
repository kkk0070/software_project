# 2FA Login Flow - Quick Reference

## Problem Fixed ✅

1. **Database Error**: `column "two_factor_enabled" does not exist`
   - **Solution**: Added columns to `initDatabase.js`

2. **2FA Not Active During Login**
   - **Solution**: Implemented OTP verification flow in login

3. **Rate Limiting Blocking 2FA Setup** ⭐ NEW
   - **Solution**: Removed rate limiting from setup endpoints

## How It Works Now

### For Users

1. **Enable 2FA** (one-time):
   - Profile → Two-Factor Authentication → Toggle ON
   - No rate limits - retry immediately if needed
   - Enter OTP from email (or check server logs if email not configured)
   - 2FA is now enabled

2. **Login with 2FA** (every time):
   - Enter email and password
   - Receive OTP via email (rate limited for security)
   - Enter OTP in dialog
   - Login complete

### For Developers

**Backend Flow**:
```
Login → Check 2FA → Send OTP → Return requires2FA
User enters OTP → Verify OTP → Issue Token
```

**API Endpoints**:
- `POST /api/auth/login` - Returns `requires2FA: true` if enabled
- `POST /api/auth/verify-login-otp` - Verifies OTP and issues token (rate limited)
- `POST /api/auth/2fa/request-otp` - Request OTP for setup (NO rate limit)
- `POST /api/auth/2fa/enable` - Enable 2FA (NO rate limit)

**Flutter Flow**:
```dart
// 1. Login
result = await AuthService.login(email, password);

// 2. Check if 2FA required
if (result['requires2FA'] == true) {
  // Show OTP dialog
  await _show2FADialog(email, maskedEmail);
}

// 3. Verify OTP
result = await AuthService.verifyLoginOTP(email, otp);

// 4. Navigate to home
Navigator.pushReplacement(...);
```

## Quick Setup

### Database Migration

If you get "column does not exist" error:

```bash
cd backend
npm run init-db
```

Or run migration:
```bash
node src/config/migrate2FA.js
```

### Email Configuration (Optional)

In `backend/.env`:
```env
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM_NAME=SePro App
```

**Note**: Email is now optional! If not configured:
- OTPs are logged to console
- 2FA still works normally
- Great for development

## Testing

### Test 2FA Setup (No Rate Limits!)

1. Login to app normally
2. Go to Profile → Enable 2FA
3. Click request OTP (can retry immediately)
4. Check email OR server console for OTP:
   ```
   ⚠️  Email service not configured. OTP for user@email.com: 395847
   ```
5. Enter OTP to enable
6. Can retry unlimited times!

### API Test

```bash
# Request OTP (no rate limit)
curl -X POST http://localhost:5000/api/auth/2fa/request-otp \
  -H "Authorization: ******" \
  -H "Content-Type: application/json"

# Enable 2FA (no rate limit)
curl -X POST http://localhost:5000/api/auth/2fa/enable \
  -H "Authorization: ******" \
  -H "Content-Type: application/json" \
  -d '{"otp":"123456"}'

# Login (rate limited - 3 per 15 min)
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Key Features

✅ OTP sent via email (or logged to console)
✅ OTP expires in 10 minutes
✅ Max 5 attempts per OTP
✅ Rate limiting on LOGIN (3 per 15 min) for security
✅ NO rate limiting on SETUP endpoints
✅ Email masking (us***@example.com)
✅ Secure crypto-based OTP generation
✅ Full UI/UX implementation
✅ Works without email configuration

## Files Changed

**Backend**:
- `backend/src/config/initDatabase.js` - Added 2FA columns
- `backend/src/controllers/authController.js` - Login + setup + error handling
- `backend/src/routes/authRoutes.js` - Removed rate limiting from setup

**Frontend**:
- `lib/services/auth_service.dart`
- `lib/screens/rideshare/auth_screen.dart`

## Documentation

For detailed documentation, see:
- `2FA_LOGIN_FLOW.md` - Complete implementation guide
- `2FA_IMPLEMENTATION.md` - Original 2FA feature docs
- `2FA_QUICKSTART.md` - 2FA setup guide
- `2FA_RATE_LIMIT_FIX.md` - Rate limiting changes ⭐ NEW

## Common Issues

**Q: OTP dialog doesn't show**
A: Check backend logs, ensure user has 2FA enabled in database

**Q: Email not received**
A: Check server console for OTP (logged for development)
   ```
   ⚠️  Email service not configured. OTP for user@email.com: 395847
   ```

**Q: Getting rate limited**
A: This should no longer happen for setup! Only login OTP is rate limited.

**Q: "column does not exist" error**
A: Run `npm run init-db` in backend directory

**Q: OTP verification fails**
A: Check OTP hasn't expired (10 min), check attempts (max 5)

## What Changed (Latest Update)

### Removed Rate Limiting:
- ❌ No more rate limits on 2FA setup endpoints
- ✅ Can retry setup immediately
- ✅ Better development experience

### Improved Error Handling:
- ❌ Email errors don't block 2FA anymore
- ✅ 2FA works without email configuration
- ✅ OTPs logged to console in development

### Security Maintained:
- ✅ Login OTP still rate limited (3 per 15 min)
- ✅ Disable 2FA still rate limited (10 per 15 min)
- ✅ All endpoints require authentication
- ✅ OTP expiry and attempt limits unchanged

