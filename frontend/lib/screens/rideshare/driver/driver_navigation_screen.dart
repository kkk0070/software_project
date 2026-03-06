import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../theme/app_theme.dart';

// Dark-mode map style (night theme).
const String _kNavDarkMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]''';

// ── Turn direction constants ────────────────────────────────────────────────
enum _TurnDirection { left, right, straight, slightLeft, slightRight, uTurn, arrive }

extension _TurnDirectionExt on _TurnDirection {
  IconData get icon {
    switch (this) {
      case _TurnDirection.left:       return Icons.turn_left;
      case _TurnDirection.right:      return Icons.turn_right;
      case _TurnDirection.slightLeft:  return Icons.turn_slight_left;
      case _TurnDirection.slightRight: return Icons.turn_slight_right;
      case _TurnDirection.uTurn:      return Icons.u_turn_left;
      case _TurnDirection.arrive:     return Icons.flag;
      case _TurnDirection.straight:
      default:                        return Icons.straight;
    }
  }

  String get label {
    switch (this) {
      case _TurnDirection.left:       return 'Turn Left';
      case _TurnDirection.right:      return 'Turn Right';
      case _TurnDirection.slightLeft:  return 'Keep Left';
      case _TurnDirection.slightRight: return 'Keep Right';
      case _TurnDirection.uTurn:      return 'Make U-Turn';
      case _TurnDirection.arrive:     return 'You have arrived';
      case _TurnDirection.straight:
      default:                        return 'Continue Straight';
    }
  }
}

// ── Navigation step model ────────────────────────────────────────────────────
class _NavStep {
  final _TurnDirection direction;
  final String distanceLabel;
  final String instruction;

  const _NavStep({
    required this.direction,
    required this.distanceLabel,
    required this.instruction,
  });
}

// ── ML-style bearing-based step generator ────────────────────────────────────

/// Computes the compass bearing (0–360°) from [a] to [b].
double _bearing(LatLng a, LatLng b) {
  final lat1 = a.latitude * math.pi / 180;
  final lat2 = b.latitude * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Haversine distance in metres between two [LatLng] points.
double _distanceM(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude) * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final sinDLat = math.sin(dLat / 2);
  final sinDLng = math.sin(dLng / 2);
  final c = sinDLat * sinDLat +
      math.cos(a.latitude * math.pi / 180) *
          math.cos(b.latitude * math.pi / 180) *
          sinDLng * sinDLng;
  return r * 2 * math.atan2(math.sqrt(c), math.sqrt(1 - c));
}

/// Derives a bearing-change angle (−180…+180°) between two consecutive
/// headings and classifies it as a [_TurnDirection].
_TurnDirection _classifyTurn(double delta) {
  if (delta > 160 || delta < -160) return _TurnDirection.uTurn;
  if (delta > 60)                  return _TurnDirection.right;
  if (delta > 20)                  return _TurnDirection.slightRight;
  if (delta < -60)                 return _TurnDirection.left;
  if (delta < -20)                 return _TurnDirection.slightLeft;
  return _TurnDirection.straight;
}

String _fmtDist(double metres) {
  if (metres >= 1000) return '${(metres / 1000).toStringAsFixed(1)} km';
  return '${metres.round()} m';
}

/// ML-style bearing-based algorithm: walks the route polyline, detects
/// significant heading changes (turns), and returns a concise list of
/// [_NavStep] instructions.
List<_NavStep> _generateSteps(List<LatLng> points) {
  if (points.length < 2) {
    return [
      const _NavStep(
        direction: _TurnDirection.arrive,
        distanceLabel: '0 m',
        instruction: 'You have arrived at your destination',
      )
    ];
  }

  // Handle straight 2-point route
  if (points.length == 2) {
    final dist = _distanceM(points[0], points[1]);
    return [
      _NavStep(
        direction: _TurnDirection.straight,
        distanceLabel: _fmtDist(dist),
        instruction: 'Continue straight to destination',
      ),
      const _NavStep(
        direction: _TurnDirection.arrive,
        distanceLabel: '0 m',
        instruction: 'You have arrived at your destination',
      ),
    ];
  }

  const double minSegmentM = 30.0; // ignore turns closer than 30 m
  final steps = <_NavStep>[];
  double accumulated = 0.0;
  double prevBearing = _bearing(points[0], points[1]);

  for (int i = 1; i < points.length - 1; i++) {
    final segDist = _distanceM(points[i - 1], points[i]);
    accumulated += segDist;
    final nextBearing = _bearing(points[i], points[i + 1]);
    // Normalise the change to −180…+180
    double delta = nextBearing - prevBearing;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;

    final turn = _classifyTurn(delta);
    if (turn != _TurnDirection.straight && accumulated >= minSegmentM) {
      steps.add(_NavStep(
        direction: turn,
        distanceLabel: _fmtDist(accumulated),
        instruction: '${turn.label} in ${_fmtDist(accumulated)}',
      ));
      accumulated = 0.0;
    }
    prevBearing = nextBearing;
  }

  // Final segment to destination
  final lastDist = accumulated + _distanceM(points[points.length - 2], points.last);
  if (lastDist >= minSegmentM) {
    steps.add(_NavStep(
      direction: _TurnDirection.straight,
      distanceLabel: _fmtDist(lastDist),
      instruction: 'Continue ${_fmtDist(lastDist)} to destination',
    ));
  }

  // If no turns were detected, add a single 'go straight' step
  if (steps.isEmpty) {
    double totalDist = 0.0;
    for (int i = 1; i < points.length; i++) {
      totalDist += _distanceM(points[i - 1], points[i]);
    }
    steps.add(_NavStep(
      direction: _TurnDirection.straight,
      distanceLabel: _fmtDist(totalDist),
      instruction: 'Continue straight to destination',
    ));
  }

  steps.add(const _NavStep(
    direction: _TurnDirection.arrive,
    distanceLabel: '0 m',
    instruction: 'You have arrived at your destination',
  ));
  return steps;
}

// ── DriverNavigationScreen ────────────────────────────────────────────────────

/// Turn-by-turn navigation screen.
///
/// Accepts optional [routePoints], [distance], [duration], [fromName], and
/// [destinationName].  When [routePoints] is supplied the bearing-based ML
/// algorithm generates real steps; otherwise a built-in demo sequence is used.
///
/// Each step is highlighted for [stepInterval] (default 500 ms) so the
/// animated left/right indicators cycle at the requested rate.
class DriverNavigationScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final String? distance;
  final String? duration;
  final String? fromName;
  final String? destinationName;
  /// How long each step is displayed (default 500 ms).
  final Duration stepInterval;

  const DriverNavigationScreen({
    super.key,
    this.routePoints = const [],
    this.distance,
    this.duration,
    this.fromName,
    this.destinationName,
    this.stepInterval = const Duration(milliseconds: 500),
  });

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen>
    with SingleTickerProviderStateMixin {
  late List<_NavStep> _steps;
  int _currentIndex = 0;
  Timer? _stepTimer;
  bool _isNavigating = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Map
  GoogleMapController? _mapController;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  // Default center used when no route points are available.
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _steps = widget.routePoints.isNotEmpty
        ? _generateSteps(widget.routePoints)
        : _demoSteps();

    _markers = _buildMarkers();
    _polylines = _buildPolylines();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Map helpers ───────────────────────────────────────────────────────────

  Set<Marker> _buildMarkers() {
    if (widget.routePoints.isEmpty) return {};
    return {
      Marker(
        markerId: const MarkerId('nav_origin'),
        position: widget.routePoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Start',
          snippet: widget.fromName,
        ),
      ),
      Marker(
        markerId: const MarkerId('nav_destination'),
        position: widget.routePoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.destinationName,
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    if (widget.routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('nav_route'),
        points: widget.routePoints,
        color: AppTheme.primaryGreen,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  /// Fits the camera to encompass the full route polyline.
  void _fitRouteBounds(GoogleMapController controller) {
    if (widget.routePoints.isEmpty) return;
    // Degrees of lat/lng padding added around the tight route bounds so that
    // the start/end markers are not clipped at the edges of the viewport.
    const double degPad = 0.005;
    // Pixel inset inside the visible viewport reserved for the overlaid
    // instruction card and bottom panel.
    const double pixelPad = 80.0;
    final lats = widget.routePoints.map((p) => p.latitude);
    final lngs = widget.routePoints.map((p) => p.longitude);
    final swLat = lats.reduce(math.min) - degPad;
    final swLng = lngs.reduce(math.min) - degPad;
    final neLat = lats.reduce(math.max) + degPad;
    final neLng = lngs.reduce(math.max) + degPad;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(swLat, swLng),
          northeast: LatLng(neLat, neLng),
        ),
        pixelPad,
      ),
    );
  }

  // ── Demo steps (used when no real route is provided) ─────────────────────
  List<_NavStep> _demoSteps() => [
        const _NavStep(direction: _TurnDirection.straight,   distanceLabel: '500 m',  instruction: 'Continue straight for 500 m'),
        const _NavStep(direction: _TurnDirection.right,      distanceLabel: '200 m',  instruction: 'Turn right in 200 m'),
        const _NavStep(direction: _TurnDirection.slightLeft, distanceLabel: '300 m',  instruction: 'Keep left in 300 m'),
        const _NavStep(direction: _TurnDirection.left,       distanceLabel: '150 m',  instruction: 'Turn left in 150 m'),
        const _NavStep(direction: _TurnDirection.straight,   distanceLabel: '1.2 km', instruction: 'Continue straight for 1.2 km'),
        const _NavStep(direction: _TurnDirection.right,      distanceLabel: '100 m',  instruction: 'Turn right in 100 m'),
        const _NavStep(direction: _TurnDirection.arrive,     distanceLabel: '0 m',    instruction: 'You have arrived at your destination'),
      ];

  // ── Navigation control ────────────────────────────────────────────────────
  void _startNavigation() {
    _stepTimer?.cancel();
    setState(() {
      _isNavigating = true;
      _currentIndex = 0;
    });
    _stepTimer = Timer.periodic(widget.stepInterval, (_) {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _steps.length - 1) {
          _currentIndex++;
        } else {
          _stepTimer?.cancel();
          _isNavigating = false;
        }
      });
    });
  }

  void _stopNavigation() {
    _stepTimer?.cancel();
    setState(() {
      _isNavigating = false;
      _currentIndex = 0;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_currentIndex];
    final isArrived = step.direction == _TurnDirection.arrive;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Real Google Map with route ──────────────────────────────
            GoogleMap(
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                final isDarkMap = Theme.of(context).brightness == Brightness.dark;
                if (isDarkMap) {
                  try {
                    await controller.setMapStyle(_kNavDarkMapStyle);
                  } catch (e) {
                    debugPrint('Navigation map style error: $e');
                  }
                }
                _fitRouteBounds(controller);
              },
              initialCameraPosition: CameraPosition(
                target: widget.routePoints.isNotEmpty
                    ? widget.routePoints.first
                    : _defaultLocation,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              tiltGesturesEnabled: false,
            ),

            // ── Turn instruction card (top) ─────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.cardDark : Colors.white).withOpacity(0.97),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
                  ],
                ),
                child: Row(
                  children: [
                    // Animated direction icon
                    ScaleTransition(
                      scale: _isNavigating ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Container(
                          key: ValueKey(step.direction),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isArrived ? Colors.green : AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            step.direction.icon,
                            color: Colors.black,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              key: ValueKey('dist_$_currentIndex'),
                              step.distanceLabel,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              key: ValueKey('inst_$_currentIndex'),
                              step.instruction,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Step progress indicators ─────────────────────────────────
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(
                  _steps.length,
                  (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentIndex
                            ? AppTheme.primaryGreen
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom panel ─────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Route summary
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: FontAwesomeIcons.clock,
                            label: 'ETA',
                            value: widget.duration ?? '—',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: FontAwesomeIcons.route,
                            label: 'Distance',
                            value: widget.distance ?? '—',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: FontAwesomeIcons.listOl,
                            label: 'Step',
                            value: '${_currentIndex + 1}/${_steps.length}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Destination label
                    if (widget.destinationName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.destinationName!,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Start / Stop navigation button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isArrived ? null : (_isNavigating ? _stopNavigation : _startNavigation),
                        icon: Icon(
                          isArrived
                              ? Icons.flag
                              : (_isNavigating ? Icons.stop : Icons.navigation),
                          size: 20,
                        ),
                        label: Text(
                          isArrived
                              ? 'Arrived!'
                              : (_isNavigating ? 'Stop Navigation' : 'Start Navigation'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isArrived
                              ? Colors.green
                              : (_isNavigating ? AppTheme.errorRed : AppTheme.primaryGreen),
                          foregroundColor: isArrived ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Back button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Map'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : Colors.black87,
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey[300]!,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
}

// ── _InfoCard ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}
