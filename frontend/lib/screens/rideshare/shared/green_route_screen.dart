import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../theme/app_theme.dart';
import '../../../utils/maps_utils.dart';

/// Maps API key – same as maps_screen.dart.
const String _kGreenRouteMapsApiKey = 'YOUR_API_KEY_HERE';

/// Base URL of the local ML route server (ml/server.py).
const String _kGreenRouteServerUrl = 'http://localhost:8080';

/// 15️⃣ Green Route Recommendation Page
///
/// Compares multiple route options (fastest, balanced, eco-optimised) and
/// draws them on a Google Map. The eco-optimised route is highlighted in
/// green with an "Eco Friendly Route" badge and CO₂ saved info.
class GreenRouteScreen extends StatefulWidget {
  /// Optional origin/destination to pre-populate the map.
  final LatLng? origin;
  final LatLng? destination;
  final String originLabel;
  final String destinationLabel;

  const GreenRouteScreen({
    super.key,
    this.origin,
    this.destination,
    this.originLabel = 'Origin',
    this.destinationLabel = 'Destination',
  });

  @override
  State<GreenRouteScreen> createState() => _GreenRouteScreenState();
}

class _GreenRouteScreenState extends State<GreenRouteScreen> {
  GoogleMapController? _mapController;

  // Default SF demo locations
  static const LatLng _defaultOrigin = LatLng(37.7749, -122.4194);
  static const LatLng _defaultDest = LatLng(37.8044, -122.2712);

  // CO₂ emission factors (kg per km) per route type – used when Directions
  // API returns actual distances.
  static const double _ecoEmissionFactor = 0.12;
  static const double _fastEmissionFactor = 0.21;
  static const double _balancedEmissionFactor = 0.15;

  late LatLng _origin;
  late LatLng _dest;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  bool _isLoading = false;
  int _selectedRoute = 0; // 0 = eco, 1 = fastest, 2 = scenic

