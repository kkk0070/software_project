import demandService from './demandService.js';
import predictionService from './predictionService.js';

/**
 * Service for optimizing resource (driver) allocation.
 */
class OptimizationService {
    constructor() {
        this.hotspots = []; // Array of rooms/zones with high demand
    }

    /**
     * Detects geographic demand hotspots based on current and predicted demand.
     * @param {Array} zones 
     */
    detectHotspots(zones) {
        const aggregated = demandService.getAggregatedDemand();
        const hotspots = zones.map(zone => {
            const currentDemand = aggregated[zone] || 0;
            const predictedDemand = predictionService.predictDemand(zone, new Date());
            
            // Score based on combination of current and future demand
            const score = (currentDemand * 0.4) + (predictedDemand * 0.6);
            
            return { zone, score, currentDemand, predictedDemand };
        })
        .filter(h => h.score > 50) // Threshold for hotspot
        .sort((a, b) => b.score - a.score);

        this.hotspots = hotspots;
        return hotspots;
    }

    /**
     * Analyzes imbalance between drivers and riders.
     * @param {string} zone 
     * @param {number} driverCount 
     * @param {number} riderCount 
     */
    analyzeImbalance(zone, driverCount, riderCount) {
        const predictedDemand = predictionService.predictDemand(zone, new Date());
        const totalExpectedRiders = riderCount + predictedDemand;
        
        const supplyDemandRatio = driverCount / (totalExpectedRiders || 1);
        
        return {
            zone,
            driverCount,
            riderCount,
            predictedDemand,
            supplyDemandRatio,
            status: supplyDemandRatio < 0.5 ? 'underserved' : (supplyDemandRatio > 2 ? 'oversaturated' : 'balanced')
        };
    }

    /**
     * Generates relocation recommendations for drivers in low-demand zones.
     * @param {Array} currentImbalances - Result of analyzeImbalance for all zones
     */
    generateRecommendations(currentImbalances) {
        const underserved = currentImbalances.filter(i => i.status === 'underserved');
        const oversaturated = currentImbalances.filter(i => i.status === 'oversaturated');
        
        const recommendations = [];
        
        oversaturated.forEach(over => {
            if (underserved.length > 0) {
                // Recommend moving to the most underserved zone
                const target = underserved[0];
                recommendations.push({
                    from: over.zone,
                    to: target.zone,
                    reason: `High demand expected in ${target.zone} with low driver supply.`,
                    priority: target.supplyDemandRatio < 0.2 ? 'high' : 'medium'
                });
            }
        });

        return recommendations;
    }
}

const optimizationService = new OptimizationService();
export default optimizationService;
export { OptimizationService };
