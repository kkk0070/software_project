import express from 'express';
import {
    getAvailableCarpools,
    createCarpool,
    acceptCarpool,
    getCarpoolHistory,
    getCarpoolDetails,
    deleteCarpool
} from '../../controllers/shared/carpoolController.js';

const router = express.Router();

router.get('/available', getAvailableCarpools);
router.post('/create', createCarpool);
router.post('/accept', acceptCarpool);
router.get('/history', getCarpoolHistory);
router.get('/:id', getCarpoolDetails);
router.delete('/:id', deleteCarpool);

export default router;
