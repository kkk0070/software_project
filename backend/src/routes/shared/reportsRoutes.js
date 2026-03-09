import express from 'express';
import {
  getRecentReports,
  getScheduledReports,
  generateReport,
  getReportStats,
  updateScheduledReport,
  deleteReport
} from '../../controllers/shared/reportsController.js';

const router = express.Router();

// Reports routes
router.get('/recent', getRecentReports);
router.get('/scheduled', getScheduledReports);
router.get('/stats', getReportStats);
router.post('/generate', generateReport);
router.put('/scheduled/:id', updateScheduledReport);
router.delete('/:id', deleteReport);

export default router;
