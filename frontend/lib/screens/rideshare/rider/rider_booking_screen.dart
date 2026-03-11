import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/user_service.dart';
import '../driver/driver_profile_detail_screen.dart';
import '../shared/location_picker_screen.dart';
import '../shared/payment_screen.dart';
import '../shared/user_profile_screen.dart';
import '../../../services/ml_service.dart';
import '../../../services/storage_service.dart';
import 'dart:async';
import 'dart:math' as math;

/// Rider Booking Screen
/// Features:
/// - Select pickup and destination locations
/// - Choose ride type (Economy, Comfort, Premium)
/// - View estimated pricing and ETA
/// - View available drivers
/// - Book a ride with a specific driver
class RiderBookingScreen extends StatefulWidget {
  const RiderBookingScreen({super.key});

  @override
  State<RiderBookingScreen> createState() => _RiderBookingScreenState();
}

// Ride type options
enum RideType { economy, comfort, premium }

class _RiderBookingScreenState extends State<RiderBookingScreen> {
  // Constants
  static const double _basePrice = 40.0; // Base price in Rupees
  static const String _placeholderDistance = '2.3 km away'; // Placeholder until GPS integration
  
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  List<Map<String, dynamic>> _availableDrivers = [];
  bool _loadingDrivers = false;
  bool _showDrivers = false;
  RideType _selectedRideType = RideType.economy;

  // New features state
  bool _isShared = false;
  int _riderCount = 1;
  double _calculatedDistanceKm = 0.0;
  double _tripDurationMin = 0.0;
  double _predictedFare = 0.0;
  Map<String, dynamic>? _fareBreakdown;
  bool _calculatingFare = false;

  // Autocomplete state
  List<String> _pickupSuggestions = [];
  List<String> _destSuggestions = [];
  Timer? _debounce;
  bool _isSearchingPickup = false;
  bool _isSearchingDest = false;

