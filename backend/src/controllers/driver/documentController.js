import { knex } from '../../config/database.js';
import multer from 'multer';
import path from 'path';
import fs from 'fs/promises';
import fsSync from 'fs';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { encodeFileToBase64, getEncodingInfo } from '../../utils/encodingUtils.js';
import { analyzeBase64Security, generateSecurityReport, getSecuritySummary } from '../../utils/securityAnalysis.js';
import { encryptFile, decryptFile, generateHash, getEncryptionInfo } from '../../utils/encryptionUtils.js';
import { getActivePublicKey, getPrivateKey } from '../../utils/keyManagement.js';
import { analyzeEncryptionSecurity, generateEncryptionReport, getEncryptionSummary } from '../../utils/encryptionSecurityAnalysis.js';
import { createPostResponse } from '../../utils/responseHelper.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../../uploads');
if (!fsSync.existsSync(uploadsDir)) {
  fsSync.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter to allow only specific file types
const fileFilter = (req, file, cb) => {
  // Define allowed extensions and mimetypes
  const allowedExtensions = /\.(jpeg|jpg|png|pdf|doc|docx)$/i;
  const allowedMimetypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
    'application/msword', // .doc
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' // .docx
  ];
  
  const extname = allowedExtensions.test(file.originalname.toLowerCase());
  const mimetype = allowedMimetypes.includes(file.mimetype);

  if (extname && mimetype) {
    return cb(null, true);
  } else {
    cb(new Error('Only .png, .jpg, .jpeg, .pdf, .doc and .docx files are allowed!'));
  }
};

export const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: fileFilter
});

// Upload document with encryption
export const uploadDocument = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const userId = req.user.id;
    const { document_type, description, encrypt } = req.body;
    const shouldEncrypt = encrypt === 'true' || encrypt === true;

    // Read the uploaded file
    const fileBuffer = await fs.readFile(req.file.path);
    let encryptedFilePath = req.file.path;
    let encryptionMetadata = null;
    let fileHash = null;

    // Encrypt the file if requested
    if (shouldEncrypt) {
      try {
        console.log('\n' + '═'.repeat(80));
        console.log('                  DOCUMENT ENCRYPTION PROCESS');
        console.log('═'.repeat(80));
        console.log(`Document: ${req.file.originalname}`);
        console.log(`User ID: ${userId}`);
        console.log(`Original Size: ${fileBuffer.length} bytes`);
        console.log('═'.repeat(80));

        // Get active public key for encryption
        const { keyId, publicKey } = await getActivePublicKey();
        console.log(`\n[KEY] Using encryption key: ${keyId}`);

        // Encrypt the file
        console.log('[ENCRYPT] Encrypting file with AES-256-GCM...');
        const encrypted = encryptFile(fileBuffer, publicKey);
        console.log('[SUCCESS] File encrypted successfully');

        // Generate hash of original file for integrity verification
        fileHash = generateHash(fileBuffer);
        console.log(`[HASH] Original file hash: ${fileHash.substring(0, 16)}...`);

        // Write encrypted data to a new file
        encryptedFilePath = req.file.path + '.enc';
        await fs.writeFile(encryptedFilePath, encrypted.encryptedData);
        console.log(`[SAVE] Encrypted file saved: ${path.basename(encryptedFilePath)}`);

        // Delete the original unencrypted file
        await fs.unlink(req.file.path);
        console.log('[DELETE] Original unencrypted file removed');

        encryptionMetadata = {
          encryptionKeyId: keyId,
          encryptedKey: encrypted.encryptedKey.toString('base64'),
          iv: encrypted.iv.toString('base64'),
          authTag: encrypted.authTag.toString('base64'),
          algorithm: encrypted.algorithm
        };

        console.log('═'.repeat(80));
        console.log('[SUCCESS] ENCRYPTION COMPLETED SUCCESSFULLY');
        console.log('═'.repeat(80) + '\n');
      } catch (encryptError) {
        console.error('[ERROR] Error encrypting file:', encryptError);
        // If encryption fails, keep the original file
        encryptedFilePath = req.file.path;
        encryptionMetadata = null;
        console.log('[WARNING]  Falling back to unencrypted storage');
      }
    }

    // Save document info to database
    const [document] = await knex('documents')
      .insert({
        user_id: userId,
        document_type: document_type || 'Other',
        file_name: req.file.originalname,
        file_path: encryptedFilePath,
        file_size: shouldEncrypt ? fsSync.statSync(encryptedFilePath).size : req.file.size,
        description: description || null,
        is_encrypted: shouldEncrypt && encryptionMetadata !== null,
        encryption_key_id: encryptionMetadata?.encryptionKeyId || null,
        encrypted_key: encryptionMetadata?.encryptedKey || null,
        encryption_iv: encryptionMetadata?.iv || null,
        encryption_auth_tag: encryptionMetadata?.authTag || null,
        encryption_algorithm: encryptionMetadata?.algorithm || null,
        file_hash: fileHash || null
      })
      .returning('*');

    res.status(201).json(createPostResponse({
      success: true,
      message: shouldEncrypt && encryptionMetadata ? 'Document uploaded and encrypted successfully' : 'Document uploaded successfully',
      data: {
        ...document,
        encrypted: shouldEncrypt && encryptionMetadata !== null,
        encryptionInfo: shouldEncrypt && encryptionMetadata ? {
          algorithm: encryptionMetadata.algorithm,
          keyId: encryptionMetadata.encryptionKeyId
        } : null
      },
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error uploading document:', error);
    // Delete uploaded file if database insert fails
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
        // Also try to delete encrypted file if it exists
        const encPath = req.file.path + '.enc';
        if (fsSync.existsSync(encPath)) {
          await fs.unlink(encPath);
        }
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error uploading document',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};

// Get user's documents
export const getUserDocuments = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await knex('documents')
      .select('id', 'document_type', 'file_name', 'file_size', 'description', 'status', 'verified_at', 'uploaded_at')
      .where('user_id', userId)
      .orderBy('uploaded_at', 'desc');

    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching documents:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching documents',
      error: error.message
    });
  }
};

