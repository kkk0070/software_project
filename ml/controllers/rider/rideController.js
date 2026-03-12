import { calculateDistance } from '../../utils/math.js';
import demandService from '../../services/demandService.js';

let rides = [];

const createRide = (rideData) => {
    if (!rideData.pickup || !rideData.destination) {
        throw new Error('Required fields missing');
    }
    const newRide = { ...rideData, id: Date.now(), status: 'pending' };
    rides.push(newRide);
    
    // Log demand record for the pickup zone
    try {
        demandService.storeDemandData({
            zone: rideData.pickup, // Assuming pickup is a zone name or coordinates string
            timestamp: new Date().toISOString(),
            demand: 1
        });
    } catch (e) {
        console.error('Failed to log demand data:', e.message);
    }

    return newRide;
};

const getRideById = (id) => {
    return rides.find(r => r.id === id);
};

const updateRide = (id, updateData) => {
    const ride = getRideById(id);
    if (!ride) return null;
    Object.assign(ride, updateData);
    return ride;
};

const deleteRide = (id) => {
    const index = rides.findIndex(r => r.id === id);
    if (index === -1) return false;
    rides.splice(index, 1);
    return true;
};

const getRideStats = () => {
    return {
        totalRides: rides.length,
        activeRides: rides.filter(r => r.status === 'active').length,
        completedRides: rides.filter(r => r.status === 'completed').length
    };
};

export { createRide, getRideById, updateRide, deleteRide, getRideStats, rides };
