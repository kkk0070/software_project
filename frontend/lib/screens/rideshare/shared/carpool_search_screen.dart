import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import 'location_picker_screen.dart';
import 'carpool_detail_screen.dart';

/// Carpool Search Screen
/// Allows users to search for available carpool rides by:
/// - Pickup location
/// - Drop-off location
/// - Date and time
/// Shows filtered results based on search criteria
class CarpoolSearchScreen extends StatefulWidget {
  final String userRole;

  const CarpoolSearchScreen({
    super.key,
    this.userRole = 'rider',
  });

  @override
  State<CarpoolSearchScreen> createState() => _CarpoolSearchScreenState();
}

class _CarpoolSearchScreenState extends State<CarpoolSearchScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearched = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Sample carpool data - In a real app, this would come from an API
  final List<Map<String, dynamic>> _allCarpools = [
    {
      'id': 1,
      'driverId': 101,
      'pickup': 'Downtown Plaza',
      'dropoff': 'Airport Terminal 2',
      'date': 'Today, 2:30 PM',
      'seats': 2,
      'price': '\$8.50',
      'driver': 'John D.',
      'rating': 4.8,
      'carbonSaved': '2.1 kg CO₂',
      'distance': '15.2 km',
      'duration': '28 min',
      'tripCount': 245,
    },
    {
      'id': 2,
      'driverId': 102,
      'pickup': 'University Campus',
      'dropoff': 'Shopping Mall',
      'date': 'Tomorrow, 10:00 AM',
      'seats': 3,
      'price': '\$6.00',
      'driver': 'Sarah M.',
      'rating': 4.9,
      'carbonSaved': '1.8 kg CO₂',
      'distance': '10.5 km',
      'duration': '18 min',
      'tripCount': 312,
    },
    {
      'id': 3,
      'driverId': 103,
      'pickup': 'Tech Park',
      'dropoff': 'Central Station',
      'date': 'Today, 5:45 PM',
      'seats': 1,
      'price': '\$7.25',
      'driver': 'Mike R.',
      'rating': 4.7,
      'carbonSaved': '1.5 kg CO₂',
      'distance': '12.8 km',
      'duration': '22 min',
      'tripCount': 189,
    },
    {
      'id': 4,
      'driverId': 104,
      'pickup': 'Downtown Plaza',
      'dropoff': 'University Campus',
      'date': 'Tomorrow, 8:00 AM',
      'seats': 2,
      'price': '\$5.50',
      'driver': 'Emily K.',
      'rating': 4.9,
      'carbonSaved': '1.2 kg CO₂',
      'distance': '8.3 km',
      'duration': '15 min',
      'tripCount': 278,
    },
    {
      'id': 5,
      'driverId': 105,
      'pickup': 'Airport Terminal 1',
      'dropoff': 'Downtown Plaza',
      'date': 'Today, 11:30 AM',
      'seats': 3,
      'price': '\$9.00',
      'driver': 'David L.',
      'rating': 4.6,
      'carbonSaved': '2.5 kg CO₂',
      'distance': '16.7 km',
      'duration': '32 min',
      'tripCount': 156,
    },
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Carpool',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Form
          _buildSearchForm(isDark),

          // Search Results
          Expanded(
            child: _hasSearched
                ? _buildSearchResults(isDark)
                : _buildEmptyState(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Find carpools near you and save on travel costs!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Pickup Location
          FadeInLeft(
            delay: const Duration(milliseconds: 100),
            child: _buildLocationField(
              controller: _pickupController,
              label: 'Pickup Location',
              icon: Icons.location_on,
              isDark: isDark,
              onTap: () => _selectLocation(true),
            ),
          ),

          const SizedBox(height: 16),

          // Drop-off Location
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildLocationField(
              controller: _dropoffController,
              label: 'Drop-off Location',
              icon: Icons.flag,
              isDark: isDark,
              onTap: () => _selectLocation(false),
            ),
          ),

          const SizedBox(height: 20),

          // Search Button
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _searchCarpools,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.5),
                ),
                child: _isSearching
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search Carpools',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryGreen,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.map,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
            onPressed: onTap,
            tooltip: 'Select from map',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppTheme.backgroundDark : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.1),
              ),
              child: Icon(
                Icons.search,
                size: 60,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for Carpools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Enter your pickup and drop-off locations to find available carpool rides',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_searchResults.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.search_off,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Carpools Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Try adjusting your search criteria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_searchResults.length} carpool${_searchResults.length != 1 ? 's' : ''} found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final carpool = _searchResults[index];
              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: _buildCarpoolCard(carpool, isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarpoolCard(Map<String, dynamic> carpool, bool isDark) {
    return GestureDetector(
      onTap: () => _viewCarpoolDetails(carpool),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with driver info and price
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carpool['driver'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.ecoGold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${carpool['rating']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  carpool['price'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Route info
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carpool['pickup'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        carpool['dropoff'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: FontAwesomeIcons.clock,
                  label: carpool['date'],
                  isDark: isDark,
                ),
                _buildInfoChip(
                  icon: FontAwesomeIcons.userGroup,
                  label: '${carpool['seats']} seats',
                  isDark: isDark,
                ),
                _buildInfoChip(
                  icon: FontAwesomeIcons.leaf,
                  label: carpool['carbonSaved'],
                  isDark: isDark,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _viewCarpoolDetails(carpool),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? (isDark ? Colors.grey[800] : Colors.grey[200]))!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color ?? (isDark ? Colors.grey[400] : Colors.grey[700]),
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? (isDark ? Colors.grey[400] : Colors.grey[700]),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLocation(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: isPickup
              ? _pickupController.text
              : _dropoffController.text,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result;
        } else {
          _dropoffController.text = result;
        }
      });
    }
  }

  Future<void> _searchCarpools() async {
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both pickup and drop-off locations'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Filter carpools based on search criteria
    // In a real app, this would be an API call with server-side filtering
    // Note: Using case-insensitive substring matching for demo purposes
    // Production should implement more sophisticated matching (fuzzy, prefix, or exact)
    final results = _allCarpools.where((carpool) {
      final pickupMatch = carpool['pickup']
          .toString()
          .toLowerCase()
          .contains(_pickupController.text.toLowerCase());
      final dropoffMatch = carpool['dropoff']
          .toString()
          .toLowerCase()
          .contains(_dropoffController.text.toLowerCase());
      
      // Use AND condition to match both pickup and dropoff
      return pickupMatch && dropoffMatch;
    }).toList();

    if (mounted) {
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  void _viewCarpoolDetails(Map<String, dynamic> carpool) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarpoolDetailScreen(
          carpoolData: carpool,
        ),
      ),
    );
  }
}