// Delete document
export const deleteDocument = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    // Get document info
    const document = await knex('documents')
      .where({ id, user_id: userId })
      .first();

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Delete file from filesystem
    try {
      await fs.access(document.file_path);
      await fs.unlink(document.file_path);
    } catch (err) {
      console.error('Error deleting file from filesystem:', err);
      // Continue with database deletion even if file deletion fails
    }

    // Delete from database
    await knex('documents').where('id', id).del();

    res.json({
      success: true,
      message: 'Document deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting document:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting document',
      error: error.message
    });
  }
};

// Download document with decryption
export const downloadDocument = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    // Get document info
    const document = await knex('documents')
      .where({ id, user_id: userId })
      .first();

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Check if file exists
    try {
      await fs.access(document.file_path);
    } catch (err) {
      return res.status(404).json({
        success: false,
        message: 'File not found on server'
      });
    }

    // If document is encrypted, decrypt it before sending
    if (document.is_encrypted) {
      try {
        console.log('\n' + '═'.repeat(80));
        console.log('                  DOCUMENT DECRYPTION PROCESS');
        console.log('═'.repeat(80));
        console.log(`Document: ${document.file_name}`);
        console.log(`User ID: ${userId}`);
        console.log('═'.repeat(80));

        // Read encrypted file
        const encryptedData = await fs.readFile(document.file_path);
        console.log(`[LOAD] Encrypted file loaded: ${encryptedData.length} bytes`);

        // Get private key for decryption
        const privateKey = await getPrivateKey(document.encryption_key_id);
        console.log(`[KEY] Retrieved decryption key: ${document.encryption_key_id}`);

        // Prepare encryption package for decryption
        const encryptedPackage = {
          encryptedData: encryptedData,
          encryptedKey: Buffer.from(document.encrypted_key, 'base64'),
          iv: Buffer.from(document.encryption_iv, 'base64'),
          authTag: Buffer.from(document.encryption_auth_tag, 'base64')
        };

        // Decrypt the file
        console.log('[DECRYPT] Decrypting file with AES-256-GCM...');
        const decryptedData = decryptFile(encryptedPackage, privateKey);
        console.log('[SUCCESS] File decrypted successfully');

        // Verify integrity if hash is available
        if (document.file_hash) {
          const computedHash = generateHash(decryptedData);
          if (computedHash === document.file_hash) {
            console.log('[SUCCESS] File integrity verified');
          } else {
            console.log('[WARNING]  File integrity check failed');
          }
        }

        console.log('═'.repeat(80));
        console.log('[SUCCESS] DECRYPTION COMPLETED SUCCESSFULLY');
        console.log('═'.repeat(80) + '\n');

        // Send decrypted file
        res.setHeader('Content-Type', 'application/octet-stream');
        res.setHeader('Content-Disposition', `attachment; filename="${document.file_name}"`);
        res.send(decryptedData);
      } catch (decryptError) {
        console.error('[ERROR] Error decrypting file:', decryptError);
        return res.status(500).json({
          success: false,
          message: 'Error decrypting document',
          error: decryptError.message
        });
      }
    } else {
      // Send unencrypted file
      res.download(document.file_path, document.file_name);
    }
  } catch (error) {
    console.error('Error downloading document:', error);
    res.status(500).json({
      success: false,
      message: 'Error downloading document',
      error: error.message
    });
  }
};

