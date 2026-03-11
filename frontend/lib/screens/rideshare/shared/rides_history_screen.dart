import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ride_service.dart';
import '../../../services/storage_service.dart';
import 'carpool_details_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../driver/driver_navigation_screen.dart';

class RidesHistoryScreen extends StatefulWidget {
  const RidesHistoryScreen({super.key});

  @override
  State<RidesHistoryScreen> createState() => _RidesHistoryScreenState();
}

class _RidesHistoryScreenState extends State<RidesHistoryScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _rides = [];
  List<Map<String, dynamic>> _carpools = [];
  bool _isLoading = true;
  int? _userId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      _userId = await StorageService.getUserId();
      
      // Load standard rides (as rider)
      if (_userId != null) {
        final riderRes = await RideService.getRides(riderId: _userId.toString());
        final driverRes = await RideService.getRides(driverId: _userId.toString());
        
        List<Map<String, dynamic>> allRides = [];
        if (riderRes['success'] == true && riderRes['data'] != null) {
          allRides.addAll((riderRes['data'] as List).cast<Map<String, dynamic>>());
        }
        if (driverRes['success'] == true && driverRes['data'] != null) {
          allRides.addAll((driverRes['data'] as List).cast<Map<String, dynamic>>());
        }
        
        // Sort by id descending (assuming newer is higher id)
        allRides.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
        
        if (mounted) {
          setState(() {
            _rides = allRides;
          });
        }
      }
      
      // Load carpools
      final carpoolRes = await RideService.getCarpoolHistory();
      if (carpoolRes['success'] == true && carpoolRes['data'] != null) {
        final data = carpoolRes['data'];
        _carpools = data is List
            ? data.map((item) => Map<String, dynamic>.from(item as Map)).toList()
            : [];
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryGreen,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Rides'),
                  Tab(text: 'Carpools'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                 // Tab 1: Standard Rides
                RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppTheme.primaryGreen,
                  child: _rides.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: _buildEmptyState(context),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rides.length,
                          itemBuilder: (context, index) => _buildRideCard(context, _rides[index]),
                        ),
                ),
                
                // Tab 2: Carpools
                RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppTheme.primaryGreen,
                  child: _carpools.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: _buildEmptyState(context, isCarpool: true),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _carpools.length,
                          itemBuilder: (context, index) => _buildCarpoolHistoryCard(context, _carpools[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCarpoolHistoryCard(BuildContext context, Map<String, dynamic> carpool) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarpoolDetailsScreen(carpoolId: carpool['id'])),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created by ${carpool['creator'] ?? 'User'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: carpool['is_creator'] == true ? Colors.blue.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    carpool['is_creator'] == true ? 'Owner' : 'Accepted', 
                    style: TextStyle(color: carpool['is_creator'] == true ? Colors.blue : AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(FontAwesomeIcons.locationDot, color: AppTheme.primaryGreen, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(carpool['from'] ?? 'Unknown', style: const TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(FontAwesomeIcons.flagCheckered, color: Colors.grey, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(carpool['to'] ?? 'Unknown', style: const TextStyle(fontSize: 13))),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OTP: ${carpool['user_otp'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Carpool'),
                            content: const Text('Are you sure you want to remove this carpool from your history?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() => _isLoading = true);
                          await RideService.deleteCarpool(carpool['id']);
                          _loadHistory();
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CarpoolDetailsScreen(carpoolId: carpool['id'])),
                        );
                      },
                      child: const Text('View Details →'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {bool isCarpool = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCarpool ? FontAwesomeIcons.users : FontAwesomeIcons.clockRotateLeft,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isCarpool ? 'No carpools joined' : 'No rides yet',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCarpool ? 'Join a carpool to see it here' : 'Your ride history will appear here',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Map<String, dynamic> ride) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = ride['created_at'] != null 
        ? DateTime.parse(ride['created_at']).toLocal().toString().split(' ')[0] 
        : 'Unknown Date';
    final from = ride['pickup_location'] ?? 'Unknown location';
    final to = ride['dropoff_location'] ?? 'Unknown destination';
    final status = ride['status'] ?? 'Completed';
    final driverName = ride['driver_name'] ?? 'Driver';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(from, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(FontAwesomeIcons.flagCheckered, color: colorScheme.onSurfaceVariant, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(to, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.user, color: colorScheme.onSurfaceVariant, size: 14),
                  const SizedBox(width: 8),
                  Text(driverName, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                ],
              ),
              if (ride['otp'] != null && (status == 'Active' || status == 'Arrived'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryGreen),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OTP: ${ride['otp']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
            ],
          ),
          if (status == 'Active' || status == 'Arrived' || status == 'PickedUp') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final isDriver = ride['driver_id'] == _userId;
                  if (isDriver) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverNavigationScreen(
                          rideId: ride['id'],
                          riderName: ride['rider_name'] ?? 'Rider',
                          pickupLocation: LatLng(
                            double.tryParse(ride['pickup_lat'].toString()) ?? 0,
                            double.tryParse(ride['pickup_lng'].toString()) ?? 0,
                          ),
                          dropoffLocation: LatLng(
                            double.tryParse(ride['dropoff_lat'].toString()) ?? 0,
                            double.tryParse(ride['dropoff_lng'].toString()) ?? 0,
                          ),
                          pickupAddress: ride['pickup_location'] ?? 'Pickup',
                          dropoffAddress: ride['dropoff_location'] ?? 'Dropoff',
                        ),
                      ),
                    ).then((_) => _loadHistory());
                  } else {
                    // For rider - could show a similar view or just a snackbar for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rider tracking view coming soon!')),
                    );
                  }
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Track Ride'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
