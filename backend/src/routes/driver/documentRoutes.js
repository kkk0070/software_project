import express from 'express';
import {
  uploadDocument,
  getUserDocuments,
  deleteDocument,
  downloadDocument,
  upload,
  getDriversWithPendingDocuments,
  getUserDocumentsAdmin,
  viewDocument,
  viewDocumentEncoded,
  downloadDocumentAdmin,
  approveDocument,
  rejectDocument,
  getSecurityAnalysis,
  getAllDocumentsWithEncoding,
  getPublicKeyForEncryption,
  getEncryptionInformation,
  demonstrateEncryption
} from '../../controllers/driver/documentController.js';
import { authenticateToken } from '../../middleware/authMiddleware.js';

const router = express.Router();

// All document routes require authentication
router.use(authenticateToken);

// Upload document
router.post('/upload', upload.single('document'), uploadDocument);

// Get user's documents
router.get('/', getUserDocuments);

// Download document
router.get('/:id/download', downloadDocument);

// Delete document
router.delete('/:id', deleteDocument);

// Admin routes for document verification
router.get('/admin/drivers', getDriversWithPendingDocuments);
router.get('/admin/user/:userId', getUserDocumentsAdmin);
router.get('/admin/view/:id', viewDocument);
router.get('/admin/view-encoded/:id', viewDocumentEncoded);
router.get('/admin/download/:id', downloadDocumentAdmin);
router.put('/admin/approve/:id', approveDocument);
router.put('/admin/reject/:id', rejectDocument);

// Admin routes for encoding and security analysis
router.get('/admin/security-analysis', getSecurityAnalysis);
router.get('/admin/all-documents-encoded', getAllDocumentsWithEncoding);

// Encryption endpoints
router.get('/encryption/public-key', getPublicKeyForEncryption);
router.get('/encryption/info', getEncryptionInformation);
router.post('/encryption/demo', demonstrateEncryption);

export default router;