// Admin: Get all drivers with pending document verification
export const getDriversWithPendingDocuments = async (req, res) => {
  try {
    const result = await knex('users as u')
      .select(
        'u.id', 'u.name', 'u.email', 'u.phone', 'u.created_at',
        'd.vehicle_type', 'd.vehicle_model', 'd.verification_status',
        knex.raw('COUNT(doc.id) as pending_documents')
      )
      .leftJoin('drivers as d', 'u.id', 'd.user_id')
      .leftJoin('documents as doc', function() {
        this.on('u.id', '=', 'doc.user_id')
          .andOn('doc.status', '=', knex.raw("?", ['Pending']));
      })
      .where('u.role', 'Driver')
      .groupBy('u.id', 'u.name', 'u.email', 'u.phone', 'u.created_at', 'd.vehicle_type', 'd.vehicle_model', 'd.verification_status')
      .orderBy('u.created_at', 'desc');

    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching drivers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching drivers',
      error: error.message
    });
  }
};

// Admin: Get documents for a specific user
export const getUserDocumentsAdmin = async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await knex('documents as d')
      .select('d.*', 'u.name as user_name', 'u.email as user_email')
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('d.user_id', userId)
      .orderBy('d.uploaded_at', 'desc');

    res.json({
      success: true,
      data: result,
      count: result.length
    });
  } catch (error) {
    console.error('Error fetching user documents:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user documents',
      error: error.message
    });
  }
};

// Admin: View document details
export const viewDocument = async (req, res) => {
  try {
    const { id } = req.params;

    const document = await knex('documents as d')
      .select('d.*', 'u.name as user_name', 'u.email as user_email')
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('d.id', id)
      .first();

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Check if file exists
    try {
      await fs.access(document.file_path);
    } catch (err) {
      return res.status(404).json({
        success: false,
        message: 'File not found on server'
      });
    }

    res.json({
      success: true,
      data: document
    });
  } catch (error) {
    console.error('Error viewing document:', error);
    res.status(500).json({
      success: false,
      message: 'Error viewing document',
      error: error.message
    });
  }
};

