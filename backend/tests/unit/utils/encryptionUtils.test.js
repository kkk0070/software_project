import {
  generateAESKey,
  generateIV,
  generateRSAKeyPair,
  encryptAES,
  decryptAES
} from '../../../src/utils/encryptionUtils.js';

describe('Encryption Utils', () => {
  describe('generateAESKey', () => {
    test('should generate a 256-bit (32 byte) AES key', () => {
      const key = generateAESKey();
      
      expect(Buffer.isBuffer(key)).toBe(true);
      expect(key.length).toBe(32);
    });

    test('should generate different keys on multiple calls', () => {
      const key1 = generateAESKey();
      const key2 = generateAESKey();
      
      expect(Buffer.compare(key1, key2)).not.toBe(0);
    });

    test('should generate cryptographically secure random keys', () => {
      const keys = new Set();
      
      // Generate multiple keys and ensure they're all unique
      for (let i = 0; i < 10; i++) {
        const key = generateAESKey();
        keys.add(key.toString('hex'));
      }
      
      expect(keys.size).toBe(10);
    });
  });

  describe('generateIV', () => {
    test('should generate a 128-bit (16 byte) IV', () => {
      const iv = generateIV();
      
      expect(Buffer.isBuffer(iv)).toBe(true);
      expect(iv.length).toBe(16);
    });

    test('should generate different IVs on multiple calls', () => {
      const iv1 = generateIV();
      const iv2 = generateIV();
      
      expect(Buffer.compare(iv1, iv2)).not.toBe(0);
    });

    test('should generate random IVs', () => {
      const ivs = new Set();
      
      for (let i = 0; i < 10; i++) {
        const iv = generateIV();
        ivs.add(iv.toString('hex'));
      }
      
      expect(ivs.size).toBe(10);
    });
  });

  describe('generateRSAKeyPair', () => {
    test('should generate RSA key pair', () => {
      const keyPair = generateRSAKeyPair();
      
      expect(keyPair).toHaveProperty('publicKey');
      expect(keyPair).toHaveProperty('privateKey');
      expect(typeof keyPair.publicKey).toBe('string');
      expect(typeof keyPair.privateKey).toBe('string');
    });

    test('should generate keys in PEM format', () => {
      const keyPair = generateRSAKeyPair();
      
      expect(keyPair.publicKey).toContain('-----BEGIN PUBLIC KEY-----');
      expect(keyPair.publicKey).toContain('-----END PUBLIC KEY-----');
      expect(keyPair.privateKey).toContain('-----BEGIN PRIVATE KEY-----');
      expect(keyPair.privateKey).toContain('-----END PRIVATE KEY-----');
    });

    test('should generate different key pairs on multiple calls', () => {
      const keyPair1 = generateRSAKeyPair();
      const keyPair2 = generateRSAKeyPair();
      
      expect(keyPair1.publicKey).not.toBe(keyPair2.publicKey);
      expect(keyPair1.privateKey).not.toBe(keyPair2.privateKey);
    });
  });

  describe('encryptAES and decryptAES', () => {
    let key, iv;

    beforeEach(() => {
      key = generateAESKey();
      iv = generateIV();
    });

    test('should encrypt and decrypt data successfully', () => {
      const originalData = 'Hello, this is sensitive data!';
      const dataBuffer = Buffer.from(originalData, 'utf-8');
      
      const { encryptedData, authTag } = encryptAES(dataBuffer, key, iv);
      
      expect(Buffer.isBuffer(encryptedData)).toBe(true);
      expect(Buffer.isBuffer(authTag)).toBe(true);
      expect(encryptedData.toString('utf-8')).not.toBe(originalData);
      
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      const decryptedString = decryptedData.toString('utf-8');
      
      expect(decryptedString).toBe(originalData);
    });

    test('should handle string input in encryption', () => {
      const originalData = 'Test string data';
      
      const { encryptedData, authTag } = encryptAES(originalData, key, iv);
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      
      expect(decryptedData.toString('utf-8')).toBe(originalData);
    });

    test('should produce different ciphertext with same plaintext but different IV', () => {
      const data = 'Same data';
      const iv1 = generateIV();
      const iv2 = generateIV();
      
      const result1 = encryptAES(data, key, iv1);
      const result2 = encryptAES(data, key, iv2);
      
      expect(Buffer.compare(result1.encryptedData, result2.encryptedData)).not.toBe(0);
    });

    test('should throw error with wrong key size', () => {
      const wrongKey = Buffer.alloc(16); // Wrong size (16 instead of 32)
      const data = 'Test data';
      
      expect(() => {
        encryptAES(data, wrongKey, iv);
      }).toThrow('AES key must be 32 bytes');
    });

    test('should throw error with wrong IV size', () => {
      const wrongIV = Buffer.alloc(8); // Wrong size (8 instead of 16)
      const data = 'Test data';
      
      expect(() => {
        encryptAES(data, key, wrongIV);
      }).toThrow('IV must be 16 bytes');
    });

    test('should handle empty data', () => {
      const emptyData = Buffer.from('');
      
      const { encryptedData, authTag } = encryptAES(emptyData, key, iv);
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      
      expect(decryptedData.length).toBe(0);
    });

    test('should handle large data', () => {
      const largeData = Buffer.from('A'.repeat(10000));
      
      const { encryptedData, authTag } = encryptAES(largeData, key, iv);
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      
      expect(Buffer.compare(largeData, decryptedData)).toBe(0);
    });

    test('should generate authentication tag', () => {
      const data = 'Test data';
      const { authTag } = encryptAES(data, key, iv);
      
      expect(Buffer.isBuffer(authTag)).toBe(true);
      expect(authTag.length).toBe(16);
    });

    test('should handle binary data', () => {
      const binaryData = Buffer.from([0x00, 0x01, 0x02, 0x03, 0xFF, 0xFE, 0xFD]);
      
      const { encryptedData, authTag } = encryptAES(binaryData, key, iv);
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      
      expect(Buffer.compare(binaryData, decryptedData)).toBe(0);
    });

    test('should handle unicode characters', () => {
      const unicodeData = '你好世界 🌍 مرحبا';
      
      const { encryptedData, authTag } = encryptAES(unicodeData, key, iv);
      const decryptedData = decryptAES(encryptedData, key, iv, authTag);
      
      expect(decryptedData.toString('utf-8')).toBe(unicodeData);
    });
  });
});
