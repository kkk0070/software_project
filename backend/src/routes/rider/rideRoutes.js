import express from 'express';
import {
  getAllRides,
  getRideById,
  createRide,
  updateRide,
  deleteRide,
  getRideStats
} from '../../controllers/rider/rideController.js';

const router = express.Router();

router.get('/', getAllRides);
router.get('/stats', getRideStats);
router.get('/:id', getRideById);
router.post('/', createRide);
router.put('/:id', updateRide);
router.delete('/:id', deleteRide);

export default router;
