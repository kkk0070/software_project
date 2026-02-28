import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sepro/screens/rideshare/driver/driver_earnings_screen.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/active_ride_provider.dart';
import '../driver/driver_home_screen.dart';
import '../rider/ride_booking_screen.dart';
import '../rider/rider_booking_screen.dart';
import 'rides_history_screen.dart';
import 'maps_screen.dart';
import 'chat_list_screen.dart';
import 'user_profile_screen.dart';
import 'sustainability_dashboard_screen.dart';
import 'live_tracking_screen.dart';

/// Main navigation screen for the ride-sharing platform
class RideshareHomeScreen extends StatefulWidget {
  final String userRole;

  const RideshareHomeScreen({super.key, this.userRole = 'rider'});

  @override
  State<RideshareHomeScreen> createState() => _RideshareHomeScreenState();
}

class _RideshareHomeScreenState extends State<RideshareHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = widget.userRole.toLowerCase() == 'driver'
        ? [
            const DriverHomeScreen(),
            const SustainabilityDashboardScreen(), // Sustainability dashboard for driver
            const MapsScreen(),
            const ChatListScreen(),
            const UserProfileScreen(),
          ]
        : [
            RideBookingScreen(userRole: widget.userRole),
            const RiderBookingScreen(), // Book for rider
            const MapsScreen(),
            const ChatListScreen(),
            const UserProfileScreen(),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = widget.userRole.toLowerCase() == 'driver';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Floating ride-status pill (rider only) ──────────────────────
            if (!isDriver)
              Consumer<ActiveRideProvider>(
                builder: (context, activeRide, _) {
                  if (!activeRide.hasActiveRide) return const SizedBox.shrink();
                  return _ActiveRidePill(
                    activeRide: activeRide,
                    isDark: isDark,
                  );
                },
              ),
            // ── Bottom navigation bar ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 70,
                  child: Stack(
                    children: [
                      // Bottom navigation items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            icon: FontAwesomeIcons.house,
                            label: 'Home',
                            index: 0,
                          ),
                          _buildNavItem(
                            icon: isDriver
                                ? FontAwesomeIcons.leaf
                                : FontAwesomeIcons.calendarCheck,
                            label: isDriver ? 'Eco' : 'Book',
                            index: 1,
                          ),
                          const SizedBox(width: 60), // Space for center button
                          _buildNavItem(
                            icon: FontAwesomeIcons.message,
                            label: 'Chat',
                            index: 3,
                          ),
                          _buildNavItem(
                            icon: FontAwesomeIcons.user,
                            label: 'Profile',
                            index: 4,
                          ),
                        ],
                      ),
                      // Circular Maps button in center
                      Center(
                        child: Transform.translate(
                          offset: const Offset(0, -15),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndex = 2;
                              });
                            },
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _currentIndex == 2
                                      ? [
                                          AppTheme.primaryGreen,
                                          AppTheme.primaryGreen.withOpacity(0.8)
                                        ]
                                      : isDark
                                          ? [Colors.grey[800]!, Colors.grey[700]!]
                                          : [Colors.grey[300]!, Colors.grey[200]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_currentIndex == 2
                                            ? AppTheme.primaryGreen
                                            : isDark
                                                ? Colors.black
                                                : Colors.grey)
                                        .withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                FontAwesomeIcons.mapLocationDot,
                                color: _currentIndex == 2
                                    ? Colors.black
                                    : (isDark ? Colors.white : Colors.grey[700]),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppTheme.primaryGreen 
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? AppTheme.primaryGreen 
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating pill shown above the bottom nav bar when the rider has an active ride.
/// Tapping it opens the LiveTrackingScreen with the current driver's details.
class _ActiveRidePill extends StatelessWidget {
  final ActiveRideProvider activeRide;
  final bool isDark;

  const _ActiveRidePill({
    required this.activeRide,
    required this.isDark,
  });

  Color get _statusColor {
    switch (activeRide.status) {
      case RideStatus.accepted:
        return AppTheme.primaryGreen;
      case RideStatus.started:
        return AppTheme.accentBlue;
      case RideStatus.pending:
      default:
        return AppTheme.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(
              driverName: activeRide.driverName,
              vehicleInfo: [
                activeRide.vehicleModel,
                if (activeRide.licensePlate.isNotEmpty) activeRide.licensePlate,
              ].where((s) => s.isNotEmpty).join(' • '),
              etaMinutes: activeRide.etaMinutes,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated pulsing dot
            _PulsingDot(color: statusColor),
            const SizedBox(width: 12),
            // Driver avatar / icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: activeRide.status == RideStatus.pending
                    ? Icon(
                        FontAwesomeIcons.car,
                        color: statusColor,
                        size: 16,
                      )
                    : Text(
                        activeRide.driverName.isNotEmpty
                            ? activeRide.driverName[0].toUpperCase()
                            : 'D',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeRide.status == RideStatus.pending
                        ? 'Finding your driver…'
                        : activeRide.driverName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeRide.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: statusColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pulsing dot indicating live status
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
