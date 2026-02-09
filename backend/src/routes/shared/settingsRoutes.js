import express from 'express';
import {
  getAllSettings,
  getSettingByKey,
  createSetting,
  updateSetting,
  deleteSetting,
  bulkUpdateSettings
} from '../../controllers/shared/settingsController.js';

const router = express.Router();

// Settings routes
router.get('/', getAllSettings);
router.get('/:key', getSettingByKey);
router.post('/', createSetting);
router.put('/:key', updateSetting);
router.delete('/:key', deleteSetting);
router.post('/bulk-update', bulkUpdateSettings);

export default router;
