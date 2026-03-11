import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ride_service.dart';
import '../../../services/storage_service.dart';
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
  String? _currentUserId;

  // Create schedule state
  int _availableSeats = 2;
  double _pricePerSeat = 5.0;
  bool _isEv = true;

  // Filter state
  bool _filterEvOnly = false;
  int? _filterMinSeats;   // null = any; 1, 2, 3+ values
  String _sortBy = 'default'; // 'default' | 'price' | 'rating'

  // Sample carpool requests data
  List<Map<String, dynamic>> _carpoolRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredCarpoolRequests = _carpoolRequests;
    _searchPickupController.addListener(_filterRides);
    _searchDropoffController.addListener(_filterRides);
    _loadAvailableCarpools();
  }

  Future<void> _loadAvailableCarpools() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      _currentUserId = (await StorageService.getUserId())?.toString();
      final res = await RideService.getAvailableCarpools();
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final validList = data is List
            ? data.map((item) => Map<String, dynamic>.from(item as Map)).toList()
            : <Map<String, dynamic>>[];
            
        // Map db payload format to the UI expectations setup by earlier static arrays
        _carpoolRequests = validList.map((cp) => {
          'id': cp['id'],
          'driverId': cp['creator_id'] ?? cp['driverId'],
          'pickup': cp['pickup'] ?? cp['pickup_location'] ?? cp['from'] ?? 'Unknown',
          'dropoff': cp['dropoff'] ?? cp['dropoff_location'] ?? cp['to'] ?? 'Unknown',
          'date': cp['scheduled_time'] != null ? DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(cp['scheduled_time']).toLocal()) : 'Unknown Time',
          'seats': cp['max_participants'] ?? 0,
          'price': '₹${cp['fare'] ?? 0}',
          'driver': cp['creator'] ?? 'Driver',
          'rating': 4.8, 
          'carbonSaved': '2.1 kg CO₂',
          'distance': '15.2 km',
          'duration': '28 min',
          'tripCount': 10,
          'vehicleType': cp['vehicle_type'] ?? 'EV',
        }).toList();
        
      }
      if (mounted) {
        setState(() {
          _filteredCarpoolRequests = _carpoolRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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
      var results = _carpoolRequests.where((ride) {
        final pickup = ride['pickup'].toString().toLowerCase();
        final dropoff = ride['dropoff'].toString().toLowerCase();

        final pickupMatch = pickupQuery.isEmpty || pickup.contains(pickupQuery);
        final dropoffMatch = dropoffQuery.isEmpty || dropoff.contains(dropoffQuery);

        // EV filter
        final evMatch = !_filterEvOnly ||
            (ride['vehicleType']?.toString().toLowerCase() == 'ev');

        // Min seats filter
        final seats = ride['seats'] as int? ?? 0;
        final seatsMatch = _filterMinSeats == null || seats >= _filterMinSeats!;

        return pickupMatch && dropoffMatch && evMatch && seatsMatch;
      }).toList();

      // Sorting
      if (_sortBy == 'price') {
        results.sort((a, b) {
          final pa = double.tryParse(
                  a['price'].toString().replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          final pb = double.tryParse(
                  b['price'].toString().replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          return pa.compareTo(pb);
        });
      } else if (_sortBy == 'rating') {
        results.sort((a, b) {
          final ra = (a['rating'] as num?)?.toDouble() ?? 0;
          final rb = (b['rating'] as num?)?.toDouble() ?? 0;
          return rb.compareTo(ra); // descending
        });
      }

      _filteredCarpoolRequests = results;
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
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleTab(isDark),
          RefreshIndicator(
            onRefresh: _loadAvailableCarpools,
            color: AppTheme.primaryGreen,
            child: _buildAvailableRidesTab(isDark)
          ),
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
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Additional Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppTheme.primaryGreen, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _showEditOptionsDialog,
                ),
              ],
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
                    value: '$_availableSeats',
                    isDark: isDark,
                  ),
                  const Divider(height: 32),
                  _buildOptionRow(
                    icon: FontAwesomeIcons.dollarSign,
                    label: 'Price per Seat',
                    value: '\$${_pricePerSeat.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                  const Divider(height: 32),
                  _buildOptionRow(
                    icon: FontAwesomeIcons.bolt,
                    label: 'Electric Vehicle',
                    value: _isEv ? 'Yes' : 'No',
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
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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

        // Filter chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: '⚡ EV Only',
                selected: _filterEvOnly,
                isDark: isDark,
                onSelected: (_) {
                  _filterEvOnly = !_filterEvOnly;
                  _filterRides();
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: '2+ Seats',
                selected: _filterMinSeats == 2,
                isDark: isDark,
                onSelected: (_) {
                  _filterMinSeats = _filterMinSeats == 2 ? null : 2;
                  _filterRides();
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: '3+ Seats',
                selected: _filterMinSeats == 3,
                isDark: isDark,
                onSelected: (_) {
                  _filterMinSeats = _filterMinSeats == 3 ? null : 3;
                  _filterRides();
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Lowest Price',
                selected: _sortBy == 'price',
                isDark: isDark,
                onSelected: (_) {
                  _sortBy = _sortBy == 'price' ? 'default' : 'price';
                  _filterRides();
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Top Rated',
                selected: _sortBy == 'rating',
                isDark: isDark,
                onSelected: (_) {
                  _sortBy = _sortBy == 'rating' ? 'default' : 'rating';
                  _filterRides();
                },
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
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
                    if ((request['vehicleType'] ?? '').toString().isNotEmpty)
                      _buildInfoChip(
                        icon: request['vehicleType'] == 'EV'
                            ? FontAwesomeIcons.bolt
                            : FontAwesomeIcons.carSide,
                        label: request['vehicleType'],
                        isDark: isDark,
                        color: request['vehicleType'] == 'EV'
                            ? AppTheme.accentBlue
                            : AppTheme.warningOrange,
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Accept button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: request['driverId']?.toString() == _currentUserId 
                        ? null 
                        : () {
                            _acceptCarpoolRequest(request);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: request['driverId']?.toString() == _currentUserId 
                          ? Colors.grey 
                          : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      request['driverId']?.toString() == _currentUserId 
                          ? 'Your Carpool' 
                          : 'Accept Carpool',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: request['driverId']?.toString() == _currentUserId 
                            ? Colors.white70 
                            : Colors.black,
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required bool isDark,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected
              ? Colors.black
              : (isDark ? Colors.grey[300] : Colors.grey[800]),
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.grey[200],
      checkmarkColor: Colors.black,
      side: BorderSide(
        color: selected
            ? AppTheme.primaryGreen
            : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        color: (color ?? (isDark ? Colors.grey[800] : Colors.grey[200]))!.withValues(alpha: 0.3),
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

  Future<void> _scheduleRide() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Validate inputs
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup and drop-off locations.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final userIdStr = await StorageService.getUserId();
    final userId = int.tryParse(userIdStr?.toString() ?? '0') ?? 0;

    final datetimeStr = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).toUtc().toIso8601String();

    final res = await RideService.createCarpool(
      creatorId: userId,
      pickupLocation: _pickupController.text,
      dropoffLocation: _dropoffController.text,
      scheduledTime: datetimeStr,
      fare: _pricePerSeat,
      maxParticipants: _availableSeats,
      vehicleType: _isEv ? 'EV' : 'Car',
    );

    if (!mounted) return;
    Navigator.pop(context); // hide loading

    if (res['success'] == true) {
      // Refresh available carpools list
      _loadAvailableCarpools();
      
      // Clear form
      _pickupController.clear();
      _dropoffController.clear();

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
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
                    // Optionally switch to Available Rides tab
                    _tabController.animateTo(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(res['message'] ?? 'Failed to schedule carpool.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showEditOptionsDialog() {
    int tempSeats = _availableSeats;
    double tempPrice = _pricePerSeat;
    bool tempEv = _isEv;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Seats:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (tempSeats > 1) {
                                setDialogState(() => tempSeats--);
                              }
                            },
                          ),
                          Text('$tempSeats'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (tempSeats < 8) {
                                setDialogState(() => tempSeats++);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price: \$'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (tempPrice > 1.0) {
                                setDialogState(() => tempPrice--);
                              }
                            },
                          ),
                          Text(tempPrice.toStringAsFixed(2)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setDialogState(() => tempPrice++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Electric Vehicle'),
                    value: tempEv,
                    onChanged: (val) => setDialogState(() => tempEv = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _availableSeats = tempSeats;
                      _pricePerSeat = tempPrice;
                      _isEv = tempEv;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _acceptCarpoolRequest(Map<String, dynamic> request) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    final userId = int.tryParse(_currentUserId ?? '0') ?? 0;
    final res = await RideService.acceptCarpool(carpoolId: request['id'], participantId: userId);
    
    if (!mounted) return;
    Navigator.pop(context); // close loading
    
    if (res['success'] == true) {
      final otp = res['user_otp'] ?? 'N/A';
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
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
                'OTP: $otp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share this OTP with the driver. You can view it anytime in your ride history.',
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(res['message'] ?? 'Failed to accept carpool.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
