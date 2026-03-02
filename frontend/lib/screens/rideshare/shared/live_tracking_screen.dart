import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../theme/app_theme.dart';
import 'emergency_screen.dart';

/// 7️⃣ Live Ride Tracking Page – with real Google Map and live GPS tracking.
class LiveTrackingScreen extends StatefulWidget {
  final String driverName;
  final String vehicleInfo;
  final int etaMinutes;

  /// Optional initial driver position (latitude/longitude). When provided the
  /// map centres on the driver; otherwise it uses the user's GPS location.
  final LatLng? initialDriverPosition;

  const LiveTrackingScreen({
    super.key,
    this.driverName = 'Your Driver',
    this.vehicleInfo = '',
    this.etaMinutes = 5,
    this.initialDriverPosition,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;

  /// Current user/rider position (from device GPS).
  LatLng? _userPosition;

  /// Simulated driver position – starts at [initialDriverPosition] and moves
  /// toward the user each tick (demo mode; replace with WebSocket updates).
  LatLng? _driverPosition;

  Set<Marker> _markers = {};

  /// GPS position stream subscription – more efficient than periodic polling.
  StreamSubscription<Position>? _positionStream;

  /// Periodic timer used only for driver animation and ETA countdown.
  Timer? _animationTimer;

  int _currentEta = 0;
  bool _isMapReady = false;

  // Default fallback (San Francisco)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _currentEta = widget.etaMinutes;
    _initTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _animationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Location & Tracking ───────────────────────────────────────────────────

  Future<void> _initTracking() async {
    // Request location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _startWithDefault();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _startWithDefault();
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _userPosition = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _userPosition = _defaultLocation;
    }

    // Place driver slightly offset from the user (demo)
    _driverPosition = widget.initialDriverPosition ??
        LatLng(
          _userPosition!.latitude + 0.01,
          _userPosition!.longitude + 0.01,
        );

    _updateMarkers();
    _startLiveTracking();
  }

  void _startWithDefault() {
    _userPosition = _defaultLocation;
    _driverPosition = widget.initialDriverPosition ??
        LatLng(_defaultLocation.latitude + 0.01,
            _defaultLocation.longitude + 0.01);
    _updateMarkers();
    _startLiveTracking();
  }

  /// Subscribes to the device's position stream (fires only on location change)
  /// and starts a periodic animation timer for the driver marker and ETA.
  void _startLiveTracking() {
    // 1. Subscribe to position stream for efficient GPS updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // metres – only fire when moved ≥5 m
      ),
    ).listen((pos) {
      if (mounted) {
        _userPosition = LatLng(pos.latitude, pos.longitude);
        _updateMarkers();
      }
    }, onError: (_) {
      // Ignore stream errors; last known position is kept
    });

    // 2. Separate timer for driver animation & ETA countdown (every 3 s)
    _animationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Move driver closer to user (demo simulation)
      if (_driverPosition != null && _userPosition != null) {
        const step = 0.001; // ~111 m per degree; demo only – replace with backend WebSocket position
        final dlat = _userPosition!.latitude - _driverPosition!.latitude;
        final dlng = _userPosition!.longitude - _driverPosition!.longitude;
        _driverPosition = LatLng(
          _driverPosition!.latitude + dlat.clamp(-step, step),
          _driverPosition!.longitude + dlng.clamp(-step, step),
        );
      }

      // Decrement ETA
      if (_currentEta > 0) _currentEta--;

      _updateMarkers();

      // Follow driver with camera
      if (_isMapReady && _driverPosition != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_driverPosition!),
        );
      }
    });
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Driver marker (car icon colour)
    if (_driverPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.driverName,
          snippet: widget.vehicleInfo.isNotEmpty ? widget.vehicleInfo : 'Driver',
        ),
      ));
    }

    // User / pickup marker
    if (_userPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _userPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ));
    }

    if (mounted) setState(() => _markers = markers);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final etaLabel = _currentEta <= 1 ? '1 min' : '$_currentEta min';
    final vehicleDisplay =
        widget.vehicleInfo.isNotEmpty ? widget.vehicleInfo : 'Vehicle';
    final initialTarget = _driverPosition ?? _userPosition ?? _defaultLocation;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Live Google Map ───────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() => _isMapReady = true);
                if (_driverPosition != null) {
                  controller.animateCamera(
                      CameraUpdate.newLatLng(_driverPosition!));
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),

            // ── Top bar: back + ETA badge + emergency ────────────────────
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    context,
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  // ETA badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FontAwesomeIcons.clock,
                            color: Colors.black, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'ETA  $etaLabel',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildIconButton(
                    context,
                    Icons.emergency,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmergencyScreen()),
                    ),
                    color: colorScheme.error,
                  ),
                ],
              ),
            ),

            // ── Driver info panel ─────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Driver row
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryGreen,
                                Color(0xFF00C853)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.driverName.isNotEmpty
                                  ? widget.driverName[0].toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.driverName,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicleDisplay,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Call button
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ETA + Distance info cards
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: FontAwesomeIcons.clock,
                            label: 'ETA',
                            value: etaLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: FontAwesomeIcons.route,
                            label: 'Distance',
                            value: '2.5 mi',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