// Admin: View document with Base64 encoding and security analysis
export const viewDocumentEncoded = async (req, res) => {
  try {
    const { id } = req.params;

    // Get document info from database
    const document = await knex('documents as d')
      .select('d.*', 'u.name as user_name', 'u.email as user_email')
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('d.id', id)
      .first();

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Check if file exists
    try {
      await fs.access(document.file_path);
    } catch (err) {
      return res.status(404).json({
        success: false,
        message: 'File not found on server'
      });
    }

    // Read file and encode to Base64
    const fileBuffer = await fs.readFile(document.file_path);
    
    // ============================================================================
    // TERMINAL OUTPUT: ENCODING & DECODING DEMONSTRATION
    // ============================================================================
    console.log('\n' + '═'.repeat(80));
    console.log('                  ENCODING & DECODING DEMONSTRATION');
    console.log('═'.repeat(80));
    console.log(`Document ID: ${id}`);
    console.log(`File: ${document.file_name}`);
    console.log(`User: ${document.user_name} (${document.user_email})`);
    console.log(`File Type: ${document.document_type}`);
    console.log(`Original Size: ${fileBuffer.length} bytes`);
    console.log('═'.repeat(80));
    
    // Show sample of original data
    const sampleData = fileBuffer.toString('utf8', 0, Math.min(100, fileBuffer.length));
    console.log('\n[DATA] STEP 1: ORIGINAL DATA (Sample)');
    console.log('─'.repeat(80));
    console.log(`Binary Data (first 100 bytes as text): ${sampleData.substring(0, 100).replace(/[^\x20-\x7E]/g, '.')}`);
    console.log(`Total bytes: ${fileBuffer.length}`);
    
    // Perform encoding
    console.log('\n[ENCRYPT] STEP 2: ENCODING TO BASE64');
    console.log('─'.repeat(80));
    console.log('Encoding process: Binary → Base64 ASCII');
    console.log('Algorithm: Base64 encoding (RFC 4648)');
    const encodedFile = encodeFileToBase64(fileBuffer);
    console.log(`✓ Encoding complete!`);
    console.log(`Encoded size: ${encodedFile.length} characters`);
    console.log(`Overhead: ${(((encodedFile.length - fileBuffer.length) / fileBuffer.length) * 100).toFixed(2)}%`);
    
    // Show sample of encoded data
    console.log('\n[INFO] STEP 3: ENCODED DATA (Sample)');
    console.log('─'.repeat(80));
    console.log(`Base64 string (first 200 chars):`);
    console.log(encodedFile.substring(0, 200));
    if (encodedFile.length > 200) {
      console.log(`... (${encodedFile.length - 200} more characters)`);
    }
    
    // Demonstrate decoding
    console.log('\n[DECRYPT] STEP 4: DECODING FROM BASE64');
    console.log('─'.repeat(80));
    console.log('Decoding process: Base64 ASCII → Binary');
    const decodedBuffer = Buffer.from(encodedFile, 'base64');
    console.log(`✓ Decoding complete!`);
    console.log(`Decoded size: ${decodedBuffer.length} bytes`);
    
    // Verify integrity
    const isIdentical = Buffer.compare(fileBuffer, decodedBuffer) === 0;
    console.log('\n[SUCCESS] STEP 5: VERIFICATION');
    console.log('─'.repeat(80));
    console.log(`Original size:  ${fileBuffer.length} bytes`);
    console.log(`Decoded size:   ${decodedBuffer.length} bytes`);
    console.log(`Match:          ${isIdentical ? '✓ IDENTICAL' : '✗ MISMATCH'}`);
    console.log(`Integrity:      ${isIdentical ? '✓ PRESERVED' : '✗ CORRUPTED'}`);
    
    // Get encoding information
    const encodingInfo = getEncodingInfo(
      fileBuffer.toString('binary'),
      encodedFile
    );
    
    // Show encoding statistics
    console.log('\n📊 ENCODING STATISTICS');
    console.log('─'.repeat(80));
    console.log(`Technique:      ${encodingInfo.technique}`);
    console.log(`Original Size:  ${encodingInfo.originalSize} bytes`);
    console.log(`Encoded Size:   ${encodingInfo.encodedSize} bytes`);
    console.log(`Overhead:       ${encodingInfo.overhead}`);
    console.log(`Description:    ${encodingInfo.description}`);
    
    // Get security analysis
    const securityAnalysis = analyzeBase64Security();
    const securitySummary = getSecuritySummary();
    
    // Log security report to terminal
    console.log('\n' + '═'.repeat(80));
    console.log('                     SECURITY ANALYSIS');
    console.log('═'.repeat(80));
    console.log(generateSecurityReport());

    res.json({
      success: true,
      data: {
        document: {
          id: document.id,
          document_type: document.document_type,
          file_name: document.file_name,
          file_size: document.file_size,
          status: document.status,
          uploaded_at: document.uploaded_at,
          user_name: document.user_name,
          user_email: document.user_email
        },
        encodedData: encodedFile,
        encoding: encodingInfo,
        security: {
          analysis: securityAnalysis,
          summary: securitySummary
        }
      }
    });
  } catch (error) {
    console.error('Error viewing encoded document:', error);
    res.status(500).json({
      success: false,
      message: 'Error viewing encoded document',
      error: error.message
    });
  }
};

// Admin: Download document
export const downloadDocumentAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    // Get document info
    const document = await knex('documents as d')
      .select('d.*', 'u.name as user_name')
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('d.id', id)
      .first();

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Check if file exists
    try {
      await fs.access(document.file_path);
    } catch (err) {
      return res.status(404).json({
        success: false,
        message: 'File not found on server'
      });
    }

    // Send file
    res.download(document.file_path, document.file_name);
  } catch (error) {
    console.error('Error downloading document:', error);
    res.status(500).json({
      success: false,
      message: 'Error downloading document',
      error: error.message
    });
  }
};

