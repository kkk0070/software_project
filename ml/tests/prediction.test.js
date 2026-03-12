import { describe, it, expect, beforeEach } from 'vitest';
import predictionService from '../services/predictionService.js';
import demandService from '../services/demandService.js';
import { generateMockDemandData } from '../utils/mockDataGenerator.js';

describe('PredictionService', () => {
    const zone = 'TestZone';

    beforeEach(() => {
        demandService.clearData();
        predictionService.models = {};
    });

    it('should train a model and predict demand correctly', () => {
        // Create simple historical data: 10 demand at 9 AM on Mon, 20 demand at 9 AM on Mon
        const history = [
            { zone, timestamp: '2023-10-02T09:00:00Z', demand: 10 }, // Mon
            { zone, timestamp: '2023-10-09T09:00:00Z', demand: 20 }  // Mon
        ];

        predictionService.trainModel(zone, history);
        
        // Predict for another Monday at 9 AM
        const prediction = predictionService.predictDemand(zone, '2023-10-16T09:00:00Z');
        expect(prediction).toBe(15); // Average of 10 and 20
    });

    it('should evaluate accuracy using MAE', () => {
        const history = [
            { zone, timestamp: '2023-10-02T09:00:00Z', demand: 10 }
        ];
        predictionService.trainModel(zone, history);

        const testData = [
            { timestamp: '2023-10-09T09:00:00Z', demand: 15 } // Actual is 15, prediction is 10
        ];

        const evaluation = predictionService.evaluateAccuracy(zone, testData);
        expect(evaluation.mae).toBe(5);
        expect(evaluation.sampleSize).toBe(1);
    });

    it('should return 0 for unknown temporal profiles', () => {
        predictionService.trainModel(zone, []);
        const prediction = predictionService.predictDemand(zone, new Date());
        expect(prediction).toBe(0);
    });

    it('should throw error if predicting for untrained zone', () => {
        expect(() => predictionService.predictDemand('EmptyZone', new Date())).toThrow('No model trained');
    });
});
