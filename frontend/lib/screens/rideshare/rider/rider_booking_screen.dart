import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/user_service.dart';
import '../../../services/storage_service.dart';
import '../driver/driver_profile_detail_screen.dart';

/// Rider Booking Screen
/// Features:
/// - Select pickup and destination locations
/// - View available drivers
/// - Book a ride with a specific driver
class RiderBookingScreen extends StatefulWidget {
  const RiderBookingScreen({super.key});

  @override
  State<RiderBookingScreen> createState() => _RiderBookingScreenState();
}

class _RiderBookingScreenState extends State<RiderBookingScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  List<Map<String, dynamic>> _availableDrivers = [];
  bool _loadingDrivers = false;
  bool _showDrivers = false;

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

    // Scroll to show drivers
    Future.delayed(const Duration(milliseconds: 300), () {
      // You can add scroll animation here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        elevation: 0,
        title: Text(
          'Book a Ride',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Pickup Location
                      _buildLocationInput(
                        controller: _pickupController,
                        icon: FontAwesomeIcons.locationDot,
                        label: 'Pickup Location',
                        hint: 'Enter your pickup location',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Swap Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.backgroundDark : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.arrowsUpDown,
                            color: AppTheme.primaryGreen,
                            size: 16,
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
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _searchForRides,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Search for Drivers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      const Text(
                        'Available Drivers',
                        style: TextStyle(
                          color: Colors.white,
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
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
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
      ],
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Driver Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.2),
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
            
            const SizedBox(width: 16),
            
            // Driver Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver['name'] ?? 'Driver',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (driver['rating'] ?? 0.0).toString(),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.car,
                        color: Colors.grey[600],
                        size: 12,
                      ),
                      const SizedBox(width: 4),
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      driver['vehicle_type'] ?? 'EV',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
