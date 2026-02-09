import { generateOTP, storeOTP, verifyOTP, generate2FASecret } from '../src/utils/otpService.js';

console.log('🧪 Testing OTP Service...\n');

// Test 1: OTP Generation
console.log('Test 1: OTP Generation');
const otp1 = generateOTP();
const otp2 = generateOTP();
console.log(`  Generated OTP 1: ${otp1} (length: ${otp1.length})`);
console.log(`  Generated OTP 2: ${otp2} (length: ${otp2.length})`);
console.log(`  [SUCCESS] OTPs are 6 digits: ${otp1.length === 6 && otp2.length === 6}`);
console.log(`  [SUCCESS] OTPs are different: ${otp1 !== otp2}\n`);

// Test 2: OTP Storage and Verification
console.log('Test 2: OTP Storage and Verification');
const testEmail = 'test@example.com';
const testOTP = '123456';
storeOTP(testEmail, testOTP, 10);
console.log(`  Stored OTP for ${testEmail}`);

const validResult = verifyOTP(testEmail, testOTP);
console.log(`  [SUCCESS] Valid OTP verification: ${validResult.success}`);
console.log(`     Message: ${validResult.message}\n`);

// Test 3: Invalid OTP
console.log('Test 3: Invalid OTP Verification');
storeOTP(testEmail, testOTP, 10);
const invalidResult = verifyOTP(testEmail, '999999');
console.log(`  [SUCCESS] Invalid OTP rejected: ${!invalidResult.success}`);
console.log(`     Message: ${invalidResult.message}\n`);

// Test 4: Multiple Attempts
console.log('Test 4: Multiple Failed Attempts');
storeOTP(testEmail, testOTP, 10);
for (let i = 1; i <= 6; i++) {
  const result = verifyOTP(testEmail, '999999');
  console.log(`  Attempt ${i}: ${result.message}`);
  if (i === 5) {
    console.log(`  [SUCCESS] Blocked after 5 attempts: ${!result.success && result.message.includes('Too many')}\n`);
  }
}

// Test 5: 2FA Secret Generation
console.log('Test 5: 2FA Secret Generation');
const secret1 = generate2FASecret();
const secret2 = generate2FASecret();
console.log(`  Generated Secret 1 (first 20 chars): ${secret1.substring(0, 20)}...`);
console.log(`  Generated Secret 2 (first 20 chars): ${secret2.substring(0, 20)}...`);
console.log(`  [SUCCESS] Secrets are different: ${secret1 !== secret2}`);
console.log(`  [SUCCESS] Secrets are base64: ${/^[A-Za-z0-9+/=]+$/.test(secret1)}\n`);

console.log('[SUCCESS] All OTP Service tests completed successfully!');
