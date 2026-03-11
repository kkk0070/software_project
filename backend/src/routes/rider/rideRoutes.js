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
  completeRide,
  rateRide,
  arriveAtPickup,
  verifyOtp
} from '../../controllers/rider/rideController.js';

const router = express.Router();

router.get('/', getAllRides);
router.get('/stats', getRideStats);
router.get('/:id', getRideById);
router.post('/', createRide);
router.put('/:id', updateRide);
router.put('/:id/accept', acceptRide);
router.put('/:id/reject', rejectRide);
router.post('/:id/complete', completeRide);
router.post('/:id/rate', rateRide);
router.post('/:id/arrive', arriveAtPickup);
router.post('/:id/verify-otp', verifyOtp);
router.delete('/:id', deleteRide);

export default router;
