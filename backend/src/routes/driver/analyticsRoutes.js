import express from 'express';
import {
  getOverviewStats,
  getDemandHeatmap,
  getRouteAnalytics,
  getSustainabilityMetrics,
  getAIOptimization
} from '../../controllers/driver/analyticsController.js';

const router = express.Router();

// Analytics routes
router.get('/overview', getOverviewStats);
router.get('/demand-heatmap', getDemandHeatmap);
router.get('/route-analytics', getRouteAnalytics);
router.get('/sustainability', getSustainabilityMetrics);
router.get('/ai-optimization', getAIOptimization);

export default router;
