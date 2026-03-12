import { describe, it, expect, beforeEach, vi } from 'vitest';
import optimizationService from '../services/optimizationService.js';
import demandService from '../services/demandService.js';
import predictionService from '../services/predictionService.js';

describe('OptimizationService', () => {
    beforeEach(() => {
        vi.restoreAllMocks();
        demandService.clearData();
    });

    it('should detect hotspots', () => {
        vi.spyOn(demandService, 'getAggregatedDemand').mockReturnValue({ 'ZoneA': 100, 'ZoneB': 10 });
        vi.spyOn(predictionService, 'predictDemand').mockReturnValue(80);

        const hotspots = optimizationService.detectHotspots(['ZoneA', 'ZoneB']);
        
        expect(hotspots.length).toBeGreaterThan(0);
        expect(hotspots[0].zone).toBe('ZoneA');
        expect(hotspots[0].score).toBeGreaterThan(50);
    });

    it('should analyze imbalance correctly', () => {
        vi.spyOn(predictionService, 'predictDemand').mockReturnValue(10);
        
        // 2 drivers for (5 riders + 10 predicted) = 2/15 = 0.13 (underserved)
        const analysis = optimizationService.analyzeImbalance('ZoneA', 2, 5);
        expect(analysis.status).toBe('underserved');
        expect(analysis.supplyDemandRatio).toBeLessThan(0.5);

        // 20 drivers for (5 riders + 10 predicted) = 20/15 = 1.33 (balanced)
        const analysis2 = optimizationService.analyzeImbalance('ZoneA', 20, 5);
        expect(analysis2.status).toBe('balanced');
    });

    it('should generate relocation recommendations', () => {
        const imbalances = [
            { zone: 'OverZone', status: 'oversaturated', supplyDemandRatio: 3 },
            { zone: 'UnderZone', status: 'underserved', supplyDemandRatio: 0.1 }
        ];

        const recs = optimizationService.generateRecommendations(imbalances);
        expect(recs.length).toBe(1);
        expect(recs[0].from).toBe('OverZone');
        expect(recs[0].to).toBe('UnderZone');
    });
});
