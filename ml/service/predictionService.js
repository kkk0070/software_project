import { extractTemporalFeatures, prepareTrainingData } from '../utils/preprocessing.js';

/**
 * Service for predicting future ride demand.
 */
class PredictionService {
    constructor() {
        this.models = {}; // Model state per zone: { zone: { temporalProfiles: {}, lastTrend: 0 } }
    }

    /**
     * Trains a simple temporal model for a zone.
     * @param {string} zone 
     * @param {Array} historicalData - Array of { timestamp, demand }
     */
    trainModel(zone, historicalData) {
        const profiles = {}; // Stores sum and count per [dayOfWeek][hour]
        
        historicalData.forEach(record => {
            const features = extractTemporalFeatures(record.timestamp);
            const key = `${features.dayOfWeek}-${features.hour}`;
            
            if (!profiles[key]) {
                profiles[key] = { sum: 0, count: 0 };
            }
            profiles[key].sum += record.demand;
            profiles[key].count += 1;
        });

        // Compute averages for each time slot
        const trainedProfiles = {};
        for (const key in profiles) {
            trainedProfiles[key] = profiles[key].sum / profiles[key].count;
        }

        this.models[zone] = {
            temporalProfiles: trainedProfiles,
            lastUpdated: new Date().toISOString()
        };

        return this.models[zone];
    }

    /**
     * Predicts demand for a future timestamp in a specific zone.
     * @param {string} zone 
     * @param {string|Date} futureTimestamp 
     */
    predictDemand(zone, futureTimestamp) {
        const model = this.models[zone];
        if (!model) {
            throw new Error(`No model trained for zone: ${zone}`);
        }

        const features = extractTemporalFeatures(futureTimestamp);
        const key = `${features.dayOfWeek}-${features.hour}`;
        
        // Return historical average or default to 0 if no data for that slot
        return model.temporalProfiles[key] || 0;
    }

    /**
     * Evaluates model accuracy using Mean Absolute Error (MAE).
     * @param {string} zone 
     * @param {Array} testData - Array of { timestamp, actualDemand }
     */
    evaluateAccuracy(zone, testData) {
        let totalError = 0;
        let count = 0;

        testData.forEach(record => {
            try {
                const prediction = this.predictDemand(zone, record.timestamp);
                totalError += Math.abs(prediction - record.demand);
                count++;
            } catch (e) {
                // Skip if no prediction available
            }
        });

        const mae = count > 0 ? totalError / count : 0;
        return {
            zone,
            mae,
            sampleSize: count,
            evaluatedAt: new Date().toISOString()
        };
    }
}

const predictionService = new PredictionService();
export default predictionService;
export { PredictionService };
