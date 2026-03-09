import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../models/ride_models.dart';
import '../widgets/ride_card.dart';
import '../theme/app_theme.dart';

class RidesHistoryScreen extends StatefulWidget {
  const RidesHistoryScreen({super.key});

  @override
  State<RidesHistoryScreen> createState() => _RidesHistoryScreenState();
}

class _RidesHistoryScreenState extends State<RidesHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'All';
  String _sortBy = 'Date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryGreen,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: AppTheme.textLight,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.clock, size: 18),
                    text: 'Upcoming',
                  ),
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.checkCircle, size: 18),
                    text: 'Completed',
                  ),
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.xmark, size: 18),
                    text: 'Cancelled',
                  ),
                ],
              ),
              if (_filterType != 'All' || _sortBy != 'Date')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Row(
                    children: [
                      if (_filterType != 'All')
                        Chip(
                          label: Text(_filterType),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _filterType = 'All';
                            });
                          },
                        ),
                      if (_filterType != 'All' && _sortBy != 'Date')
                        const SizedBox(width: 8),
                      if (_sortBy != 'Date')
                        Chip(
                          label: Text('Sort: $_sortBy'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _sortBy = 'Date';
                            });
                          },
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterType = 'All';
                            _sortBy = 'Date';
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UpcomingRides(),
          _CompletedRides(),
          _CancelledRides(),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Filter by Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'EV', 'Pool', 'Solo'].map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _filterType == type,
                    onSelected: (selected) {
                      setModalState(() {
                        _filterType = type;
                      });
                      setState(() {
                        _filterType = type;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sort by',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Date', 'Price', 'Distance'].map((sort) {
                  return ChoiceChip(
                    label: Text(sort),
                    selected: _sortBy == sort,
                    onSelected: (selected) {
                      setModalState(() {
                        _sortBy = sort;
                      });
                      setState(() {
                        _sortBy = sort;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingRides extends StatelessWidget {
  const _UpcomingRides();

  @override
  Widget build(BuildContext context) {
    final upcomingRides = _getMockUpcomingRides();

    if (upcomingRides.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available,
        message: 'No upcoming rides',
        subtitle: 'Book your next eco-friendly ride!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: upcomingRides.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: RideCard(
            ride: upcomingRides[index],
            onTap: () {
              _showRideDetails(context, upcomingRides[index]);
            },
          ),
        );
      },
    );
  }

  List<Ride> _getMockUpcomingRides() {
    return [
      Ride(
        id: '1',
        pickupLocation: 'Tech Park, Electronic City',
        dropLocation: 'MG Road Metro Station',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        distance: 15.5,
        fare: 280,
        passengers: 3,
        isPooled: true,
        carbonSaved: 2.3,
        status: RideStatus.scheduled,
        driverName: 'Rajesh Kumar',
        vehicleNumber: 'KA-01-AB-1234',
      ),
      Ride(
        id: '2',
        pickupLocation: 'Indiranagar',
        dropLocation: 'Koramangala 5th Block',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        distance: 8.2,
        fare: 150,
        passengers: 1,
        isPooled: false,
        carbonSaved: 0,
        status: RideStatus.scheduled,
      ),
    ];
  }

  void _showRideDetails(BuildContext context, Ride ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RideDetailsSheet(ride: ride),
    );
  }
}

class _CompletedRides extends StatelessWidget {
  const _CompletedRides();

  @override
  Widget build(BuildContext context) {
    final completedRides = _getMockCompletedRides();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: completedRides.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: RideCard(ride: completedRides[index], onTap: () {}),
        );
      },
    );
  }

  List<Ride> _getMockCompletedRides() {
    return [
      Ride(
        id: '3',
        pickupLocation: 'Whitefield Main Road',
        dropLocation: 'Bangalore Airport',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        distance: 35.0,
        fare: 650,
        passengers: 2,
        isPooled: true,
        carbonSaved: 5.2,
        status: RideStatus.completed,
        driverName: 'Suresh Patel',
        vehicleNumber: 'KA-02-CD-5678',
      ),
      Ride(
        id: '4',
        pickupLocation: 'Jayanagar 4th Block',
        dropLocation: 'Brigade Road',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        distance: 12.0,
        fare: 220,
        passengers: 4,
        isPooled: true,
        carbonSaved: 3.8,
        status: RideStatus.completed,
        driverName: 'Prakash Reddy',
        vehicleNumber: 'KA-03-EF-9012',
      ),
      Ride(
        id: '5',
        pickupLocation: 'HSR Layout',
        dropLocation: 'BTM Layout',
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
        distance: 5.5,
        fare: 95,
        passengers: 1,
        isPooled: false,
        carbonSaved: 0,
        status: RideStatus.completed,
      ),
    ];
  }
}

class _CancelledRides extends StatelessWidget {
  const _CancelledRides();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.cancel_outlined,
      message: 'No cancelled rides',
      subtitle: 'Great! You haven\'t cancelled any rides',
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppTheme.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideDetailsSheet extends StatelessWidget {
  final Ride ride;

  const _RideDetailsSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ride Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Pickup',
                    value: ride.pickupLocation,
                    iconColor: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.flag,
                    label: 'Drop',
                    value: ride.dropLocation,
                    iconColor: AppTheme.errorRed,
                  ),
                  const Divider(height: 32),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value:
                        '${ride.dateTime.day}/${ride.dateTime.month}/${ride.dateTime.year}',
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value:
                        '${ride.dateTime.hour}:${ride.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  const Divider(height: 32),
                  if (ride.driverName != null) ...[
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Driver',
                      value: ride.driverName!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (ride.vehicleNumber != null) ...[
                    _DetailRow(
                      icon: Icons.directions_car,
                      label: 'Vehicle',
                      value: ride.vehicleNumber!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _DetailRow(
                    icon: Icons.route,
                    label: 'Distance',
                    value: '${ride.distance.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.payments,
                    label: 'Fare',
                    value: '₹${ride.fare.toStringAsFixed(0)}',
                  ),
                  if (ride.carbonSaved > 0) ...[
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: AppTheme.successGreen,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Carbon Saved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${ride.carbonSaved.toStringAsFixed(1)} kg CO₂',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (ride.status == RideStatus.scheduled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ride cancelled'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel Ride',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? AppTheme.primaryGreen, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
