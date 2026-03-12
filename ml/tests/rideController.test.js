import { describe, it, expect, beforeEach } from 'vitest';
import * as rideController from '../controllers/rider/rideController';

describe('rideController', () => {
    beforeEach(() => {
        rideController.rides.length = 0; // Clear mock db
    });

    describe('createRide', () => {
        it('should accept ride data in body', () => {
            const data = { pickup: 'Location A', destination: 'Location B', type: 'lux' };
            const ride = rideController.createRide(data);
            expect(ride.pickup).toBe('Location A');
            expect(ride.status).toBe('pending');
        });

        it('should validate required fields', () => {
            expect(() => rideController.createRide({})).toThrow('Required fields missing');
        });
    });

    describe('getRideById', () => {
        it('should accept ID parameter', () => {
            const ride = rideController.createRide({ pickup: 'A', destination: 'B' });
            const found = rideController.getRideById(ride.id);
            expect(found.id).toBe(ride.id);
        });
    });

    describe('updateRide', () => {
        it('should accept update data in body', () => {
            const ride = rideController.createRide({ pickup: 'A', destination: 'B' });
            const updated = rideController.updateRide(ride.id, { status: 'active' });
            expect(updated.status).toBe('active');
        });
    });

    describe('deleteRide', () => {
        it('should accept ID parameter for deletion', () => {
            const ride = rideController.createRide({ pickup: 'A', destination: 'B' });
            const deleted = rideController.deleteRide(ride.id);
            expect(deleted).toBe(true);
            expect(rideController.rides.length).toBe(0);
        });
    });

    describe('Ride statistics', () => {
        it('getRideStats should provide statistical data', () => {
            rideController.createRide({ pickup: 'A', destination: 'B', status: 'active' });
            const stats = rideController.getRideStats();
            expect(stats.totalRides).toBe(1);
        });
    });
});

//npm run test:table