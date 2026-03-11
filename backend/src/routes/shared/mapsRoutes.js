import express from 'express';
import {
    saveDownloadedMap,
    getDownloadedMaps,
    deleteDownloadedMap
} from '../../controllers/shared/mapsController.js';

const router = express.Router();

router.post('/download', saveDownloadedMap);
router.get('/downloaded', getDownloadedMaps);
router.delete('/downloaded/:id', deleteDownloadedMap);

export default router;