// Admin: Approve document
export const approveDocument = async (req, res) => {
  try {
    const { id } = req.params;
    const adminId = req.user.id;

    // Update document status
    const [document] = await knex('documents')
      .where('id', id)
      .update({
        status: 'Approved',
        verified_at: knex.fn.now(),
        verified_by: adminId
      })
      .returning('*');

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    // Check if all documents for this driver are approved
    const userDocs = await knex('documents')
      .where('user_id', document.user_id)
      .select(
        knex.raw('COUNT(*) as total'),
        knex.raw("SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) as approved")
      )
      .first();

    const { total, approved } = userDocs;

    // If all documents are approved, update driver verification status
    if (parseInt(total) > 0 && parseInt(total) === parseInt(approved)) {
      await knex('drivers')
        .where('user_id', document.user_id)
        .update({ verification_status: 'Verified' });
    }

    res.json({
      success: true,
      message: 'Document approved successfully',
      data: document
    });
  } catch (error) {
    console.error('Error approving document:', error);
    res.status(500).json({
      success: false,
      message: 'Error approving document',
      error: error.message
    });
  }
};

// Admin: Reject document
export const rejectDocument = async (req, res) => {
  try {
    const { id } = req.params;
    const adminId = req.user.id;
    const { reason } = req.body;

    // Update document status
    const [document] = await knex('documents')
      .where('id', id)
      .update({
        status: 'Rejected',
        verified_at: knex.fn.now(),
        verified_by: adminId,
        description: reason || 'Rejected'
      })
      .returning('*');

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found'
      });
    }

    res.json({
      success: true,
      message: 'Document rejected',
      data: document
    });
  } catch (error) {
    console.error('Error rejecting document:', error);
    res.status(500).json({
      success: false,
      message: 'Error rejecting document',
      error: error.message
    });
  }
};

// Admin: Get security analysis for encoding technique
export const getSecurityAnalysis = async (req, res) => {
  try {
    // Get security analysis
    const securityAnalysis = analyzeBase64Security();
    const securitySummary = getSecuritySummary();
    
    // Log security report to terminal
    console.log(generateSecurityReport());
    
    res.json({
      success: true,
      data: {
        analysis: securityAnalysis,
        summary: securitySummary,
        message: 'Security analysis logged to terminal'
      }
    });
  } catch (error) {
    console.error('Error generating security analysis:', error);
    res.status(500).json({
      success: false,
      message: 'Error generating security analysis',
      error: error.message
    });
  }
};

// Admin: Get all documents with encoding info
export const getAllDocumentsWithEncoding = async (req, res) => {
  try {
    const result = await knex('documents as d')
      .select(
        'd.id', 'd.document_type', 'd.file_name', 'd.file_size', 'd.status',
        'd.uploaded_at', 'u.name as user_name', 'u.email as user_email',
        'u.role as user_role'
      )
      .innerJoin('users as u', 'd.user_id', 'u.id')
      .where('u.role', 'Driver')
      .orderBy('d.uploaded_at', 'desc');
    
    // Log to terminal
    console.log('\n' + '='.repeat(80));
    console.log('DRIVER DOCUMENTS DASHBOARD - ENCODING ANALYSIS');
    console.log('='.repeat(80));
    console.log(`Total Documents: ${result.length}`);
    console.log(`Pending: ${result.filter(d => d.status === 'Pending').length}`);
    console.log(`Approved: ${result.filter(d => d.status === 'Approved').length}`);
    console.log(`Rejected: ${result.filter(d => d.status === 'Rejected').length}`);
    console.log('='.repeat(80));
    
    result.forEach((doc, index) => {
      console.log(`\n${index + 1}. ${doc.file_name}`);
      console.log(`   Driver: ${doc.user_name} (${doc.user_email})`);
      console.log(`   Type: ${doc.document_type} | Status: ${doc.status}`);
      console.log(`   Size: ${(doc.file_size / 1024).toFixed(2)} KB`);
      console.log(`   Uploaded: ${new Date(doc.uploaded_at).toLocaleString()}`);
    });
    
    console.log('\n' + '='.repeat(80));
    console.log('BASE64 ENCODING TECHNIQUE - SECURITY INFORMATION');
    console.log('='.repeat(80));
    console.log(generateSecurityReport());

    res.json({
      success: true,
      data: result,
      count: result.length,
      message: 'Documents listed with security analysis logged to terminal'
    });
  } catch (error) {
    console.error('Error fetching documents:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching documents',
      error: error.message
    });
  }
};

