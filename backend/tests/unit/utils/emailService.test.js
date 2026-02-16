import { sendOTPEmail, send2FAStatusEmail } from '../../../src/utils/emailService.js';

describe('Email Service', () => {
  beforeEach(() => {
    // Set up email configuration for testing
    process.env.EMAIL_USER = 'test@example.com';
    process.env.EMAIL_PASSWORD = 'test-password';
    process.env.EMAIL_SERVICE = 'gmail';
  });

  afterEach(() => {
    // Clean up environment variables
    delete process.env.EMAIL_USER;
    delete process.env.EMAIL_PASSWORD;
    delete process.env.EMAIL_SERVICE;
  });

  describe('sendOTPEmail', () => {
    test('should throw error when email is not configured', async () => {
      // Remove email configuration
      delete process.env.EMAIL_USER;
      delete process.env.EMAIL_PASSWORD;
      
      await expect(sendOTPEmail('user@example.com', '123456'))
        .rejects.toThrow('EMAIL_NOT_CONFIGURED');
    });

    test('should attempt to send with valid configuration', async () => {
      // With test credentials, it will fail to actually send
      // but we're testing that it attempts to send
      await expect(sendOTPEmail('test@example.com', '654321'))
        .rejects.toThrow('EMAIL_SEND_FAILED');
    });
  });

  describe('send2FAStatusEmail', () => {
    test('should handle missing email configuration gracefully', async () => {
      // Remove email configuration
      delete process.env.EMAIL_USER;
      delete process.env.EMAIL_PASSWORD;
      
      const result = await send2FAStatusEmail('user@example.com', false);
      
      // Function should return false when email not configured
      expect(result).toBe(false);
    });

    test('should accept valid parameters for enabling 2FA', async () => {
      const result = await send2FAStatusEmail('test@example.com', true);
      // Returns false when email fails (expected with test credentials)
      expect(result).toBe(false);
    });

    test('should accept valid parameters for disabling 2FA', async () => {
      const result = await send2FAStatusEmail('test@example.com', false);
      expect(result).toBe(false);
    });
  });
});
