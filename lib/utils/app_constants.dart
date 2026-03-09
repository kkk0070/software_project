/// Constants used throughout the EcoRide app
class AppConstants {
  // API endpoints (for future integration)
  static const String baseUrl = 'https://api.ecoride.com';
  
  // App Info
  static const String appName = 'EcoRide';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Sustainable Mobility for Everyone';
  
  // Carbon emission calculation (kg CO₂ per km)
  static const double carbonPerKmSolo = 0.19; // Average car
  static const double carbonPerKmPool = 0.095; // Pooled (50% reduction)
  static const double carbonSavingsPerPooledRide = 0.095; // Savings per km
  
  // Eco score thresholds
  static const int ecoScoreBronze = 100;
  static const int ecoScoreSilver = 300;
  static const int ecoScoreGold = 600;
  static const int ecoScorePlatinum = 1000;
  
  // Achievement IDs
  static const String achievementFirstRide = 'first_ride';
  static const String achievementFirstPool = 'first_pool';
  static const String achievementWeekStreak = 'week_streak';
  static const String achievementMonthStreak = 'month_streak';
  static const String achievement10Rides = '10_rides';
  static const String achievement50Rides = '50_rides';
  static const String achievement100Rides = '100_rides';
  static const String achievement50kgCO2 = '50kg_co2';
  static const String achievement100kgCO2 = '100kg_co2';
  
  // Settings keys
  static const String keyPreferPooling = 'prefer_pooling';
  static const String keyEcoMode = 'eco_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  
  // Ride constraints
  static const int minPassengers = 1;
  static const int maxPassengers = 4;
  static const double minFare = 50.0;
  static const double baseRatePerKm = 15.0;
  static const double poolDiscountPercent = 30.0;
  
  // Animation durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
}

/// Helper functions for calculations and formatting
class AppHelpers {
  /// Calculate carbon saved for a pooled ride
  static double calculateCarbonSaved(double distanceKm, bool isPooled) {
    if (!isPooled) return 0.0;
    return distanceKm * AppConstants.carbonSavingsPerPooledRide;
  }
  
  /// Calculate ride fare
  static double calculateFare(double distanceKm, bool isPooled, int passengers) {
    double baseFare = distanceKm * AppConstants.baseRatePerKm;
    
    if (isPooled) {
      baseFare = baseFare * (1 - AppConstants.poolDiscountPercent / 100);
    }
    
    // Minimum fare
    if (baseFare < AppConstants.minFare) {
      baseFare = AppConstants.minFare;
    }
    
    return baseFare;
  }
  
  /// Get eco score level name
  static String getEcoScoreLevel(int score) {
    if (score >= AppConstants.ecoScorePlatinum) {
      return 'Platinum';
    } else if (score >= AppConstants.ecoScoreGold) {
      return 'Gold';
    } else if (score >= AppConstants.ecoScoreSilver) {
      return 'Silver';
    } else if (score >= AppConstants.ecoScoreBronze) {
      return 'Bronze';
    } else {
      return 'Beginner';
    }
  }
  
  /// Format distance with unit
  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
  
  /// Format currency
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  
  /// Format carbon value
  static String formatCarbon(double kg) {
    return '${kg.toStringAsFixed(1)} kg CO₂';
  }
  
  /// Calculate trees equivalent (1 tree absorbs ~21 kg CO₂ per year)
  static int calculateTreesEquivalent(double carbonKg) {
    return (carbonKg / 21).round();
  }
}
