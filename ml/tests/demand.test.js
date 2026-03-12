import { describe, it, expect, beforeEach } from 'vitest';
import demandService from '../services/demandService.js';
import { generateMockDemandData } from '../utils/mockDataGenerator.js';

describe('DemandService', () => {
    beforeEach(() => {
        demandService.clearData();
    });

    it('should store valid demand data', () => {
        const data = { zone: 'Downtown', timestamp: new Date().toISOString(), demand: 50 };
        const record = demandService.storeDemandData(data);
        
        expect(record.zone).toBe('Downtown');
        expect(record.demand).toBe(50);
        expect(demandService.demandData.length).toBe(1);
    });

    it('should throw error for invalid zone', () => {
        const data = { zone: '', timestamp: new Date().toISOString(), demand: 50 };
        expect(() => demandService.storeDemandData(data)).toThrow('Invalid zone');
    });

    it('should throw error for negative demand', () => {
        const data = { zone: 'Downtown', timestamp: new Date().toISOString(), demand: -5 };
        expect(() => demandService.storeDemandData(data)).toThrow('Invalid demand');
    });

    it('should filter historical demand by zone and time range', () => {
        const now = Date.now();
        demandService.storeDemandData({ zone: 'A', timestamp: new Date(now - 1000).toISOString(), demand: 10 });
        demandService.storeDemandData({ zone: 'A', timestamp: new Date(now - 5000).toISOString(), demand: 20 });
        demandService.storeDemandData({ zone: 'B', timestamp: new Date(now - 1000).toISOString(), demand: 30 });

        const history = demandService.getHistoricalDemand('A', now - 2000, now);
        expect(history.length).toBe(1);
        expect(history[0].demand).toBe(10);
    });

    it('should aggregate demand by zone', () => {
        demandService.storeDemandData({ zone: 'A', timestamp: new Date().toISOString(), demand: 10 });
        demandService.storeDemandData({ zone: 'A', timestamp: new Date().toISOString(), demand: 20 });
        demandService.storeDemandData({ zone: 'B', timestamp: new Date().toISOString(), demand: 5 });

        const aggregated = demandService.getAggregatedDemand();
        expect(aggregated['A']).toBe(30);
        expect(aggregated['B']).toBe(5);
    });
});

describe('MockDataGenerator', () => {
    it('should generate requested number of records', () => {
        demandService.clearData();
        const zones = ['Zone1', 'Zone2'];
        const days = 1;
        generateMockDemandData(zones, days);
        
        // 2 zones * 1 day * 24 hours = 48 records
        expect(demandService.demandData.length).toBe(48);
    });
});
