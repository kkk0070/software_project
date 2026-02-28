import express from 'express';
import {
  getAllRides,
  getRideById,
  createRide,
  updateRide,
  deleteRide,
  getRideStats,
  acceptRide,
  rejectRide,
  rateRide
} from '../../controllers/rider/rideController.js';

const router = express.Router();

router.get('/', getAllRides);
router.get('/stats', getRideStats);
router.get('/:id', getRideById);
router.post('/', createRide);
router.put('/:id', updateRide);
router.put('/:id/accept', acceptRide);
router.put('/:id/reject', rejectRide);
router.post('/:id/rate', rateRide);
router.delete('/:id', deleteRide);

export default router;
