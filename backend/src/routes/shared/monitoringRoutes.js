import express from 'express';
import {
  getLiveRideMonitoring,
  getSafetyMonitoring,
  getSystemMonitoring,
  getGPSLogs
} from '../../controllers/shared/monitoringController.js';

const router = express.Router();

// Monitoring routes
router.get('/live-rides', getLiveRideMonitoring);
router.get('/safety', getSafetyMonitoring);
router.get('/system', getSystemMonitoring);
router.get('/gps-logs', getGPSLogs);

export default router;
