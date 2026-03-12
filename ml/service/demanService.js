/**
 * Service for managing ride demand data.
 */
class DemandService {
    constructor() {
        this.demandData = []; // Array of { zone, timestamp, demand, status }
    }

    /**
     * Stores a demand record after validation.
     * @param {Object} data - { zone, timestamp, demand }
     */
    storeDemandData(data) {
        this.validateDemandData(data);
        const record = {
            ...data,
            id: Date.now() + Math.random().toString(36).substr(2, 9),
            loggedAt: new Date().toISOString()
        };
        this.demandData.push(record);
        return record;
    }

    /**
     * Validates demand data.
     * @param {Object} data 
     * @throws {Error} if validation fails
     */
    validateDemandData(data) {
        if (!data.zone || typeof data.zone !== 'string') {
            throw new Error('Invalid zone: Zone is required and must be a string');
        }
        if (!data.timestamp || isNaN(new Date(data.timestamp).getTime())) {
            throw new Error('Invalid timestamp: A valid date/time is required');
        }
        if (typeof data.demand !== 'number' || data.demand < 0) {
            throw new Error('Invalid demand: Demand must be a non-negative number');
        }
    }

    /**
     * Gets historical demand for a specific zone and time range.
     * @param {string} zone 
     * @param {number} startTime - unix timestamp
     * @param {number} endTime - unix timestamp
     */
    getHistoricalDemand(zone, startTime, endTime) {
        return this.demandData.filter(d => {
            const time = new Date(d.timestamp).getTime();
            return d.zone === zone && time >= startTime && time <= endTime;
        });
    }

    /**
     * Aggregates demand by zone.
     */
    getAggregatedDemand() {
        const aggregation = {};
        this.demandData.forEach(d => {
            if (!aggregation[d.zone]) {
                aggregation[d.zone] = 0;
            }
            aggregation[d.zone] += d.demand;
        });
        return aggregation;
    }

    /**
     * Clears all demand data (useful for resets).
     */
    clearData() {
        this.demandData = [];
    }
}

const demandService = new DemandService();
export default demandService;
export { DemandService };