  // New: Store coordinates
  double? _pickupLat, _pickupLng;
  double? _destLat, _destLng;
  bool _calculatingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }



  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableDrivers() async {
    setState(() {
      _loadingDrivers = true;
    });

    try {
      // Get current user ID to filter out own profile
      final currentUserId = await StorageService.getUserId();
      
      final result = await UserService.getAvailableDrivers();
      if (result['success'] == true && result['data'] != null) {
        List<Map<String, dynamic>> drivers = List<Map<String, dynamic>>.from(result['data']);
        
        // Filter out current user if they are a driver
        if (currentUserId != null) {
          drivers = drivers.where((driver) => driver['id'] != currentUserId).toList();
        }
        
        setState(() {
          _availableDrivers = drivers;
          _loadingDrivers = false;
        });
      } else {
        setState(() {
          _loadingDrivers = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingDrivers = false;
      });
    }
  }

  void _searchForRides() {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination')),
      );
      return;
    }

    setState(() {
      _showDrivers = true;
      // Reset distances so it calculates fresh from route
      _calculatedDistanceKm = 0.0;
      _tripDurationMin = 0;
    });

    _updateRouteAndFare();
  }

  Future<void> _updateRouteAndFare() async {
    // If coords are missing, try to geocode the text first
    if (_pickupLat == null && _pickupController.text.isNotEmpty) {
      final coords = await MLService.geocodeAddress(_pickupController.text);
      if (coords != null) {
        _pickupLat = coords['lat'];
        _pickupLng = coords['lng'];
      }
    }
    if (_destLat == null && _destinationController.text.isNotEmpty) {
      final coords = await MLService.geocodeAddress(_destinationController.text);
      if (coords != null) {
        _destLat = coords['lat'];
        _destLng = coords['lng'];
      }
    }

    if (_pickupLat != null && _pickupLng != null && _destLat != null && _destLng != null) {
      setState(() => _calculatingRoute = true);
      
      final routeData = await MLService.getRoute(
        originLat: _pickupLat!,
        originLng: _pickupLng!,
        destLat: _destLat!,
        destLng: _destLng!,
      );

      if (mounted && routeData['success'] != false) {
        setState(() {
          _calculatedDistanceKm = (routeData['distance_km'] ?? _calculatedDistanceKm).toDouble();
          _tripDurationMin = (routeData['time_min'] ?? 0.0).toDouble();
          _calculatingRoute = false;
        });
      }
    }
    
    _calculateMLFare();
  }

  Future<void> _calculateMLFare() async {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) return;
    if (_pickupLat == null || _destLat == null) return;

    setState(() => _calculatingFare = true);

    // Get distance from OSM routing if available, otherwise straight line
    double dist = _calculatedDistanceKm;
    if (dist <= 0) {
      dist = _haversineDistance(_pickupLat!, _pickupLng!, _destLat!, _destLng!);
      // Buffer for roads
      dist *= 1.3;
    }

    // Rough CO2 based on distance and ride type
    double co2 = dist * (_selectedRideType == RideType.premium ? 0.3 : 0.15);

    // Get vehicle type for ML
    final vehicleType = _getRideTypeDetails(_selectedRideType)['vehicleType'];

    final result = await MLService.predictFare(
      distanceKm: dist,
      weather: 'Clear',
      traffic: 'Low',
      time: 'Off-Peak',
      co2Kg: co2,
      vehicleType: vehicleType,
    ).timeout(const Duration(seconds: 10), onTimeout: () => {'estimated_fare': 0.0, 'success': false});

    if (mounted) {
      if (result['success'] == false && (_predictedFare == 0 || dist != _prevDist)) {
        // Fallback to local calculation
        final localDetails = _calculateFareDetails();
        setState(() {
          _predictedFare = localDetails['farePerRider'];
          _calculatingFare = false;
        });
      } else {
        setState(() {
          _predictedFare = (result['estimated_fare'] ?? _predictedFare).toDouble();
          _fareBreakdown = result['breakdown'] ?? _fareBreakdown;
          _calculatingFare = false;
        });
      }
    }
    _prevDist = dist;
  }
  
  double _prevDist = 0.0;

  void _onPickupChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.length >= 3) {
        setState(() {
          _isSearchingPickup = true;
          _predictedFare = 0;
          _calculatedDistanceKm = 0;
        });
        final suggestions = await MLService.getAutocompleteSuggestions(value);
        if (mounted) {
          setState(() {
            _pickupSuggestions = suggestions;
            _isSearchingPickup = false;
          });
        }
      } else {
        setState(() {
          _pickupSuggestions = [];
          _pickupLat = null;
          _pickupLng = null;
        });
      }
    });
  }

  void _onDestChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.length >= 3) {
        setState(() {
          _isSearchingDest = true;
          _predictedFare = 0;
          _calculatedDistanceKm = 0;
        });
        final suggestions = await MLService.getAutocompleteSuggestions(value);
        if (mounted) {
          setState(() {
            _destSuggestions = suggestions;
            _isSearchingDest = false;
          });
        }
      } else {
        setState(() {
          _destSuggestions = [];
          _destLat = null;
          _destLng = null;
        });
      }
    });
  }

  // Open location picker on map
  Future<void> _selectLocationOnMap(TextEditingController controller) async {
    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialLocation: controller.text.isNotEmpty ? controller.text : null,
          ),
        ),
      );

      if (result != null && result['address'] != null) {
        setState(() {
          controller.text = result['address'] as String;
          if (controller == _pickupController) {
            _pickupLat = result['latitude'];
            _pickupLng = result['longitude'];
          } else {
            _destLat = result['latitude'];
            _destLng = result['longitude'];
          }
          _predictedFare = 0;
          _calculatedDistanceKm = 0;
        });
        _updateRouteAndFare();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening location picker: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  // Get ride type details
  Map<String, dynamic> _getRideTypeDetails(RideType type) {
    switch (type) {
      case RideType.economy:
        return {
          'name': 'Economy',
          'icon': FontAwesomeIcons.car,
          'description': 'Affordable eco-friendly rides',
          'priceMultiplier': 1.0,
          'perKmRate': 33.0, // User request
          'vehicleType': 'car_petrol',
          'eta': '3-5 min',
          'color': AppTheme.primaryGreen,
        };
      case RideType.comfort:
        return {
          'name': 'Comfort',
          'icon': FontAwesomeIcons.carSide,
          'description': 'More space and comfort',
          'priceMultiplier': 1.0, 
          'perKmRate': 38.0, 
          'vehicleType': 'comfort',
          'eta': '5-8 min',
          'color': AppTheme.accentBlue,
        };
      case RideType.premium:
        return {
          'name': 'Premium',
          'icon': FontAwesomeIcons.shuttleVan,
          'description': 'Luxury eco vehicles',
          'priceMultiplier': 1.0,
          'perKmRate': 50.0,
          'vehicleType': 'premium',
          'eta': '8-12 min',
          'color': AppTheme.accentPurple,
        };
    }
  }

  // Helper function to safely convert dynamic value to double
  double _toDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }



  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // km
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
    final dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * 3.141592653589793 / 180.0) * 
              math.cos(lat2 * 3.141592653589793 / 180.0) * 
              math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  // Calculate pricing breakdown
  Map<String, dynamic> _calculateFareDetails() {
    final details = _getRideTypeDetails(_selectedRideType);
    
    double dist = _calculatedDistanceKm;
    if (dist <= 0 && _pickupLat != null && _destLat != null) {
      dist = _haversineDistance(_pickupLat!, _pickupLng!, _destLat!, _destLng!) * 1.3;
    }
    if (dist <= 0) dist = 5.0; // Minimal default

    // Total Fare = Distance × Per Km Rate
    double totalFare = dist * details['perKmRate'];
    double farePerRider = _isShared ? (totalFare / _riderCount) : totalFare;

    return {
      'distance': dist,
      'totalFare': totalFare,
      'farePerRider': farePerRider,
    };
  }

  double _getFinalFare() {
    if (_predictedFare > 0) {
      final details = _getRideTypeDetails(_selectedRideType);
      double total = _predictedFare * details['priceMultiplier'];
      return _isShared ? (total / _riderCount) : total;
    }
    final fareDetails = _calculateFareDetails();
    return fareDetails['farePerRider'];
  }

  String _calculateEstimatedPrice() {
    double fare = _getFinalFare();
    if (fare <= 0) return '₹--';
    return '₹${fare.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              child: Icon(
                Icons.person,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Book a Ride',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Info icon for ride tips
          IconButton(
            icon: const Icon(FontAwesomeIcons.circleInfo, size: 20),
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            onPressed: () {
              // Show tips dialog
              _showRideTips(context, isDark);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              
              // Location Input Section
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Pickup Location
                      _buildLocationInput(
                        controller: _pickupController,
                        icon: FontAwesomeIcons.locationDot,
                        label: 'Pickup Location',
                        hint: 'Enter your pickup location',
                        onChanged: _onPickupChanged,
                        suggestions: _pickupSuggestions,
                        isSearching: _isSearchingPickup,
                        onSuggestionSelected: (s) async {
                          _pickupController.text = s;
                          setState(() => _pickupSuggestions = []);
                          final coords = await MLService.geocodeAddress(s);
                          if (coords != null && mounted) {
                            setState(() {
                              _pickupLat = coords['lat'];
                              _pickupLng = coords['lng'];
                            });
                          }
                          _updateRouteAndFare();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Swap Icon
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Swap pickup and destination
                            final temp = _pickupController.text;
                            _pickupController.text = _destinationController.text;
                            _destinationController.text = temp;
                            _calculateMLFare();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.backgroundDark : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.arrowsUpDown,
                              color: AppTheme.primaryGreen,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Destination Location
                      _buildLocationInput(
                        controller: _destinationController,
                        icon: FontAwesomeIcons.locationCrosshairs,
                        label: 'Destination',
                        hint: 'Where do you want to go?',
                        onChanged: _onDestChanged,
                        suggestions: _destSuggestions,
                        isSearching: _isSearchingDest,
                        onSuggestionSelected: (s) async {
                          _destinationController.text = s;
                          setState(() => _destSuggestions = []);
                          final coords = await MLService.geocodeAddress(s);
                          if (coords != null && mounted) {
                            setState(() {
                              _destLat = coords['lat'];
                              _destLng = coords['lng'];
                            });
                          }
                          _updateRouteAndFare();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              
              
              // Ride Type Selection Section
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Ride Type',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRideTypeSelector(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Estimated Price and ETA
              if (_pickupController.text.isNotEmpty && _destinationController.text.isNotEmpty)
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildEstimateCard(),
                ),
              
              const SizedBox(height: 24),
              
              // Search Button
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _searchForRides,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
                        SizedBox(width: 12),
                        Text(
                          'Find Available Drivers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Available Drivers Section
              if (_showDrivers) ...[
                FadeInUp(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Drivers (${_availableDrivers.length})',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.arrowsRotate,
                          size: 18,
                        ),
                        color: AppTheme.primaryGreen,
                        onPressed: _loadAvailableDrivers,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (_loadingDrivers)
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Finding nearby drivers...',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_availableDrivers.isEmpty)
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            FontAwesomeIcons.carSide,
                            color: Colors.grey[600],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No drivers available',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try again in a few moments',
                            style: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._availableDrivers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final driver = entry.value;
                    return FadeInUp(
                      delay: Duration(milliseconds: 200 + (index * 100)),
                      child: _buildDriverCard(driver),
                    );
                  }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildLocationInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required ValueChanged<String>? onChanged,
    required List<String> suggestions,
    required bool isSearching,
    required ValueChanged<String> onSuggestionSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
          onChanged: (value) {
            onChanged?.call(value);
            // Trigger rebuild to show/hide estimate card
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.mapLocationDot,
                    size: 18,
                  ),
                  color: AppTheme.primaryGreen,
                  onPressed: () => _selectLocationOnMap(controller).then((_) => _calculateMLFare()),
                  tooltip: 'Select on map',
                ),
              ],
            ),
            filled: true,
            fillColor: isDark ? AppTheme.backgroundDark : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(suggestions[index], style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 13)),
                  onTap: () => onSuggestionSelected(suggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRideTypeSelector() {
    return Row(
      children: [
        Expanded(child: _buildRideTypeCard(RideType.economy)),
        const SizedBox(width: 12),
        Expanded(child: _buildRideTypeCard(RideType.comfort)),
        const SizedBox(width: 12),
        Expanded(child: _buildRideTypeCard(RideType.premium)),
      ],
    );
  }

  Widget _buildRideTypeCard(RideType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = _getRideTypeDetails(type);
    final isSelected = _selectedRideType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRideType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (details['color'] as Color).withValues(alpha: 0.2)
              : (isDark ? AppTheme.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (details['color'] as Color)
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              details['icon'],
              color: isSelected ? details['color'] : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              details['name'],
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : AppTheme.textDark)
                    : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              details['eta'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = _getRideTypeDetails(_selectedRideType);
    final fareDetails = _calculateFareDetails();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (details['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Distance',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              _calculatingRoute
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    '${_calculatedDistanceKm > 0 ? _calculatedDistanceKm.toStringAsFixed(2) : _calculateFareDetails()['distance'].toStringAsFixed(2)} km',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ],
          ),
          if (_tripDurationMin > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Travel Time',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  '${_tripDurationMin.toStringAsFixed(0)} mins',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price estimate
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isShared ? 'ML Fare per rider' : 'ML Total Fare',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _calculatingFare
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Text(
                        _calculateEstimatedPrice(),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ],
              ),
              // ETA estimate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (details['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Pickup: ${details['eta']}',
                      style: TextStyle(
                        color: details['color'],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_tripDurationMin > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Arrival: ${DateTime.now().add(Duration(minutes: _tripDurationMin.toInt() + 5)).hour}:${DateTime.now().add(Duration(minutes: _tripDurationMin.toInt() + 5)).minute.toString().padLeft(2, "0")}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Payment Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      amount: _getFinalFare(),
                      pickup: _pickupController.text,
                      dropoff: _destinationController.text,
                      driverName: _availableDrivers.isNotEmpty ? _availableDrivers.first['name'] ?? 'Assigned Driver' : 'Assigned Driver',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRideTips(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.lightbulb,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Booking Tips',
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem(
              '🌱',
              'Choose Economy for eco-friendly rides',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '⭐',
              'Check driver ratings before booking',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '🚗',
              'Book in advance for better rates',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '💰',
              'Premium rides offer luxury experience',
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rating = _toDouble(driver['rating'], 4.5);
    
    return GestureDetector(
      onTap: () {
        // Navigate to driver profile detail with booking context
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverProfileDetailScreen(
              driver: driver,
              pickupLocation: _pickupController.text,
              destinationLocation: _destinationController.text,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Driver Avatar with status indicator
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.3),
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.user,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                // Online status indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Driver Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          driver['name'] ?? 'Driver',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Vehicle info
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.car,
                        color: Colors.grey[600],
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          driver['vehicle_model'] ?? 'Vehicle',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Vehicle type badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.leaf,
                              color: AppTheme.primaryGreen,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver['vehicle_type'] ?? 'EV',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Distance indicator (placeholder until GPS integration)
                      Text(
                        _placeholderDistance,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Arrow Icon with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.chevronRight,
                color: AppTheme.primaryGreen,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
