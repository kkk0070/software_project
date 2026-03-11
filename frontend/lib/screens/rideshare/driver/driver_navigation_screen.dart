import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ride_service.dart';

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

enum NavigationPhase { toPickup, atPickup, inTrip, completed }

class DriverNavigationScreen extends StatefulWidget {
  final int rideId;
  final String riderName;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;

  const DriverNavigationScreen({
    super.key,
    required this.rideId,
    required this.riderName,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  NavigationPhase _phase = NavigationPhase.toPickup;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _driverLocation;
  StreamSubscription<Position>? _positionStream;
  bool _isLoading = true;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Mock location if real one fails
      _setMockLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setMockLocation();
        return;
      }
    }

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _driverLocation = LatLng(position.latitude, position.longitude);
          if (_isLoading) {
            _isLoading = false;
            _updateMapContents();
          }
        });
      }
    });
  }

  void _setMockLocation() {
    setState(() {
      // Somewhere near Coimbatore for testing
      _driverLocation = LatLng(11.0168, 76.9558);
      _isLoading = false;
      _updateMapContents();
    });
  }

  Future<void> _updateMapContents() async {
    if (_driverLocation == null) return;

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    if (_phase == NavigationPhase.toPickup) {
      // Marker for driver
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You (Driver)'),
      ));
      // Marker for pickup
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup: ${widget.riderName}'),
      ));

      // Draw polyline from driver to pickup
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverLocation!, widget.pickupLocation],
        color: Colors.blue,
        width: 5,
      ));
    } else if (_phase == NavigationPhase.inTrip) {
      // Marker for driver (now with rider)
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      // Marker for destination
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: widget.dropoffLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ));

      // Draw polyline to destination
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverLocation!, widget.dropoffLocation],
        color: AppTheme.primaryGreen,
        width: 5,
      ));
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });

    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null || _driverLocation == null) return;

    LatLngBounds bounds;
    if (_phase == NavigationPhase.toPickup) {
      bounds = _getBounds(_driverLocation!, widget.pickupLocation);
    } else {
      bounds = _getBounds(_driverLocation!, widget.dropoffLocation);
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _getBounds(LatLng p1, LatLng p2) {
    return LatLngBounds(
      southwest: LatLng(
        math.min(p1.latitude, p2.latitude),
        math.min(p1.longitude, p2.longitude),
      ),
      northeast: LatLng(
        math.max(p1.latitude, p2.latitude),
        math.max(p1.longitude, p2.longitude),
      ),
    );
  }

  Future<void> _handleArrived() async {
    setState(() => _isLoading = true);
    final res = await RideService.arriveAtPickup(widget.rideId);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      setState(() {
        _phase = NavigationPhase.atPickup;
      });
      _showOtpDialog();
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Rider OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ask the rider for their 4-digit security code.'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              onChanged: (val) => _otpValue = val,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_otpValue.length == 4) {
                Navigator.pop(context);
                _verifyOtp();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Verify & Start Trip'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final res = await RideService.verifyOtp(widget.rideId, _otpValue);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      setState(() {
        _phase = NavigationPhase.inTrip;
      });
      _updateMapContents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Invalid OTP'), backgroundColor: Colors.red),
      );
      _showOtpDialog();
    }
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);
    final res = await RideService.completeRide(widget.rideId);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      setState(() => _phase = NavigationPhase.completed);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ride Completed'),
          content: const Text('Payment has been processed. Great job!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Back to home
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) {
              _mapController = c;
              if (Theme.of(context).brightness == Brightness.dark) {
                c.setMapStyle(_kNavDarkMapStyle);
              }
              _fitBounds();
            },
            initialCameraPosition: CameraPosition(
              target: widget.pickupLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          
          // Header info
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.riderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          _phase == NavigationPhase.toPickup ? 'Picking up from ${widget.pickupAddress}' : 'Dropping off at ${widget.dropoffAddress}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_phase == NavigationPhase.toPickup)
                  _buildActionButton('Arrived at Pickup', _handleArrived, Colors.blue),
                if (_phase == NavigationPhase.atPickup)
                  _buildActionButton('Enter OTP', _showOtpDialog, AppTheme.primaryGreen),
                if (_phase == NavigationPhase.inTrip)
                  _buildActionButton('Complete Ride', _handleComplete, AppTheme.primaryGreen),
              ],
            ),
          ),

          if (_isLoading)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
