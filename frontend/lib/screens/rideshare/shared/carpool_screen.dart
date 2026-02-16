import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import 'carpool_search_screen.dart';
import 'carpool_detail_screen.dart';

/// Enhanced Carpool Screen
/// Features:
/// - Schedule rides with date/time picker
/// - Accept carpool plans
/// - View available carpool rides
/// - Matching UI layout for both driver and rider
class CarpoolScreen extends StatefulWidget {
  final String userRole;
  
  const CarpoolScreen({super.key, this.userRole = 'rider'});

  @override
  State<CarpoolScreen> createState() => _CarpoolScreenState();
}

class _CarpoolScreenState extends State<CarpoolScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _searchPickupController = TextEditingController();
  final TextEditingController _searchDropoffController = TextEditingController();
  List<Map<String, dynamic>> _filteredCarpoolRequests = [];
  
  // Sample carpool requests data
  final List<Map<String, dynamic>> _carpoolRequests = [
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredCarpoolRequests = _carpoolRequests; // Initialize with all rides
    _searchPickupController.addListener(_filterRides);
    _searchDropoffController.addListener(_filterRides);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _searchPickupController.dispose();
    _searchDropoffController.dispose();
    super.dispose();
  }

  void _filterRides() {
    final pickupQuery = _searchPickupController.text.toLowerCase();
    final dropoffQuery = _searchDropoffController.text.toLowerCase();
    
    setState(() {
      if (pickupQuery.isEmpty && dropoffQuery.isEmpty) {
        _filteredCarpoolRequests = _carpoolRequests;
      } else {
        _filteredCarpoolRequests = _carpoolRequests.where((ride) {
          final pickup = ride['pickup'].toString().toLowerCase();
          final dropoff = ride['dropoff'].toString().toLowerCase();
          
          final pickupMatch = pickupQuery.isEmpty || pickup.contains(pickupQuery);
          final dropoffMatch = dropoffQuery.isEmpty || dropoff.contains(dropoffQuery);
          
          return pickupMatch && dropoffMatch; // AND logic - both must match
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDriver = widget.userRole.toLowerCase() == 'driver';
    
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
          'Carpool',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarpoolSearchScreen(
                    userRole: widget.userRole,
                  ),
                ),
              );
            },
            tooltip: 'Search Carpools',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: [
            Tab(text: isDriver ? 'Create Schedule' : 'Schedule Ride'),
            Tab(text: isDriver ? 'Requests' : 'Available Rides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleTab(isDark),
          _buildAvailableRidesTab(isDark),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Save money and reduce carbon emissions by carpooling!',
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
          
          const SizedBox(height: 16),
          
          // Quick access to search carpools
          FadeInDown(
            delay: const Duration(milliseconds: 50),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarpoolSearchScreen(
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.search,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                label: Text(
                  'Search Available Carpools',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // OR divider
          FadeInDown(
            delay: const Duration(milliseconds: 75),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInLeft(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInLeft(
            delay: const Duration(milliseconds: 150),
            child: _buildTextField(
              controller: _pickupController,
              label: 'Pickup Location',
              icon: Icons.location_on,
              isDark: isDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildTextField(
              controller: _dropoffController,
              label: 'Drop-off Location',
              icon: Icons.flag,
              isDark: isDark,
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInLeft(
            delay: const Duration(milliseconds: 250),
            child: Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateTimeSelector(
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                    icon: Icons.calendar_today,
                    isDark: isDark,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeSelector(
                    label: 'Time',
                    value: _selectedTime.format(context),
                    icon: Icons.access_time,
                    isDark: isDark,
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInLeft(
            delay: const Duration(milliseconds: 350),
            child: Text(
              'Additional Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildOptionRow(
                    icon: FontAwesomeIcons.users,
                    label: 'Available Seats',
                    value: '2',
                    isDark: isDark,
                  ),
                  const Divider(height: 32),
                  _buildOptionRow(
                    icon: FontAwesomeIcons.dollarSign,
                    label: 'Price per Seat',
                    value: '\$5.00',
                    isDark: isDark,
                  ),
                  const Divider(height: 32),
                  _buildOptionRow(
                    icon: FontAwesomeIcons.bolt,
                    label: 'Electric Vehicle',
                    value: 'Yes',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          FadeInUp(
            delay: const Duration(milliseconds: 450),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _scheduleRide();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule Carpool Ride',
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

  Widget _buildAvailableRidesTab(bool isDark) {
    return Column(
      children: [
        // Pickup location search
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: _searchPickupController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Search pickup location...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.location_on,
                color: AppTheme.primaryGreen,
              ),
              suffixIcon: _searchPickupController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchPickupController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.cardDark : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        
        // Drop-off location search
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: _searchDropoffController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Search drop-off location...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.flag,
                color: AppTheme.primaryGreen,
              ),
              suffixIcon: _searchDropoffController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchDropoffController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.cardDark : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        
        // Info banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
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
                Icons.touch_app,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tap on any carpool to view full details and chat with driver',
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
        
        // List of carpools or empty state
        Expanded(
          child: _filteredCarpoolRequests.isEmpty
              ? _buildEmptySearchState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCarpoolRequests.length,
                  itemBuilder: (context, index) {
                    final request = _filteredCarpoolRequests[index];
                    return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarpoolDetailScreen(
                    carpoolData: request,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with driver info
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
                            request['driver'],
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
                                '${request['rating']}',
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
                      request['price'],
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
                            request['pickup'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            request['dropoff'],
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
                      label: request['date'],
                      isDark: isDark,
                    ),
                    _buildInfoChip(
                      icon: FontAwesomeIcons.userGroup,
                      label: '${request['seats']} seats',
                      isDark: isDark,
                    ),
                    _buildInfoChip(
                      icon: FontAwesomeIcons.leaf,
                      label: request['carbonSaved'],
                      isDark: isDark,
                      color: AppTheme.primaryGreen,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Accept button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _acceptCarpoolRequest(request);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept Carpool',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No rides found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Try adjusting your pickup or drop-off location filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchPickupController.clear();
              _searchDropoffController.clear();
            },
            icon: const Icon(Icons.clear, color: Colors.black),
            label: const Text(
              'Clear Filters',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppTheme.cardDark : Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _scheduleRide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.2),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ride Scheduled!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your carpool ride has been scheduled successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptCarpoolRequest(Map<String, dynamic> request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.2),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carpool Accepted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have successfully joined this carpool ride. The driver will be notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
