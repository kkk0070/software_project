import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

// Ride type options
enum RideType { economy, comfort, premium }

class _BookRideScreenState extends State<BookRideScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  bool _isPooled = true;
  int _passengers = 1;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // New fields for driver selection
  List<Map<String, dynamic>> _availableDrivers = [];
  bool _loadingDrivers = false;
  bool _showDrivers = false;
  RideType _selectedRideType = RideType.economy;
  String? _selectedDriverId;
  
  // Constants for pricing
  static const double _basePrice = 50.0;
  static const double _basePricePerKm = 5.0;
  // TODO: Replace with actual distance calculation from GPS/Maps API
  static const double _estimatedDistance = 8.5; // km - placeholder for demonstration

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAvailableDrivers() async {
    setState(() {
      _loadingDrivers = true;
    });

    try {
      final currentUserId = await StorageService.getUserId();
      final result = await UserService.getAvailableDrivers();
      
      if (result['success'] == true && result['data'] != null) {
        List<Map<String, dynamic>> drivers = List<Map<String, dynamic>>.from(result['data']);
        
        // Filter out current user
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
  
  // Get ride type details
  Map<String, dynamic> _getRideTypeDetails(RideType type) {
    switch (type) {
      case RideType.economy:
        return {
          'name': 'Economy',
          'icon': FontAwesomeIcons.car,
          'description': 'Affordable eco rides',
          'priceMultiplier': 1.0,
          'eta': '5-8 min',
          'color': AppTheme.primaryGreen,
        };
      case RideType.comfort:
        return {
          'name': 'Comfort',
          'icon': FontAwesomeIcons.carSide,
          'description': 'More space',
          'priceMultiplier': 1.3,
          'eta': '8-12 min',
          'color': AppTheme.accentBlue,
        };
      case RideType.premium:
        return {
          'name': 'Premium',
          'icon': FontAwesomeIcons.shuttleVan,
          'description': 'Luxury vehicles',
          'priceMultiplier': 1.8,
          'eta': '10-15 min',
          'color': AppTheme.accentPurple,
        };
    }
  }
  
  // Calculate estimated price
  String _calculateEstimatedPrice() {
    final details = _getRideTypeDetails(_selectedRideType);
    final distancePrice = _estimatedDistance * _basePricePerKm;
    final totalPrice = (_basePrice + distancePrice) * details['priceMultiplier'];
    
    // Apply pooling discount
    if (_isPooled) {
      return '\$${(totalPrice * 0.7).toStringAsFixed(2)}';
    }
    return '\$${totalPrice.toStringAsFixed(2)}';
  }
  
  void _searchForRides() {
    if (_pickupController.text.isEmpty || _dropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both pickup and destination'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _showDrivers = true;
    });
  }
  
  // Helper function to safely convert dynamic value to double
  double _toDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Book a Ride'),
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.circleInfo, size: 20),
            onPressed: () {
              _showRideTips(context, isDark);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enhanced Map placeholder with route visualization
            FadeInDown(
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.8),
                      AppTheme.accentBlue.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative grid pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _GridPainter(),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Route visualization
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.locationDot,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 2,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (index) => 
                                    Container(
                                      width: 4,
                                      height: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.flagCheckered,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.mapLocationDot,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_estimatedDistance.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Interactive Map Coming Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter your pickup and destination',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

              // Pickup Location
              FadeInLeft(
                delay: const Duration(milliseconds: 100),
                child: TextField(
                  controller: _pickupController,
                  onChanged: (value) {
                    // Update state only to show/hide price estimate card
                    if ((value.isNotEmpty && _dropController.text.isNotEmpty) ||
                        (value.isEmpty && _dropController.text.isNotEmpty)) {
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    hintText: 'Enter pickup address',
                    prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        // Use current location
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Drop Location
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: TextField(
                  controller: _dropController,
                  onChanged: (value) {
                    // Update state only to show/hide price estimate card
                    if ((value.isNotEmpty && _pickupController.text.isNotEmpty) ||
                        (value.isEmpty && _pickupController.text.isNotEmpty)) {
                      setState(() {});
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Drop Location',
                    hintText: 'Enter destination',
                    prefixIcon: Icon(Icons.flag, color: AppTheme.errorRed),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Vehicle Type Selection
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildVehicleTypeCard(RideType.economy, isDark)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildVehicleTypeCard(RideType.comfort, isDark)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildVehicleTypeCard(RideType.premium, isDark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              
              // Pool/Solo Toggle
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPoolOption(
                            icon: FontAwesomeIcons.users,
                            label: 'Pool Ride',
                            subtitle: 'Save 30% & reduce CO₂',
                            isSelected: _isPooled,
                            onTap: () => setState(() => _isPooled = true),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPoolOption(
                            icon: FontAwesomeIcons.carSide,
                            label: 'Solo Ride',
                            subtitle: 'Just you',
                            isSelected: !_isPooled,
                            onTap: () => setState(() => _isPooled = false),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Passengers count
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Card(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.user, 
                              color: AppTheme.primaryGreen, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Passengers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _passengers > 1
                                  ? () {
                                      setState(() {
                                        _passengers--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.primaryGreen,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_passengers',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _passengers < 4
                                  ? () {
                                      setState(() {
                                        _passengers++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Price Estimate Card
              if (_pickupController.text.isNotEmpty && _dropController.text.isNotEmpty)
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildPriceEstimateCard(isDark),
                ),
              const SizedBox(height: 16),

              // Schedule
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Card(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 30)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, 
                                        color: AppTheme.primaryGreen, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _selectedTime = time;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, 
                                        color: AppTheme.primaryGreen, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search for Drivers Button
              FadeInUp(
                delay: const Duration(milliseconds: 800),
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
                      shadowColor: AppTheme.primaryGreen.withOpacity(0.5),
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
                        'Available Drivers',
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
                        const CircularProgressIndicator(
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
                      child: _buildDriverCard(driver, isDark),
                    );
                  }).toList(),
              ],

              // Estimated Impact
              if (_isPooled && _pickupController.text.isNotEmpty)
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.leaf,
                          color: AppTheme.successGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Carbon Savings',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '~${(_estimatedDistance * 0.15).toStringAsFixed(1)} kg CO₂ by pooling this ride',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successGreen.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build vehicle type card
  Widget _buildVehicleTypeCard(RideType type, bool isDark) {
    final details = _getRideTypeDetails(type);
    final isSelected = _selectedRideType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRideType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? details['color'].withOpacity(0.15)
              : (isDark ? AppTheme.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? details['color']
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              details['icon'],
              color: isSelected ? details['color'] : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              details['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? details['color'] : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              details['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build pool option widget
  Widget _buildPoolOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppTheme.primaryGreen : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build price estimate card
  Widget _buildPriceEstimateCard(bool isDark) {
    final details = _getRideTypeDetails(_selectedRideType);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            details['color'].withOpacity(0.2),
            details['color'].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: details['color'].withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Fare',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _calculateEstimatedPrice(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: details['color'],
                        ),
                      ),
                      if (_isPooled)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '30% OFF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clock,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        details['eta'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.route,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_estimatedDistance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build driver card
  Widget _buildDriverCard(Map<String, dynamic> driver, bool isDark) {
    final name = driver['name'] ?? 'Unknown Driver';
    final rating = _toDouble(driver['rating'], 4.5);
    final vehicleModel = driver['vehicle_model'] ?? 'EV Vehicle';
    final vehiclePlate = driver['vehicle_plate'] ?? 'ABC-123';
    final tripsCompleted = driver['trips_completed'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppTheme.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _selectedDriverId == driver['id']
              ? AppTheme.primaryGreen
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDriverId = driver['id'];
          });
          _showBookingConfirmation(driver, isDark);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Driver avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FaIcon(
                          FontAwesomeIcons.car,
                          size: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$tripsCompleted trips',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$vehicleModel • $vehiclePlate',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // ETA badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  // TODO: Calculate actual ETA based on driver location
                  '3 min',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Show booking confirmation dialog
  void _showBookingConfirmation(Map<String, dynamic> driver, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 28),
            const SizedBox(width: 12),
            Text(
              'Confirm Booking',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book a ride with ${driver['name']}?',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('From', _pickupController.text, isDark),
                  const Divider(height: 20),
                  _buildSummaryRow('To', _dropController.text, isDark),
                  const Divider(height: 20),
                  _buildSummaryRow('Fare', _calculateEstimatedPrice(), isDark),
                  const Divider(height: 20),
                  _buildSummaryRow('Type', _getRideTypeDetails(_selectedRideType)['name'], isDark),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ride booked with ${driver['name']}!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  // Show ride tips dialog
  void _showRideTips(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.lightbulb, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 12),
            Text(
              'Booking Tips',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem('🌱', 'Pool rides save 30% and reduce carbon emissions', isDark),
            const SizedBox(height: 12),
            _buildTipItem('⭐', 'Check driver ratings before booking', isDark),
            const SizedBox(height: 12),
            _buildTipItem('🚗', 'Premium vehicles offer more comfort', isDark),
            const SizedBox(height: 12),
            _buildTipItem('📍', 'Verify pickup location for faster pickups', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.primaryGreen)),
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
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for grid pattern
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
