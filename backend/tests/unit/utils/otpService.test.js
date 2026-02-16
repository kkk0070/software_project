import { generateOTP, storeOTP, verifyOTP, generate2FASecret } from '../../../src/utils/otpService.js';

describe('OTP Service', () => {
  describe('generateOTP', () => {
    test('should generate a 6-digit OTP', () => {
      const otp = generateOTP();
      expect(otp).toHaveLength(6);
      expect(otp).toMatch(/^\d{6}$/);
    });

    test('should generate different OTPs on multiple calls', () => {
      const otp1 = generateOTP();
      const otp2 = generateOTP();
      const otp3 = generateOTP();
      
      // At least two should be different (statistically very likely)
      expect(otp1 === otp2 && otp2 === otp3).toBe(false);
    });

    test('should generate valid numeric OTPs', () => {
      const otp = generateOTP();
      const numericValue = parseInt(otp, 10);
      expect(numericValue).toBeGreaterThanOrEqual(100000);
      expect(numericValue).toBeLessThanOrEqual(999999);
    });
  });

  describe('storeOTP and verifyOTP', () => {
    const testEmail = 'test@example.com';
    const testOTP = '123456';

    beforeEach(() => {
      // Clear any existing OTP for test email before each test
      verifyOTP(testEmail, testOTP);
    });

    test('should store and verify a valid OTP', () => {
      storeOTP(testEmail, testOTP, 10);
      const result = verifyOTP(testEmail, testOTP);
      
      expect(result.success).toBe(true);
      expect(result.message).toContain('verified');
    });

    test('should reject invalid OTP', () => {
      storeOTP(testEmail, testOTP, 10);
      const result = verifyOTP(testEmail, '999999');
      
      expect(result.success).toBe(false);
      expect(result.message).toContain('Invalid OTP');
    });

    test('should reject OTP for non-existent email', () => {
      const result = verifyOTP('nonexistent@example.com', testOTP);
      
      expect(result.success).toBe(false);
      expect(result.message).toContain('No OTP found');
    });

    test('should block after 5 failed attempts', () => {
      storeOTP(testEmail, testOTP, 10);
      
      // Try 5 incorrect OTPs
      for (let i = 0; i < 5; i++) {
        verifyOTP(testEmail, '999999');
      }
      
      // 6th attempt should be blocked
      const result = verifyOTP(testEmail, testOTP);
      expect(result.success).toBe(false);
      expect(result.message).toContain('Too many');
    });

    test('should remove OTP after successful verification', () => {
      storeOTP(testEmail, testOTP, 10);
      
      // First verification should succeed
      let result = verifyOTP(testEmail, testOTP);
      expect(result.success).toBe(true);
      
      // Second verification should fail (OTP removed)
      result = verifyOTP(testEmail, testOTP);
      expect(result.success).toBe(false);
    });
  });

  describe('generate2FASecret', () => {
    test('should generate a base64 secret', () => {
      const secret = generate2FASecret();
      expect(secret).toBeTruthy();
      expect(secret.length).toBeGreaterThan(0);
      // Base64 regex pattern
      expect(secret).toMatch(/^[A-Za-z0-9+/=]+$/);
    });

    test('should generate different secrets on multiple calls', () => {
      const secret1 = generate2FASecret();
      const secret2 = generate2FASecret();
      
      expect(secret1).not.toBe(secret2);
    });

    test('should generate secrets of reasonable length', () => {
      const secret = generate2FASecret();
      // Typically 32+ bytes base64 encoded
      expect(secret.length).toBeGreaterThan(20);
    });
  });
});
