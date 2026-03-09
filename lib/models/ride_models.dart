enum TransportType { standard, ev, hybrid, publicTransport }

class Ride {
  final String id;
  final String pickupLocation;
  final String dropLocation;
  final DateTime dateTime;
  final double distance;
  final double fare;
  final int passengers;
  final bool isPooled;
  final double carbonSaved;
  final RideStatus status;
  final String? driverName;
  final String? vehicleNumber;
  final TransportType transportType;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.dateTime,
    required this.distance,
    required this.fare,
    this.passengers = 1,
    this.isPooled = false,
    this.carbonSaved = 0.0,
    this.status = RideStatus.scheduled,
    this.driverName,
    this.vehicleNumber,
    this.transportType = TransportType.standard,
  });
}

enum RideStatus { scheduled, inProgress, completed, cancelled }

// New Hotel Model
class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviews;
  final double pricePerNight;
  final List<String> amenities;
  final bool isEcoFriendly;
  final String ecoRating; // Gold, Silver, Bronze
  final double carbonFootprint;
  final List<String> greenFeatures;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.pricePerNight,
    required this.amenities,
    this.isEcoFriendly = false,
    this.ecoRating = 'None',
    this.carbonFootprint = 0.0,
    this.greenFeatures = const [],
  });
}

// New Restaurant Model
class Restaurant {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String cuisine;
  final List<String> categories; // Vegan, Organic, Local, etc.
  final double avgPrice;
  final bool isEcoFriendly;
  final String openingHours;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.cuisine,
    required this.categories,
    required this.avgPrice,
    this.isEcoFriendly = false,
    this.openingHours = '9 AM - 10 PM',
  });
}

// New Travel Guide Model
class TravelGuide {
  final String id;
  final String name;
  final String photoUrl;
  final double rating;
  final int reviews;
  final List<String> languages;
  final List<String> specializations;
  final double pricePerDay;
  final int experienceYears;
  final bool isCertified;
  final String bio;

  TravelGuide({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.reviews,
    required this.languages,
    required this.specializations,
    required this.pricePerDay,
    required this.experienceYears,
    this.isCertified = false,
    this.bio = '',
  });
}

// New Experience/Activity Model
class Experience {
  final String id;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviews;
  final double price;
  final int durationHours;
  final String category; // Adventure, Cultural, Nature, etc.
  final bool isEcoFriendly;
  final double carbonImpact;

  Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.durationHours,
    required this.category,
    this.isEcoFriendly = false,
    this.carbonImpact = 0.0,
  });
}

// Enhanced Transportation Model
class Transportation {
  final String id;
  final String type; // Flight, Train, Bus, EV
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final double carbonEmission;
  final bool isEcoFriendly;
  final String provider;
  final int availableSeats;

  Transportation({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.carbonEmission,
    this.isEcoFriendly = false,
    required this.provider,
    this.availableSeats = 0,
  });
}

// Weather Model
class WeatherInfo {
  final String location;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final DateTime timestamp;

  WeatherInfo({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.timestamp,
  });
}

// Destination Suggestion Model
class DestinationSuggestion {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final String description;
  final List<String> bestMonths;
  final double avgBudget;
  final List<String> highlights;
  final double ecoScore;
  final String climate;

  DestinationSuggestion({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.description,
    required this.bestMonths,
    required this.avgBudget,
    required this.highlights,
    required this.ecoScore,
    required this.climate,
  });
}

// Trip Planner Model
class TripPlan {
  final String id;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<DayPlan> dayPlans;
  final double totalBudget;
  final double totalCarbonFootprint;

  TripPlan({
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.dayPlans,
    required this.totalBudget,
    required this.totalCarbonFootprint,
  });
}

class DayPlan {
  final int dayNumber;
  final String title;
  final List<Activity> activities;
  final double dailyBudget;

  DayPlan({
    required this.dayNumber,
    required this.title,
    required this.activities,
    required this.dailyBudget,
  });
}

class Activity {
  final String time;
  final String title;
  final String description;
  final String location;
  final double estimatedCost;

  Activity({
    required this.time,
    required this.title,
    required this.description,
    required this.location,
    required this.estimatedCost,
  });
}

class SustainabilityStats {
  final double totalCarbonSaved;
  final int totalRidesPooled;
  final double totalDistanceShared;
  final int treesEquivalent;
  final int currentStreak;
  final List<Achievement> achievements;

  SustainabilityStats({
    required this.totalCarbonSaved,
    required this.totalRidesPooled,
    required this.totalDistanceShared,
    required this.treesEquivalent,
    required this.currentStreak,
    required this.achievements,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    this.unlockedDate,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int ecoScore;
  final bool preferPooling;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.ecoScore = 0,
    this.preferPooling = true,
  });
}