  /// Static route option metadata (distance/time/CO₂ come from API or estimates).
  final List<_RouteOption> _routes = [
    _RouteOption(
      id: 'eco',
      title: 'Eco-Optimised Route',
      subtitle: 'Lowest emissions',
      icon: FontAwesomeIcons.leaf,
      color: AppTheme.primaryGreen,
      isEco: true,
      co2Kg: 1.2,
      co2Saved: 0.9,
      timeMin: 12,
      distanceKm: 4.0,
    ),
    _RouteOption(
      id: 'fastest',
      title: 'Fastest Route',
      subtitle: 'Quickest travel time',
      icon: FontAwesomeIcons.bolt,
      color: AppTheme.accentBlue,
      isEco: false,
      co2Kg: 2.1,
      co2Saved: 0.0,
      timeMin: 10,
      distanceKm: 5.0,
    ),
    _RouteOption(
      id: 'balanced',
      title: 'Balanced Route',
      subtitle: 'Best of both worlds',
      icon: FontAwesomeIcons.route,
      color: AppTheme.warningOrange,
      isEco: false,
      co2Kg: 1.5,
      co2Saved: 0.6,
      timeMin: 11,
      distanceKm: 4.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _origin = widget.origin ?? _defaultOrigin;
    _dest = widget.destination ?? _defaultDest;
    _loadRoutes();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Route Loading ─────────────────────────────────────────────────────────

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    _buildStaticMarkers();

    // On web always try the ML server; on native require a real API key.
    if (kIsWeb || _kGreenRouteMapsApiKey != 'YOUR_API_KEY_HERE') {
      await _fetchAndDrawDirectionsRoutes();
    } else {
      _buildDemoPolylines();
    }

    setState(() => _isLoading = false);
    _fitCamera();
  }

  void _buildStaticMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('origin'),
        position: _origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.originLabel,
          snippet: 'Start',
        ),
      ),
      Marker(
        markerId: const MarkerId('dest'),
        position: _dest,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.destinationLabel,
          snippet: 'End',
        ),
      ),
    };
  }

  /// Fetches up to 3 alternative routes.
  /// On web: uses the local ML route server (avoids CORS).
  /// On native: uses the Google Directions API (if key configured).
  Future<void> _fetchAndDrawDirectionsRoutes() async {
    if (kIsWeb) {
      // Use ML route server – road-following polylines, no CORS issues.
      try {
        final uri = Uri.parse('$_kGreenRouteServerUrl/all_routes').replace(
          queryParameters: {
            'origin_lat': _origin.latitude.toString(),
            'origin_lng': _origin.longitude.toString(),
            'dest_lat':   _dest.latitude.toString(),
            'dest_lng':   _dest.longitude.toString(),
          },
        );
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          _buildDemoPolylines();
          return;
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final apiRoutes = data['routes'] as List<dynamic>? ?? [];
        if (apiRoutes.isEmpty) {
          _buildDemoPolylines();
          return;
        }
        final polylines = <Polyline>{};
        for (int i = 0; i < math.min(apiRoutes.length, _routes.length); i++) {
          final r = apiRoutes[i] as Map<String, dynamic>;
          final rawCoords = r['coordinates'] as List<dynamic>;
          final pts = rawCoords.map((c) {
            final pair = c as List<dynamic>;
            return LatLng(
              (pair[0] as num).toDouble(),
              (pair[1] as num).toDouble(),
            );
          }).toList();
          polylines.add(_buildPolyline(i, pts));

          _routes[i] = _routes[i].copyWith(
            distanceKm: (r['distance_km'] as num).toDouble(),
            timeMin:    (r['time_min'] as num).ceil(),
            co2Kg:      (r['co2_kg'] as num).toDouble(),
          );
        }
        setState(() => _polylines = polylines);
        return;
      } catch (e) {
        debugPrint('GreenRoute ML server error: $e');
        _buildDemoPolylines();
        return;
      }
    }
    // Native path: use Google Directions API.
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${_origin.latitude},${_origin.longitude}',
          'destination': '${_dest.latitude},${_dest.longitude}',
          'alternatives': 'true',
          'mode': 'driving',
          'key': _kGreenRouteMapsApiKey,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        _buildDemoPolylines();
        return;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if ((data['status'] as String) != 'OK') {
        _buildDemoPolylines();
        return;
      }
      final apiRoutes = data['routes'] as List<dynamic>;
      final polylines = <Polyline>{};
      for (int i = 0; i < math.min(apiRoutes.length, _routes.length); i++) {
        final route = apiRoutes[i] as Map<String, dynamic>;
        final encoded = (route['overview_polyline']
            as Map<String, dynamic>)['points'] as String;
        final pts = MapsUtils.decodePolyline(encoded);
        polylines.add(_buildPolyline(i, pts));

        // Update distance / time from API response
        final leg = ((route['legs'] as List<dynamic>)[0]) as Map<String, dynamic>;
        final distM = (leg['distance'] as Map<String, dynamic>)['value'] as int;
        final durS = (leg['duration'] as Map<String, dynamic>)['value'] as int;
        _routes[i] = _routes[i].copyWith(
          distanceKm: distM / 1000.0,
          timeMin: (durS / 60).ceil(),
          co2Kg: distM / 1000.0 *
              (i == 0
                  ? _ecoEmissionFactor
                  : i == 1
                      ? _fastEmissionFactor
                      : _balancedEmissionFactor),
        );
      }
      setState(() => _polylines = polylines);
    } catch (e) {
      debugPrint('GreenRoute Directions error: $e');
      _buildDemoPolylines();
    }
  }

  /// Builds demo straight-line polylines when no API key is configured.
  void _buildDemoPolylines() {
    // Three slightly different paths via intermediate waypoints
    final mid = LatLng(
      (_origin.latitude + _dest.latitude) / 2,
      (_origin.longitude + _dest.longitude) / 2,
    );
    final offsets = [0.008, -0.012, 0.004];
    final polylines = <Polyline>{};
    for (int i = 0; i < _routes.length; i++) {
      final via = LatLng(mid.latitude + offsets[i], mid.longitude + offsets[i]);
      polylines.add(_buildPolyline(i, [_origin, via, _dest]));
    }
    setState(() => _polylines = polylines);
  }

  Polyline _buildPolyline(int index, List<LatLng> points) {
    final r = _routes[index];
    final isSelected = index == _selectedRoute;
    return Polyline(
      polylineId: PolylineId(r.id),
      points: points,
      color: isSelected ? r.color : r.color.withOpacity(0.35),
      width: isSelected ? 5 : 3,
      patterns: index == 0
          ? [] // eco = solid
          : index == 1
              ? [PatternItem.dash(20), PatternItem.gap(8)] // fastest = dashed
              : [PatternItem.dot, PatternItem.gap(6)], // balanced = dotted
      zIndex: isSelected ? 2 : 0,
    );
  }

  void _selectRoute(int index) {
    setState(() {
      _selectedRoute = index;
      // Rebuild polylines with updated selection
      final currentPoints = _polylines.map((p) => p.points).toList();
      if (currentPoints.length == _routes.length) {
        _polylines = {
          for (int i = 0; i < _routes.length; i++)
            _buildPolyline(i, currentPoints[i]),
        };
      }
    });
  }

  void _fitCamera() {
    final allLat = [_origin.latitude, _dest.latitude];
    final allLng = [_origin.longitude, _dest.longitude];
    const pad = 0.02;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
              allLat.reduce(math.min) - pad, allLng.reduce(math.min) - pad),
          northeast: LatLng(
              allLat.reduce(math.max) + pad, allLng.reduce(math.max) + pad),
        ),
        60,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Green Routes',
            style:
                TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: Column(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (_origin.latitude + _dest.latitude) / 2,
                      (_origin.longitude + _dest.longitude) / 2,
                    ),
                    zoom: 12,
                  ),
                  onMapCreated: (c) {
                    _mapController = c;
                    _fitCamera();
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen)),
                  ),
              ],
            ),
          ),

          // ── Route options list ────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your route',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _routes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _buildRouteCard(context, i, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, int index, bool isDark) {
    final r = _routes[index];
    final isSelected = index == _selectedRoute;

    return GestureDetector(
      onTap: () => _selectRoute(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? r.color.withOpacity(0.1)
              : (isDark ? AppTheme.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? r.color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Route icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: r.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(r.icon, color: r.color, size: 18),
            ),
            const SizedBox(width: 12),

            // Title + metrics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          r.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (r.isEco) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🌿 Eco Friendly',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Metric(
                          Icons.access_time, '${r.timeMin} min', Colors.grey),
                      const SizedBox(width: 10),
                      _Metric(Icons.straighten,
                          '${r.distanceKm.toStringAsFixed(1)} km',
                          Colors.grey),
                      const SizedBox(width: 10),
                      _Metric(Icons.cloud_outlined,
                          '${r.co2Kg.toStringAsFixed(1)} kg CO₂',
                          r.isEco ? AppTheme.primaryGreen : Colors.grey),
                    ],
                  ),
                  if (r.co2Saved > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saves ${r.co2Saved.toStringAsFixed(1)} kg CO₂ vs fastest',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Radio indicator
            Radio<int>(
              value: index,
              groupValue: _selectedRoute,
              onChanged: (v) => _selectRoute(v!),
              activeColor: r.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper types & widgets ────────────────────────────────────────────────────

class _RouteOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isEco;
  final double co2Kg;
  final double co2Saved;
  final int timeMin;
  final double distanceKm;

  const _RouteOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isEco,
    required this.co2Kg,
    required this.co2Saved,
    required this.timeMin,
    required this.distanceKm,
  });

  _RouteOption copyWith({
    double? co2Kg,
    double? co2Saved,
    int? timeMin,
    double? distanceKm,
  }) {
    return _RouteOption(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      isEco: isEco,
      co2Kg: co2Kg ?? this.co2Kg,
      co2Saved: co2Saved ?? this.co2Saved,
      timeMin: timeMin ?? this.timeMin,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Metric(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
