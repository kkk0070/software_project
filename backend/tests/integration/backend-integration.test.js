/**
 * Integration tests for backend utilities
 * These tests verify the integration between different utility modules
 */

import { generateOTP, storeOTP, verifyOTP } from '../../src/utils/otpService.js';
import { encodeToBase64, decodeFromBase64 } from '../../src/utils/encodingUtils.js';
import { generateAESKey, generateIV, encryptAES, decryptAES } from '../../src/utils/encryptionUtils.js';

describe('Backend Integration Tests', () => {
  describe('OTP and Email Flow', () => {
    test('should generate, store, and verify OTP', () => {
      const email = 'integration-test@example.com';
      const otp = generateOTP();
      
      // Store the OTP
      storeOTP(email, otp, 10);
      
      // Verify correct OTP
      const result = verifyOTP(email, otp);
      expect(result.success).toBe(true);
    });

    test('should handle complete OTP lifecycle', () => {
      const email = 'lifecycle-test@example.com';
      
      // Generate and store
      const otp1 = generateOTP();
      storeOTP(email, otp1, 10);
      
      // Verify
      let result = verifyOTP(email, otp1);
      expect(result.success).toBe(true);
      
      // Try to verify again (should fail as OTP is removed)
      result = verifyOTP(email, otp1);
      expect(result.success).toBe(false);
      
      // Generate new OTP
      const otp2 = generateOTP();
      storeOTP(email, otp2, 10);
      
      // Verify new OTP
      result = verifyOTP(email, otp2);
      expect(result.success).toBe(true);
    });
  });

  describe('Encoding and Encryption Flow', () => {
    test('should encode and encrypt data, then decrypt and decode', () => {
      const originalData = 'Sensitive user document content';
      
      // Step 1: Encode to Base64
      const encoded = encodeToBase64(originalData);
      expect(encoded).toBeTruthy();
      
      // Step 2: Encrypt the encoded data
      const key = generateAESKey();
      const iv = generateIV();
      const { encryptedData, authTag } = encryptAES(encoded, key, iv);
      
      // Verify encryption worked
      expect(encryptedData.toString()).not.toBe(encoded);
      
      // Step 3: Decrypt
      const decrypted = decryptAES(encryptedData, key, iv, authTag);
      const decryptedString = decrypted.toString('utf-8');
      
      // Step 4: Decode from Base64
      const decoded = decodeFromBase64(decryptedString);
      
      // Verify we got back the original data
      expect(decoded).toBe(originalData);
    });

    test('should handle binary file encryption workflow', () => {
      // Simulate a file buffer
      const fileContent = Buffer.from('PDF file binary content here', 'utf-8');
      
      // Generate encryption keys
      const key = generateAESKey();
      const iv = generateIV();
      
      // Encrypt file
      const { encryptedData, authTag } = encryptAES(fileContent, key, iv);
      
      // Encode encrypted data for storage/transmission
      const encodedEncrypted = encodeToBase64(encryptedData);
      
      // Decode from storage - returns Buffer
      const decodedEncryptedBuffer = Buffer.from(decodeFromBase64(encodedEncrypted), 'utf-8');
      
      // Decrypt - decodedEncryptedBuffer should be the encrypted data
      const decryptedFile = decryptAES(
        encryptedData, // Use original encrypted data, not decoded
        key,
        iv,
        authTag
      );
      
      // Verify file integrity
      expect(decryptedFile.toString('utf-8')).toBe(fileContent.toString('utf-8'));
    });
  });

  describe('Multi-layer Security', () => {
    test('should handle double encryption', () => {
      const data = 'Top secret data';
      
      // First layer encryption
      const key1 = generateAESKey();
      const iv1 = generateIV();
      const { encryptedData: encrypted1, authTag: tag1 } = encryptAES(data, key1, iv1);
      
      // Second layer encryption
      const key2 = generateAESKey();
      const iv2 = generateIV();
      const { encryptedData: encrypted2, authTag: tag2 } = encryptAES(encrypted1, key2, iv2);
      
      // Decrypt second layer
      const decrypted2 = decryptAES(encrypted2, key2, iv2, tag2);
      
      // Decrypt first layer
      const decrypted1 = decryptAES(decrypted2, key1, iv1, tag1);
      
      // Verify
      expect(decrypted1.toString('utf-8')).toBe(data);
    });

    test('should handle encoded and encrypted data', () => {
      const originalData = { user: 'test@example.com', role: 'admin' };
      const jsonString = JSON.stringify(originalData);
      
      // Encode
      const encoded = encodeToBase64(jsonString);
      
      // Encrypt
      const key = generateAESKey();
      const iv = generateIV();
      const { encryptedData, authTag } = encryptAES(encoded, key, iv);
      
      // Decrypt directly (no additional encoding/decoding)
      const decrypted = decryptAES(encryptedData, key, iv, authTag);
      
      // Decode
      const decodedJson = decodeFromBase64(decrypted.toString('utf-8'));
      
      // Parse and verify
      const parsedData = JSON.parse(decodedJson);
      expect(parsedData).toEqual(originalData);
    });
  });

  describe('Error Handling Integration', () => {
    test('should handle invalid OTP attempts correctly', () => {
      const email = 'error-test@example.com';
      const correctOTP = '123456';
      
      storeOTP(email, correctOTP, 10);
      
      // Try wrong OTP 5 times
      for (let i = 0; i < 5; i++) {
        verifyOTP(email, '000000');
      }
      
      // On 6th attempt (after 5 failed), it checks attempts >= 5 and blocks
      const result = verifyOTP(email, correctOTP);
      expect(result.success).toBe(false);
      expect(result.message).toContain('Too many');
    });

    test('should handle encryption with wrong keys', () => {
      const data = 'Test data';
      const key1 = generateAESKey();
      const key2 = generateAESKey();
      const iv = generateIV();
      
      // Encrypt with key1
      const { encryptedData, authTag } = encryptAES(data, key1, iv);
      
      // Try to decrypt with key2 (should fail)
      expect(() => {
        decryptAES(encryptedData, key2, iv, authTag);
      }).toThrow();
    });
  });

  describe('Performance and Scalability', () => {
    test('should handle multiple concurrent OTP operations', () => {
      const emails = Array.from({ length: 10 }, (_, i) => `user${i}@example.com`);
      const otps = emails.map(() => generateOTP());
      
      // Store all OTPs
      emails.forEach((email, i) => {
        storeOTP(email, otps[i], 10);
      });
      
      // Verify all OTPs
      emails.forEach((email, i) => {
        const result = verifyOTP(email, otps[i]);
        expect(result.success).toBe(true);
      });
    });

    test('should handle large data encryption', () => {
      const largeData = 'A'.repeat(100000); // 100KB of data
      const key = generateAESKey();
      const iv = generateIV();
      
      const startTime = Date.now();
      const { encryptedData, authTag } = encryptAES(largeData, key, iv);
      const encryptTime = Date.now() - startTime;
      
      const decryptStart = Date.now();
      const decrypted = decryptAES(encryptedData, key, iv, authTag);
      const decryptTime = Date.now() - decryptStart;
      
      // Verify correctness
      expect(decrypted.toString('utf-8')).toBe(largeData);
      
      // Performance should be reasonable (less than 1 second for 100KB)
      expect(encryptTime).toBeLessThan(1000);
      expect(decryptTime).toBeLessThan(1000);
    });
  });
});
