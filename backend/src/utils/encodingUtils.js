/**
 * Encoding Utilities for Document Security
 * Implements Base64 encoding/decoding techniques
 */

/**
 * Encode data to Base64
 * @param {string|Buffer} data - Data to encode
 * @returns {string} Base64 encoded string
 */
export const encodeToBase64 = (data) => {
  try {
    if (Buffer.isBuffer(data)) {
      return data.toString('base64');
    }
    return Buffer.from(data, 'utf-8').toString('base64');
  } catch (error) {
    console.error('Error encoding to Base64:', error);
    throw new Error('Failed to encode data');
  }
};

/**
 * Decode Base64 data
 * @param {string} encodedData - Base64 encoded string
 * @returns {string} Decoded string
 */
export const decodeFromBase64 = (encodedData) => {
  try {
    return Buffer.from(encodedData, 'base64').toString('utf-8');
  } catch (error) {
    console.error('Error decoding from Base64:', error);
    throw new Error('Failed to decode data');
  }
};

/**
 * Encode file buffer to Base64
 * @param {Buffer} fileBuffer - File buffer to encode
 * @returns {string} Base64 encoded file
 */
export const encodeFileToBase64 = (fileBuffer) => {
  try {
    return fileBuffer.toString('base64');
  } catch (error) {
    console.error('Error encoding file to Base64:', error);
    throw new Error('Failed to encode file');
  }
};

/**
 * Decode Base64 to buffer
 * @param {string} encodedFile - Base64 encoded file
 * @returns {Buffer} Decoded buffer
 */
export const decodeBase64ToBuffer = (encodedFile) => {
  try {
    return Buffer.from(encodedFile, 'base64');
  } catch (error) {
    console.error('Error decoding Base64 to buffer:', error);
    throw new Error('Failed to decode file');
  }
};

/**
 * Get encoding information
 * @param {string} originalData - Original data
 * @param {string} encodedData - Encoded data
 * @returns {Object} Encoding information
 */
export const getEncodingInfo = (originalData, encodedData) => {
  const originalSize = Buffer.byteLength(originalData, 'utf-8');
  const encodedSize = Buffer.byteLength(encodedData, 'utf-8');
  const overhead = ((encodedSize - originalSize) / originalSize * 100).toFixed(2);
  
  return {
    technique: 'Base64',
    originalSize,
    encodedSize,
    overhead: `${overhead}%`,
    description: 'Base64 encoding converts binary data to ASCII text format'
  };
};
