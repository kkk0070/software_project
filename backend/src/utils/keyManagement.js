/**
 * Key Management Utilities
 * Handles RSA key pair generation, storage, and rotation
 */

import { generateRSAKeyPair } from './encryptionUtils.js';
import { query } from '../config/database.js';
import crypto from 'crypto';

/**
 * Generate and store a new RSA key pair
 * @param {string} keyName - Name/identifier for the key pair
 * @returns {Object} { keyId, publicKey }
 */
export const generateAndStoreKeyPair = async (keyName = 'server-master-key') => {
  try {
    const { publicKey, privateKey } = generateRSAKeyPair();
    
    // Generate a unique key ID
    const keyId = crypto.randomBytes(16).toString('hex');
    
    // Store in database
    const result = await query(`
      INSERT INTO encryption_keys (key_id, key_name, public_key, private_key, key_type, status)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, key_id, key_name, public_key, created_at
    `, [keyId, keyName, publicKey, privateKey, 'RSA-2048', 'active']);
    
    return {
      id: result.rows[0].id,
      keyId: result.rows[0].key_id,
      keyName: result.rows[0].key_name,
      publicKey: result.rows[0].public_key,
      createdAt: result.rows[0].created_at
    };
  } catch (error) {
    console.error('Error generating and storing key pair:', error);
    throw new Error('Failed to generate key pair: ' + error.message);
  }
};

/**
 * Get active public key for encryption
 * @returns {Object} { keyId, publicKey }
 */
export const getActivePublicKey = async () => {
  try {
    const result = await query(`
      SELECT key_id, public_key, key_name
      FROM encryption_keys
      WHERE status = 'active' AND key_type = 'RSA-2048'
      ORDER BY created_at DESC
      LIMIT 1
    `);
    
    if (result.rows.length === 0) {
      throw new Error('No active encryption key found');
    }
    
    return {
      keyId: result.rows[0].key_id,
      publicKey: result.rows[0].public_key,
      keyName: result.rows[0].key_name
    };
  } catch (error) {
    console.error('Error getting active public key:', error);
    throw error;
  }
};

/**
 * Get private key for decryption
 * @param {string} keyId - Key ID
 * @returns {string} Private key in PEM format
 */
export const getPrivateKey = async (keyId) => {
  try {
    const result = await query(`
      SELECT private_key
      FROM encryption_keys
      WHERE key_id = $1 AND status = 'active'
    `, [keyId]);
    
    if (result.rows.length === 0) {
      throw new Error('Private key not found or inactive');
    }
    
    return result.rows[0].private_key;
  } catch (error) {
    console.error('Error getting private key:', error);
    throw error;
  }
};

/**
 * Rotate encryption keys (mark old as rotated, generate new)
 * @returns {Object} New key pair information
 */
export const rotateKeys = async () => {
  try {
    // Mark all active keys as rotated
    await query(`
      UPDATE encryption_keys
      SET status = 'rotated', rotated_at = CURRENT_TIMESTAMP
      WHERE status = 'active'
    `);
    
    // Generate new key pair
    const newKeyPair = await generateAndStoreKeyPair('server-master-key');
    
    console.log('[SUCCESS] Encryption keys rotated successfully');
    return newKeyPair;
  } catch (error) {
    console.error('Error rotating keys:', error);
    throw new Error('Failed to rotate keys: ' + error.message);
  }
};

/**
 * Initialize key management (create first key pair if none exists)
 * @returns {Object} Key pair information or null if already initialized
 */
export const initializeKeyManagement = async () => {
  try {
    // Check if any keys exist
    const result = await query(`
      SELECT COUNT(*) as count FROM encryption_keys
    `);
    
    if (parseInt(result.rows[0].count) === 0) {
      console.log('🔐 Initializing encryption key management...');
      const keyPair = await generateAndStoreKeyPair('server-master-key');
      console.log('[SUCCESS] Master key pair generated successfully');
      return keyPair;
    }
    
    console.log('ℹ️  Encryption keys already initialized');
    return null;
  } catch (error) {
    // If table doesn't exist, that's okay - migration will handle it
    // PostgreSQL error format: 'relation "encryption_keys" does not exist'
    if (error.message && (
      error.message.includes('does not exist') || 
      error.message.includes('relation "encryption_keys"') ||
      error.code === '42P01' // PostgreSQL error code for undefined_table
    )) {
      console.log('ℹ️  Encryption keys table not yet created');
      console.log('   Run migration to create it: npm run migrate-encryption');
      return null;
    }
    console.error('Error initializing key management:', error);
    throw error;
  }
};

/**
 * Get key usage statistics
 * @returns {Object} Statistics about key usage
 */
export const getKeyStatistics = async () => {
  try {
    const result = await query(`
      SELECT 
        COUNT(*) as total_keys,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_keys,
        SUM(CASE WHEN status = 'rotated' THEN 1 ELSE 0 END) as rotated_keys,
        MAX(created_at) as latest_key_created
      FROM encryption_keys
    `);
    
    const documentsResult = await query(`
      SELECT COUNT(*) as encrypted_documents
      FROM documents
      WHERE encryption_key_id IS NOT NULL
    `);
    
    return {
      ...result.rows[0],
      encrypted_documents: documentsResult.rows[0].encrypted_documents
    };
  } catch (error) {
    console.error('Error getting key statistics:', error);
    return {
      total_keys: 0,
      active_keys: 0,
      rotated_keys: 0,
      encrypted_documents: 0
    };
  }
};
