/**
 * Encryption Utilities for Document Security
 * Implements AES-256-GCM encryption and RSA key exchange
 */

import crypto from 'crypto';

// Encryption configuration
const AES_ALGORITHM = 'aes-256-gcm';
const AES_KEY_SIZE = 32; // 256 bits
const AES_IV_SIZE = 16; // 128 bits
const AES_AUTH_TAG_SIZE = 16; // 128 bits
const RSA_KEY_SIZE = 2048;
const RSA_PADDING = crypto.constants.RSA_PKCS1_OAEP_PADDING;

/**
 * Generate a secure random AES key
 * @returns {Buffer} 256-bit AES key
 */
export const generateAESKey = () => {
  return crypto.randomBytes(AES_KEY_SIZE);
};

/**
 * Generate a secure random initialization vector (IV)
 * @returns {Buffer} 128-bit IV
 */
export const generateIV = () => {
  return crypto.randomBytes(AES_IV_SIZE);
};

/**
 * Generate RSA key pair for key exchange
 * @returns {Object} { publicKey, privateKey }
 */
export const generateRSAKeyPair = () => {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: RSA_KEY_SIZE,
    publicKeyEncoding: {
      type: 'spki',
      format: 'pem'
    },
    privateKeyEncoding: {
      type: 'pkcs8',
      format: 'pem'
    }
  });
  
  return { publicKey, privateKey };
};

/**
 * Encrypt data using AES-256-GCM
 * @param {Buffer} data - Data to encrypt
 * @param {Buffer} key - AES encryption key (32 bytes)
 * @param {Buffer} iv - Initialization vector (16 bytes)
 * @returns {Object} { encryptedData, authTag }
 */
export const encryptAES = (data, key, iv) => {
  try {
    if (!Buffer.isBuffer(data)) {
      data = Buffer.from(data);
    }
    
    if (key.length !== AES_KEY_SIZE) {
      throw new Error(`AES key must be ${AES_KEY_SIZE} bytes`);
    }
    
    if (iv.length !== AES_IV_SIZE) {
      throw new Error(`IV must be ${AES_IV_SIZE} bytes`);
    }
    
    const cipher = crypto.createCipheriv(AES_ALGORITHM, key, iv);
    
    const encrypted = Buffer.concat([
      cipher.update(data),
      cipher.final()
    ]);
    
    const authTag = cipher.getAuthTag();
    
    return {
      encryptedData: encrypted,
      authTag: authTag
    };
  } catch (error) {
    throw new Error('Failed to encrypt data: ' + error.message);
  }
};

/**
 * Decrypt data using AES-256-GCM
 * @param {Buffer} encryptedData - Encrypted data
 * @param {Buffer} key - AES decryption key (32 bytes)
 * @param {Buffer} iv - Initialization vector (16 bytes)
 * @param {Buffer} authTag - Authentication tag (16 bytes)
 * @returns {Buffer} Decrypted data
 */
export const decryptAES = (encryptedData, key, iv, authTag) => {
  try {
    if (!Buffer.isBuffer(encryptedData)) {
      encryptedData = Buffer.from(encryptedData);
    }
    
    if (key.length !== AES_KEY_SIZE) {
      throw new Error(`AES key must be ${AES_KEY_SIZE} bytes`);
    }
    
    if (iv.length !== AES_IV_SIZE) {
      throw new Error(`IV must be ${AES_IV_SIZE} bytes`);
    }
    
    if (authTag.length !== AES_AUTH_TAG_SIZE) {
      throw new Error(`Auth tag must be ${AES_AUTH_TAG_SIZE} bytes`);
    }
    
    const decipher = crypto.createDecipheriv(AES_ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);
    
    const decrypted = Buffer.concat([
      decipher.update(encryptedData),
      decipher.final()
    ]);
    
    return decrypted;
  } catch (error) {
    throw new Error('Failed to decrypt data: ' + error.message);
  }
};

/**
 * Encrypt AES key using RSA public key for secure key exchange
 * @param {Buffer} aesKey - AES key to encrypt
 * @param {string} publicKey - RSA public key in PEM format
 * @returns {Buffer} Encrypted AES key
 */
export const encryptRSA = (aesKey, publicKey) => {
  try {
    const encrypted = crypto.publicEncrypt(
      {
        key: publicKey,
        padding: RSA_PADDING,
        oaepHash: 'sha256'
      },
      aesKey
    );
    
    return encrypted;
  } catch (error) {
    console.error('Error in RSA encryption:', error);
    throw new Error('Failed to encrypt key with RSA: ' + error.message);
  }
};

