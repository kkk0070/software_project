import express from 'express';
import {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  getUserStats
} from '../../controllers/driver/userController.js';

const router = express.Router();

router.get('/', getAllUsers);
router.get('/stats', getUserStats);
router.get('/:id', getUserById);
router.post('/', createUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);

export default router;
