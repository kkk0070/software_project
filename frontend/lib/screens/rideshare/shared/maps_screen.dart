import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/maps_utils.dart';
import '../driver/driver_navigation_screen.dart';

/// Google Maps API key.
/// Must match the key used in:
///   - web/index.html  (Maps JavaScript API script tag)
///   - android/app/src/main/AndroidManifest.xml  (com.google.android.geo.API_KEY)
///
/// Replace this placeholder with your actual key from Google Cloud Console.
/// Do NOT commit a real API key here without first restricting it in the Cloud
/// Console (by HTTP referrer, Android fingerprint, or iOS bundle ID).
const String _kMapsApiKey = 'AIzaSyDrpIN_Stxm5qFtWu8YjvShd3PNK8OMcMY';

/// Base URL of the local ML route server (ml/server.py).
/// Start it with: cd ml && python server.py
/// Used on Flutter Web to bypass CORS restrictions on Google Maps REST APIs.
const String _kRouteServerUrl = 'http://localhost:8080';

/// Dark-mode map style JSON (night theme).
const String _darkMapStyle = '''[
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

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _error;

  // Search & autocomplete
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<String> _fromSuggestions = [];
  List<String> _destSuggestions = [];
  bool _showFromSuggestions = false;
  bool _showDestSuggestions = false;
  Timer? _debounceTimer;
  bool _isPanelExpanded = true;

  bool _isRouteLoading = false;
  String? _routeError;

  // Route data
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];

  // Route info (distance / duration from Directions API)
  String? _routeDistance;
  String? _routeDuration;

  // Vehicle type selection & emission / AQI data
  String _selectedVehicle = 'car_petrol';
  double? _routeDistanceKm;
  LatLng? _routeMidpoint;
  Map<String, dynamic>? _emissionData;
  Map<String, dynamic>? _aqiData;

  /// Supported vehicle types shown in the selector.
  static const List<Map<String, dynamic>> _vehicleTypes = [
    {'id': 'car_petrol',  'label': 'Car',     'icon': Icons.directions_car,    'factor': 0.210},
    {'id': 'car_diesel',  'label': 'Diesel',  'icon': Icons.directions_car_filled, 'factor': 0.171},
    {'id': 'motorcycle',  'label': 'Moto',    'icon': Icons.two_wheeler,        'factor': 0.103},
    {'id': 'electric',    'label': 'EV',      'icon': Icons.electric_car,       'factor': 0.053},
    {'id': 'bus',         'label': 'Bus',     'icon': Icons.directions_bus,     'factor': 0.089},
    {'id': 'bicycle',     'label': 'Bike',    'icon': Icons.pedal_bike,         'factor': 0.000},
    {'id': 'walking',     'label': 'Walk',    'icon': Icons.directions_walk,    'factor': 0.000},
  ];

  // Default location (San Francisco)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  /// Returns true when the API key has been replaced with a real value.
  bool get _isApiKeyConfigured => _kMapsApiKey != 'YOUR_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    _fromController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  // ── Geocoding ─────────────────────────────────────────────────────────────

  Future<LatLng?> _geocodeAddress(String address) async {
    if (kIsWeb) return _geocodeAddressWeb(address);
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } on NoResultFoundException {
      // Address yielded no results.
    } catch (e) {
      debugPrint('Geocoding error for "$address": $e');
    }
    return null;
  }

  Future<LatLng?> _geocodeAddressWeb(String address) async {
    try {
      final uri = Uri.parse('$_kRouteServerUrl/geocode')
          .replace(queryParameters: {'address': address});
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) return null;
      return LatLng(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('Web geocoding error for "$address": $e');
    }
    return null;
  }

  // ── Places Autocomplete ───────────────────────────────────────────────────

  /// Fetches autocomplete suggestions.
  /// On web: uses the local ML route server (avoids CORS).
  /// On native: uses the Google Places Autocomplete API (if key configured).
  Future<List<String>> _fetchAutocompleteSuggestions(String input) async {
    if (input.length < 3) return [];
    if (kIsWeb) {
      try {
        final uri = Uri.parse('$_kRouteServerUrl/autocomplete')
            .replace(queryParameters: {'input': input});
        final response = await http.get(uri);
        if (response.statusCode != 200) return [];
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final predictions = data['predictions'] as List<dynamic>? ?? [];
        return predictions
            .map((p) => (p as Map<String, dynamic>)['description'] as String)
            .toList();
      } catch (e) {
        debugPrint('Autocomplete error: $e');
        return [];
      }
    }
    if (!_isApiKeyConfigured) return [];
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {'input': input, 'key': _kMapsApiKey, 'types': 'geocode'},
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final predictions = data['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map((p) => (p as Map<String, dynamic>)['description'] as String)
          .toList();
    } catch (e) {
      debugPrint('Autocomplete error: $e');
      return [];
    }
  }

  void _onFromChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final suggestions = await _fetchAutocompleteSuggestions(value);
      if (mounted) {
        setState(() {
          _fromSuggestions = suggestions;
          _showFromSuggestions = suggestions.isNotEmpty;
        });
      }
    });
  }

  void _onDestChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final suggestions = await _fetchAutocompleteSuggestions(value);
      if (mounted) {
        setState(() {
          _destSuggestions = suggestions;
          _showDestSuggestions = suggestions.isNotEmpty;
        });
      }
    });
  }

  // ── Directions API (road-path routing) ───────────────────────────────────

  /// Calls the ML route server (on web) or Google Directions API (on native)
  /// and draws the actual road-path polyline.
  /// Falls back to straight-line if neither source succeeds.
  Future<void> _drawDirectionsRoute(LatLng from, LatLng destination) async {
    List<LatLng> routePoints = [from, destination]; // fallback
    String? distance;
    String? duration;
    double? distanceKm; // numeric km – used for emission calculation

    if (kIsWeb) {
      // On web use the local ML route server (ml/server.py) – no CORS issues.
      try {
        final uri = Uri.parse('$_kRouteServerUrl/route').replace(
          queryParameters: {
            'origin_lat': from.latitude.toString(),
            'origin_lng': from.longitude.toString(),
            'dest_lat':   destination.latitude.toString(),
            'dest_lng':   destination.longitude.toString(),
          },
        );
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final coords = data['coordinates'] as List<dynamic>;
          if (coords.isNotEmpty) {
            routePoints = coords.map((c) {
              final pair = c as List<dynamic>;
              return LatLng(
                (pair[0] as num).toDouble(),
                (pair[1] as num).toDouble(),
              );
            }).toList();
            distanceKm = (data['distance_km'] as num).toDouble();
            distance =
                '${distanceKm.toStringAsFixed(1)} km';
            duration =
                '${(data['time_min'] as num).toStringAsFixed(0)} min';
          }
        }
      } catch (e) {
        debugPrint('Directions API error: $e');
      }
    } else if (_isApiKeyConfigured) {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/directions/json',
          {
            'origin': '${from.latitude},${from.longitude}',
            'destination':
                '${destination.latitude},${destination.longitude}',
            'mode': 'driving',
            'key': _kMapsApiKey,
          },
        );
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String;
          if (status == 'OK') {
            final routes = data['routes'] as List<dynamic>;
            if (routes.isNotEmpty) {
              final route = routes[0] as Map<String, dynamic>;
              final overviewPolyline =
                  route['overview_polyline'] as Map<String, dynamic>;
              final encoded = overviewPolyline['points'] as String;
              routePoints = MapsUtils.decodePolyline(encoded);

              final leg =
                  ((route['legs'] as List<dynamic>)[0]) as Map<String, dynamic>;
              distance =
                  (leg['distance'] as Map<String, dynamic>)['text'] as String;
              duration =
                  (leg['duration'] as Map<String, dynamic>)['text'] as String;
              // Parse numeric distance from Google response (metres → km)
              final distM =
                  (leg['distance'] as Map<String, dynamic>)['value'] as int;
              distanceKm = distM / 1000.0;
            }
          }
        }
      } catch (e) {
        debugPrint('Directions API error: $e');
      }
    }

    // If no API provided a distance, approximate from straight-line
    // Use a final non-nullable variable so Dart flow analysis is satisfied.
    final double effectiveDistanceKm =
        distanceKm ?? (_haversineKm(from, destination) * 1.3);

    // Route midpoint for AQI estimation
    final midIdx = routePoints.length ~/ 2;
    final midpoint = routePoints.isNotEmpty ? routePoints[midIdx] : from;

    // Build markers
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('from'),
        position: from,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'From',
          snippet: _fromController.text,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: _destinationController.text,
        ),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: AppTheme.primaryGreen,
        width: 5,
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
      _routePoints = routePoints;
      _routeDistance = distance;
      _routeDuration = duration;
      _routeDistanceKm = effectiveDistanceKm;
      _routeMidpoint = midpoint;
    });

    // Fit camera
    const double minDelta = 0.005;
    final lats = routePoints.map((p) => p.latitude);
    final lngs = routePoints.map((p) => p.longitude);
    final swLat = lats.reduce(math.min) - minDelta;
    final swLng = lngs.reduce(math.min) - minDelta;
    final neLat = lats.reduce(math.max) + minDelta;
    final neLng = lngs.reduce(math.max) + minDelta;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(swLat, swLng),
          northeast: LatLng(neLat, neLng),
        ),
        80,
      ),
    );

    // Calculate emission + AQI for the selected vehicle type
    await _calculateEmission(effectiveDistanceKm, midpoint);
  }

  /// Haversine straight-line distance between two points (km).
  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h = sinDLat * sinDLat +
        math.cos(_degToRad(a.latitude)) *
            math.cos(_degToRad(b.latitude)) *
            sinDLng * sinDLng;
    return 2 * r * math.asin(math.sqrt(h));
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;

  // ── Route Search ──────────────────────────────────────────────────────────

  Future<void> _searchRoute() async {
    final fromText = _fromController.text.trim();
    final destText = _destinationController.text.trim();

    if (fromText.isEmpty || destText.isEmpty) {
      setState(() {
        _routeError = 'Please enter both From and Destination locations.';
      });
      return;
    }

    setState(() {
      _isRouteLoading = true;
      _routeError = null;
      _showFromSuggestions = false;
      _showDestSuggestions = false;
    });

    final from = await _geocodeAddress(fromText);
    final destination = await _geocodeAddress(destText);

    if (from == null) {
      setState(() {
        _isRouteLoading = false;
        _routeError =
            'Could not find "From" location. Try a more specific address.';
      });
      return;
    }

    if (destination == null) {
      setState(() {
        _isRouteLoading = false;
        _routeError =
            'Could not find "Destination" location. Try a more specific address.';
      });
      return;
    }

    setState(() {
      _isRouteLoading = false;
    });

    await _drawDirectionsRoute(from, destination);
  }

  void _clearRoute() {
    setState(() {
      _fromController.clear();
      _destinationController.clear();
      _markers = {};
      _polylines = {};
      _routePoints = [];
      _routeError = null;
      _routeDistance = null;
      _routeDuration = null;
      _fromSuggestions = [];
      _destSuggestions = [];
      _showFromSuggestions = false;
      _showDestSuggestions = false;
      _routeDistanceKm = null;
      _routeMidpoint = null;
      _emissionData = null;
      _aqiData = null;
    });
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  // ── Vehicle & Emission ────────────────────────────────────────────────────

  /// Called when the user taps a vehicle type chip.
  /// Immediately recalculates emissions without re-fetching the route.
  void _onVehicleChanged(String vehicleId) {
    setState(() => _selectedVehicle = vehicleId);
    if (_routeDistanceKm != null) {
      _calculateEmission(_routeDistanceKm!, _routeMidpoint);
    }
  }

  /// Compute emission + AQI.  On Flutter Web the ML server is called first;
  /// the local fallback is always used on native or when the server is down.
  Future<void> _calculateEmission(double distanceKm, LatLng? midpoint) async {
    if (kIsWeb) {
      bool serverOk = false;
      try {
        // Emission
        final emUri = Uri.parse('$_kRouteServerUrl/emission').replace(
          queryParameters: {
            'vehicle_type': _selectedVehicle,
            'distance_km':  distanceKm.toString(),
          },
        );
        final emRes = await http.get(emUri);
        if (emRes.statusCode == 200) {
          final emData = jsonDecode(emRes.body) as Map<String, dynamic>;
          if (!emData.containsKey('error')) {
            setState(() => _emissionData = emData);
            serverOk = true;
          }
        }

        // AQI (use midpoint of route, or a default)
        final mp = midpoint ?? _defaultLocation;
        final aqiUri = Uri.parse('$_kRouteServerUrl/air_quality').replace(
          queryParameters: {
            'lat':          mp.latitude.toString(),
            'lng':          mp.longitude.toString(),
            'distance_km':  distanceKm.toString(),
            'vehicle_type': _selectedVehicle,
          },
        );
        final aqiRes = await http.get(aqiUri);
        if (aqiRes.statusCode == 200) {
          final aqiData = jsonDecode(aqiRes.body) as Map<String, dynamic>;
          if (!aqiData.containsKey('error')) {
            setState(() => _aqiData = aqiData);
          }
        }
      } catch (e) {
        debugPrint('Emission/AQI server error: $e');
      }
      if (serverOk) return; // server handled it
    }

    // Local fallback (always used on native; fallback on web)
    _calculateEmissionLocally(distanceKm, midpoint);
  }

  /// Calculate emission and a simulated AQI entirely in Dart (no server call).
  void _calculateEmissionLocally(double distanceKm, LatLng? midpoint) {
    final vInfo = _vehicleTypes.firstWhere(
      (v) => v['id'] == _selectedVehicle,
      orElse: () => _vehicleTypes[0],
    );
    final factor = (vInfo['factor'] as double);
    final co2 = factor * distanceKm;

    String category;
    if (co2 == 0) {
      category = 'Zero Emission';
    } else if (co2 < 0.5) {
      category = 'Very Low';
    } else if (co2 < 1.5) {
      category = 'Low';
    } else if (co2 < 3.0) {
      category = 'Moderate';
    } else if (co2 < 6.0) {
      category = 'High';
    } else {
      category = 'Very High';
    }

    // Simulated AQI based on emission contribution
    final mp = midpoint ?? _defaultLocation;
    final urbanFactor =
        (math.sin(mp.latitude * 0.12)).abs() * (math.cos(mp.longitude * 0.08)).abs();
    final baseAqi = 40 + urbanFactor * 80;
    final aqiImpactFactors = {
      'car_petrol': 1.00, 'car_diesel': 1.25, 'motorcycle': 0.80,
      'electric': 0.08, 'bus': 0.30, 'bicycle': 0.00, 'walking': 0.00,
    };
    final aqiImpact = (aqiImpactFactors[_selectedVehicle] ?? 0.5) * distanceKm * 2.5;
    final aqiValue = (baseAqi + aqiImpact).clamp(0, 500).toInt();

    String aqiCategory;
    String aqiColor;
    String aqiDesc;
    if (aqiValue <= 50) {
      aqiCategory = 'Good'; aqiColor = '#00e400';
      aqiDesc = 'Air quality is satisfactory.';
    } else if (aqiValue <= 100) {
      aqiCategory = 'Moderate'; aqiColor = '#ffff00';
      aqiDesc = 'Acceptable air quality.';
    } else if (aqiValue <= 150) {
      aqiCategory = 'Unhealthy for Sensitive Groups'; aqiColor = '#ff7e00';
      aqiDesc = 'Sensitive people may be affected.';
    } else if (aqiValue <= 200) {
      aqiCategory = 'Unhealthy'; aqiColor = '#ff0000';
      aqiDesc = 'Everyone may experience health effects.';
    } else {
      aqiCategory = 'Very Unhealthy'; aqiColor = '#8f3f97';
      aqiDesc = 'Health alert for everyone.';
    }

    setState(() {
      _emissionData = {
        'co2_kg': double.parse(co2.toStringAsFixed(3)),
        'emission_factor_kg_per_km': factor,
        'category': category,
      };
      _aqiData = {
        'aqi': aqiValue,
        'category': aqiCategory,
        'color': aqiColor,
        'description': aqiDesc,
      };
    });
  }

  /// Parse a hex color string like '#00e400' to a Flutter [Color].
  static Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              if (isDark) {
                await controller.setMapStyle(_darkMapStyle);
              }
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : _defaultLocation,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            markers: _markers.isNotEmpty
                ? _markers
                : (_currentPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId('current_location'),
                          position: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          infoWindow: const InfoWindow(
                            title: 'Your Location',
                          ),
                        ),
                      }
                    : {}),
            polylines: _polylines,
            onTap: (_) {
              setState(() {
                _showFromSuggestions = false;
                _showDestSuggestions = false;
              });
            },
          ),

          // Top Search Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.locationDot,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Plan Your Route',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        if (_polylines.isNotEmpty)
                          GestureDetector(
                            onTap: _clearRoute,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPanelExpanded = !_isPanelExpanded;
                            });
                          },
                          child: Icon(
                            _isPanelExpanded ? Icons.expand_less : Icons.expand_more,
                            color: isDark ? Colors.white : Colors.black,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    if (_isPanelExpanded) ...[
                      const SizedBox(height: 12),

                    // From search bar + suggestions
                    _SearchBarWithSuggestions(
                      controller: _fromController,
                      hint: 'From (e.g. New York, NY)',
                      icon: Icons.trip_origin,
                      iconColor: AppTheme.primaryGreen,
                      isDark: isDark,
                      suggestions: _fromSuggestions,
                      showSuggestions: _showFromSuggestions,
                      onChanged: _onFromChanged,
                      onSuggestionTap: (s) {
                        _fromController.text = s;
                        setState(() {
                          _showFromSuggestions = false;
                          _fromSuggestions = [];
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Route connector line
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 16,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Destination search bar + suggestions
                    _SearchBarWithSuggestions(
                      controller: _destinationController,
                      hint: 'Destination (e.g. Los Angeles, CA)',
                      icon: Icons.location_on,
                      iconColor: AppTheme.errorRed,
                      isDark: isDark,
                      suggestions: _destSuggestions,
                      showSuggestions: _showDestSuggestions,
                      onChanged: _onDestChanged,
                      onSuggestionTap: (s) {
                        _destinationController.text = s;
                        setState(() {
                          _showDestSuggestions = false;
                          _destSuggestions = [];
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Vehicle type selector
                    _VehicleSelector(
                      vehicleTypes: _vehicleTypes,
                      selected: _selectedVehicle,
                      onSelected: _onVehicleChanged,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Get Route button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRouteLoading ? null : _searchRoute,
                        icon: _isRouteLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.directions, size: 18),
                        label: Text(
                            _isRouteLoading ? 'Finding Route...' : 'Get Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    // Route info (distance / duration)
                    if (_routeDistance != null && _routeDuration != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.straighten,
                                    color: AppTheme.primaryGreen, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _routeDistance!,
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 16,
                                color:
                                    AppTheme.primaryGreen.withValues(alpha: 0.3)),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: AppTheme.primaryGreen, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _routeDuration!,
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Navigate button – shown after shortest distance is displayed
                    if (_routeDistance != null && _routeDuration != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DriverNavigationScreen(
                                  routePoints: _routePoints,
                                  distance: _routeDistance,
                                  duration: _routeDuration,
                                  fromName: _fromController.text,
                                  destinationName: _destinationController.text,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.navigation, size: 20),
                          label: const Text('Start Navigation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Emission info card
                    if (_emissionData != null && _polylines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.eco,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CO₂ Emission: '
                                    '${(_emissionData!['co2_kg'] as num).toStringAsFixed(2)} kg',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_emissionData!['category']}  •  '
                                    '${(_emissionData!['emission_factor_kg_per_km'] as num).toStringAsFixed(3)} kg/km',
                                    style: TextStyle(
                                      color: Colors.orange.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Air Quality (AQI) card
                    if (_aqiData != null && _polylines.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Builder(builder: (context) {
                        final aqi = _aqiData!['aqi'] as int;
                        final aqiColor =
                            _hexColor(_aqiData!['color'] as String);
                        final aqiCat =
                            _aqiData!['category'] as String;
                        final aqiDesc =
                            _aqiData!['description'] as String? ?? '';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: aqiColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: aqiColor.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: aqiColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$aqi',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.air,
                                            size: 14,
                                            color: Colors.blueGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Air Quality: $aqiCat',
                                          style: TextStyle(
                                            color: aqiColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (aqiDesc.isNotEmpty)
                                      Text(
                                        aqiDesc,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    // Route error
                    if (_routeError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _routeError!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator (initial location fetch)
          if (_isLoading)
            Container(
              color:
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),

          // Location error message
          if (_error != null && !_isLoading)
            Positioned(
              top: 280,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

/// Horizontal scrollable chip row for selecting a vehicle type.
class _VehicleSelector extends StatelessWidget {
  final List<Map<String, dynamic>> vehicleTypes;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isDark;

  const _VehicleSelector({
    required this.vehicleTypes,
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vehicleTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final vt = vehicleTypes[i];
              final isSelected = vt['id'] == selected;
              return GestureDetector(
                onTap: () => onSelected(vt['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : (isDark
                            ? AppTheme.surfaceDark
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vt['icon'] as IconData,
                        size: 14,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? Colors.white70 : Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vt['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.black
                              : (isDark
                                  ? Colors.white70
                                  : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Search bar with autocomplete dropdown.
class _SearchBarWithSuggestions extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final List<String> suggestions;
  final bool showSuggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSuggestionTap;

  const _SearchBarWithSuggestions({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.suggestions,
    required this.showSuggestions,
    required this.onChanged,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: iconColor, size: 20),
            filled: true,
            fillColor: isDark ? AppTheme.surfaceDark : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
            ),
          ),
        ),
        if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length > 5 ? 5 : suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () => onSuggestionTap(suggestions[i]),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined,
                            color: Colors.grey[500], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestions[i],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