/**
 * Decrypt AES key using RSA private key
 * @param {Buffer} encryptedKey - Encrypted AES key
 * @param {string} privateKey - RSA private key in PEM format
 * @returns {Buffer} Decrypted AES key
 */
export const decryptRSA = (encryptedKey, privateKey) => {
  try {
    const decrypted = crypto.privateDecrypt(
      {
        key: privateKey,
        padding: RSA_PADDING,
        oaepHash: 'sha256'
      },
      encryptedKey
    );
    
    return decrypted;
  } catch (error) {
    console.error('Error in RSA decryption:', error);
    throw new Error('Failed to decrypt key with RSA: ' + error.message);
  }
};

/**
 * Encrypt file data with AES and encrypt the AES key with RSA
 * @param {Buffer} fileData - File data to encrypt
 * @param {string} publicKey - RSA public key for key exchange
 * @returns {Object} Encrypted file package with metadata
 */
export const encryptFile = (fileData, publicKey) => {
  try {
    // Generate unique AES key and IV for this file
    const aesKey = generateAESKey();
    const iv = generateIV();
    
    // Encrypt the file data with AES
    const { encryptedData, authTag } = encryptAES(fileData, aesKey, iv);
    
    // Encrypt the AES key with RSA for secure key exchange
    const encryptedKey = encryptRSA(aesKey, publicKey);
    
    return {
      encryptedData: encryptedData,
      encryptedKey: encryptedKey,
      iv: iv,
      authTag: authTag,
      algorithm: AES_ALGORITHM,
      keySize: AES_KEY_SIZE * 8, // in bits
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error encrypting file:', error);
    throw new Error('Failed to encrypt file: ' + error.message);
  }
};

/**
 * Decrypt file data by first decrypting the AES key with RSA
 * @param {Object} encryptedPackage - Encrypted file package
 * @param {string} privateKey - RSA private key for key decryption
 * @returns {Buffer} Decrypted file data
 */
export const decryptFile = (encryptedPackage, privateKey) => {
  try {
    const { encryptedData, encryptedKey, iv, authTag } = encryptedPackage;
    
    // Decrypt the AES key with RSA
    const aesKey = decryptRSA(encryptedKey, privateKey);
    
    // Decrypt the file data with AES
    const decryptedData = decryptAES(encryptedData, aesKey, iv, authTag);
    
    return decryptedData;
  } catch (error) {
    console.error('Error decrypting file:', error);
    throw new Error('Failed to decrypt file: ' + error.message);
  }
};

/**
 * Generate a hash of data for integrity verification
 * @param {Buffer} data - Data to hash
 * @returns {string} SHA-256 hash
 */
export const generateHash = (data) => {
  return crypto.createHash('sha256').update(data).digest('hex');
};

/**
 * Generate HMAC for message authentication
 * @param {Buffer} data - Data to authenticate
 * @param {Buffer} key - HMAC key
 * @returns {string} HMAC hex string
 */
export const generateHMAC = (data, key) => {
  return crypto.createHmac('sha256', key).update(data).digest('hex');
};

/**
 * Verify HMAC for message authentication
 * @param {Buffer} data - Data to verify
 * @param {Buffer} key - HMAC key
 * @param {string} hmac - HMAC to verify against
 * @returns {boolean} True if HMAC is valid
 */
export const verifyHMAC = (data, key, hmac) => {
  const computed = generateHMAC(data, key);
  return crypto.timingSafeEqual(Buffer.from(computed), Buffer.from(hmac));
};

/**
 * Get encryption information for logging/display
 * @returns {Object} Encryption configuration details
 */
export const getEncryptionInfo = () => {
  return {
    aes: {
      algorithm: AES_ALGORITHM,
      keySize: AES_KEY_SIZE * 8,
      ivSize: AES_IV_SIZE * 8,
      authTagSize: AES_AUTH_TAG_SIZE * 8,
      mode: 'GCM (Galois/Counter Mode)',
      description: 'Authenticated encryption with associated data (AEAD)'
    },
    rsa: {
      keySize: RSA_KEY_SIZE,
      padding: 'OAEP with SHA-256',
      usage: 'Key exchange and digital signatures',
      description: 'Asymmetric encryption for secure key distribution'
    },
    security: {
      confidentiality: 'HIGH - AES-256-GCM provides strong encryption',
      integrity: 'HIGH - GCM mode includes built-in authentication',
      keyExchange: 'SECURE - RSA-2048 OAEP for safe key distribution',
      recommendation: 'Industry standard encryption suitable for sensitive data'
    }
  };
};