// Get public key for encryption (key exchange endpoint)
export const getPublicKeyForEncryption = async (req, res) => {
  try {
    console.log('\n' + '═'.repeat(80));
    console.log('               KEY EXCHANGE - PUBLIC KEY REQUEST');
    console.log('═'.repeat(80));
    
    const { keyId, publicKey, keyName } = await getActivePublicKey();
    
    console.log(`[KEY] Key ID: ${keyId}`);
    console.log(`[INFO] Key Name: ${keyName}`);
    console.log(`[ENCRYPT] Public Key Length: ${publicKey.length} characters`);
    console.log('═'.repeat(80));
    console.log('[SUCCESS] Public key distributed for secure key exchange');
    console.log('═'.repeat(80) + '\n');
    
    res.json({
      success: true,
      data: {
        keyId: keyId,
        publicKey: publicKey,
        algorithm: 'RSA-2048',
        usage: 'Encrypt AES keys for secure file encryption',
        instructions: 'Use this public key to encrypt your AES session keys'
      }
    });
  } catch (error) {
    console.error('Error retrieving public key:', error);
    res.status(500).json({
      success: false,
      message: 'Error retrieving public key',
      error: error.message
    });
  }
};

// Get encryption information and security analysis
export const getEncryptionInformation = async (req, res) => {
  try {
    const encryptionInfo = getEncryptionInfo();
    const securityAnalysis = analyzeEncryptionSecurity();
    const securitySummary = getEncryptionSummary();
    
    // Log comprehensive security report to terminal
    console.log(generateEncryptionReport());
    
    res.json({
      success: true,
      data: {
        encryption: encryptionInfo,
        security: {
          analysis: securityAnalysis,
          summary: securitySummary
        }
      }
    });
  } catch (error) {
    console.error('Error getting encryption info:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting encryption info',
      error: error.message
    });
  }
};

// Demonstrate encryption/decryption process
export const demonstrateEncryption = async (req, res) => {
  try {
    const { text } = req.body;
    const sampleData = text || 'This is a sample document for encryption demonstration.';
    
    console.log('\n' + '═'.repeat(80));
    console.log('            ENCRYPTION & DECRYPTION DEMONSTRATION');
    console.log('═'.repeat(80));
    console.log(`Original Data: "${sampleData}"`);
    console.log(`Data Length: ${sampleData.length} characters`);
    console.log('═'.repeat(80));
    
    // Get public key
    const { keyId, publicKey } = await getActivePublicKey();
    console.log(`\n[KEY] STEP 1: KEY GENERATION`);
    console.log(`   Using RSA Key ID: ${keyId}`);
    
    // Encrypt
    console.log(`\n[ENCRYPT] STEP 2: ENCRYPTION`);
    const dataBuffer = Buffer.from(sampleData, 'utf-8');
    const encrypted = encryptFile(dataBuffer, publicKey);
    console.log(`   Algorithm: ${encrypted.algorithm}`);
    console.log(`   Encrypted Size: ${encrypted.encryptedData.length} bytes`);
    console.log(`   IV: ${encrypted.iv.toString('hex').substring(0, 32)}...`);
    console.log(`   Auth Tag: ${encrypted.authTag.toString('hex')}`);
    
    // Get private key and decrypt
    console.log(`\n[DECRYPT] STEP 3: DECRYPTION`);
    const privateKey = await getPrivateKey(keyId);
    const encryptedPackage = {
      encryptedData: encrypted.encryptedData,
      encryptedKey: encrypted.encryptedKey,
      iv: encrypted.iv,
      authTag: encrypted.authTag
    };
    const decrypted = decryptFile(encryptedPackage, privateKey);
    const decryptedText = decrypted.toString('utf-8');
    console.log(`   Decrypted Data: "${decryptedText}"`);
    
    // Verify
    console.log(`\n[SUCCESS] STEP 4: VERIFICATION`);
    const isMatch = sampleData === decryptedText;
    console.log(`   Original matches decrypted: ${isMatch ? 'YES [SUCCESS]' : 'NO [ERROR]'}`);
    
    console.log('\n' + '═'.repeat(80));
    console.log('[SUCCESS] DEMONSTRATION COMPLETED SUCCESSFULLY');
    console.log('═'.repeat(80) + '\n');
    
    res.json(createPostResponse({
      success: true,
      message: 'Encryption demonstration completed successfully',
      data: {
        original: sampleData,
        encrypted: {
          data: encrypted.encryptedData.toString('base64').substring(0, 100) + '...',
          keyId: keyId,
          algorithm: encrypted.algorithm,
          size: encrypted.encryptedData.length
        },
        decrypted: decryptedText,
        verified: isMatch
      },
      requestBody: req.body
    }));
  } catch (error) {
    console.error('Error in encryption demonstration:', error);
    res.status(500).json(createPostResponse({
      success: false,
      message: 'Error in encryption demonstration',
      data: {
        error: error.message
      },
      requestBody: req.body
    }));
  }
};
