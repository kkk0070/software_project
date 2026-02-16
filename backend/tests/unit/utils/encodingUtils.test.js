import {
  encodeToBase64,
  decodeFromBase64,
  encodeFileToBase64,
  decodeBase64ToBuffer,
  getEncodingInfo
} from '../../../src/utils/encodingUtils.js';

describe('Encoding Utils', () => {
  describe('encodeToBase64', () => {
    test('should encode string to Base64', () => {
      const input = 'Hello World';
      const result = encodeToBase64(input);
      
      expect(result).toBe('SGVsbG8gV29ybGQ=');
      expect(typeof result).toBe('string');
    });

    test('should encode buffer to Base64', () => {
      const buffer = Buffer.from('Test Data', 'utf-8');
      const result = encodeToBase64(buffer);
      
      expect(result).toBe('VGVzdCBEYXRh');
    });

    test('should handle empty string', () => {
      const result = encodeToBase64('');
      expect(result).toBe('');
    });

    test('should handle special characters', () => {
      const input = '!@#$%^&*()_+-={}[]|\\:";\'<>?,./';
      const result = encodeToBase64(input);
      const decoded = decodeFromBase64(result);
      
      expect(decoded).toBe(input);
    });

    test('should handle unicode characters', () => {
      const input = '你好世界 🌍';
      const result = encodeToBase64(input);
      const decoded = decodeFromBase64(result);
      
      expect(decoded).toBe(input);
    });
  });

  describe('decodeFromBase64', () => {
    test('should decode Base64 string', () => {
      const encoded = 'SGVsbG8gV29ybGQ=';
      const result = decodeFromBase64(encoded);
      
      expect(result).toBe('Hello World');
    });

    test('should decode empty Base64 string', () => {
      const result = decodeFromBase64('');
      expect(result).toBe('');
    });

    test('should handle invalid Base64', () => {
      // Invalid Base64 doesn't throw - it just decodes incorrectly
      // This is expected behavior with Buffer.from()
      const result = decodeFromBase64('Invalid!!!Base64');
      expect(result).toBeDefined();
    });

    test('should correctly decode encoded data', () => {
      const original = 'Testing decoding functionality';
      const encoded = encodeToBase64(original);
      const decoded = decodeFromBase64(encoded);
      
      expect(decoded).toBe(original);
    });
  });

  describe('encodeFileToBase64', () => {
    test('should encode file buffer to Base64', () => {
      const fileBuffer = Buffer.from('File content here', 'utf-8');
      const result = encodeFileToBase64(fileBuffer);
      
      expect(typeof result).toBe('string');
      expect(result).toBe('RmlsZSBjb250ZW50IGhlcmU=');
    });

    test('should handle empty buffer', () => {
      const emptyBuffer = Buffer.from('', 'utf-8');
      const result = encodeFileToBase64(emptyBuffer);
      
      expect(result).toBe('');
    });

    test('should encode binary data', () => {
      const binaryBuffer = Buffer.from([0x48, 0x65, 0x6c, 0x6c, 0x6f]);
      const result = encodeFileToBase64(binaryBuffer);
      
      expect(result).toBe('SGVsbG8=');
    });
  });

  describe('decodeBase64ToBuffer', () => {
    test('should decode Base64 to buffer', () => {
      const encoded = 'RmlsZSBjb250ZW50IGhlcmU=';
      const result = decodeBase64ToBuffer(encoded);
      
      expect(Buffer.isBuffer(result)).toBe(true);
      expect(result.toString('utf-8')).toBe('File content here');
    });

    test('should handle empty string', () => {
      const result = decodeBase64ToBuffer('');
      
      expect(Buffer.isBuffer(result)).toBe(true);
      expect(result.length).toBe(0);
    });

    test('should round-trip encode and decode', () => {
      const original = Buffer.from('Test file data', 'utf-8');
      const encoded = encodeFileToBase64(original);
      const decoded = decodeBase64ToBuffer(encoded);
      
      expect(Buffer.compare(original, decoded)).toBe(0);
    });
  });

  describe('getEncodingInfo', () => {
    test('should return encoding information', () => {
      const original = 'Test data';
      const encoded = encodeToBase64(original);
      const info = getEncodingInfo(original, encoded);
      
      expect(info).toHaveProperty('technique');
      expect(info).toHaveProperty('originalSize');
      expect(info).toHaveProperty('encodedSize');
      expect(info).toHaveProperty('overhead');
      expect(info).toHaveProperty('description');
      
      expect(info.technique).toBe('Base64');
      expect(typeof info.originalSize).toBe('number');
      expect(typeof info.encodedSize).toBe('number');
    });

    test('should calculate overhead percentage', () => {
      const original = 'Hello';
      const encoded = encodeToBase64(original);
      const info = getEncodingInfo(original, encoded);
      
      expect(info.overhead).toMatch(/^\d+\.\d+%$/);
      expect(info.encodedSize).toBeGreaterThan(info.originalSize);
    });

    test('should handle different data sizes', () => {
      const smallData = 'A';
      const largeData = 'A'.repeat(1000);
      
      const smallEncoded = encodeToBase64(smallData);
      const largeEncoded = encodeToBase64(largeData);
      
      const smallInfo = getEncodingInfo(smallData, smallEncoded);
      const largeInfo = getEncodingInfo(largeData, largeEncoded);
      
      expect(smallInfo.originalSize).toBeLessThan(largeInfo.originalSize);
      expect(smallInfo.encodedSize).toBeLessThan(largeInfo.encodedSize);
    });
  });

  describe('Integration tests', () => {
    test('should maintain data integrity through encode/decode cycle', () => {
      const testCases = [
        'Simple text',
        '123456789',
        'Special chars: !@#$%',
        '{"json": "data", "number": 123}',
        'Multi\nLine\nText',
        'Tab\tSeparated\tValues'
      ];

      testCases.forEach(testCase => {
        const encoded = encodeToBase64(testCase);
        const decoded = decodeFromBase64(encoded);
        expect(decoded).toBe(testCase);
      });
    });

    test('should handle large data', () => {
      const largeString = 'A'.repeat(10000);
      const encoded = encodeToBase64(largeString);
      const decoded = decodeFromBase64(encoded);
      
      expect(decoded).toBe(largeString);
      expect(decoded.length).toBe(10000);
    });
  });
});
