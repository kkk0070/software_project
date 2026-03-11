import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ride_service.dart';

class CarpoolDetailsScreen extends StatefulWidget {
  final int carpoolId;

  const CarpoolDetailsScreen({super.key, required this.carpoolId});

  @override
  State<CarpoolDetailsScreen> createState() => _CarpoolDetailsScreenState();
}

class _CarpoolDetailsScreenState extends State<CarpoolDetailsScreen> {
  GoogleMapController? _mapController;
  Map<String, dynamic>? _carpoolData;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Simulation state
  int _currentStopIndex = 0; // 0 = picking up 1st user, 1 = 2nd, etc.
  bool _tripCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCarpoolDetails();
  }

  Future<void> _loadCarpoolDetails() async {
    final result = await RideService.getCarpoolDetails(widget.carpoolId);
    if (result['success'] == true) {
      if (mounted) {
        setState(() {
          _carpoolData = result['data'];
          _isLoading = false;
        });
        _updateMap();
      }
    }
  }

  void _updateMap() {
    if (_carpoolData == null) return;
    final List<Map<String, dynamic>> participants = (_carpoolData!['participants'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [];
    final markers = <Marker>{};
    final List<LatLng> polylinePoints = [];

    // Driver location (mocked as start of "From" area)
    final LatLng driverLoc = const LatLng(12.9716, 77.5946); // Bangalore Center
    markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: driverLoc,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: 'Driver Location'),
    ));
    polylinePoints.add(driverLoc);

    // Participant pickup points
    for (int i = 0; i < participants.length; i++) {
      final p = participants[i];
      
      // Since backend doesn't provide real-time location yet, use mocked nearby locations
      final loc = p['location'] != null 
          ? LatLng(p['location']['lat'], p['location']['lng'])
          : LatLng(12.9716 + (i * 0.01), 77.5946 + (i * 0.01)); // Mocked nearby
          
      final hasReached = p['reached'] == true;

      markers.add(Marker(
        markerId: MarkerId('participant_$i'),
        position: loc,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          hasReached ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(title: 'Pickup: ${p['name']}'),
      ));
      
      // Only include points up to current stop + 1 (next target)
      if (i <= _currentStopIndex) {
        polylinePoints.add(loc);
      }
    }

    // Final destination
    final LatLng destLoc = const LatLng(12.9141, 77.6412); // Electronic City Area
    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: destLoc,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'Final Destination'),
    ));

    // If all participants reached, show polyline to destination
    bool allReached = participants.isEmpty || participants.every((p) => p['reached'] == true);
    if (allReached) {
      polylinePoints.add(destLoc);
    }

    setState(() {
      _markers = markers;
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: AppTheme.primaryGreen,
          width: 5,
        )
      };
    });

    if (_mapController != null && polylinePoints.isNotEmpty) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(polylinePoints.last));
    }
  }

  void _verifyOtp(int participantIndex) {
    if (_carpoolData == null) return;
    final List<Map<String, dynamic>> participants = (_carpoolData!['participants'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [];
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify OTP for ${participants[participantIndex]['name']}'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter 4-digit OTP'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (otpController.text == participants[participantIndex]['otp']) {
                Navigator.pop(context);
                _onParticipantReached(participantIndex);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid OTP'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _onParticipantReached(int index) {
    setState(() {
      _carpoolData!['participants'][index]['reached'] = true;
      if (_currentStopIndex < (_carpoolData!['participants'].length - 1)) {
        _currentStopIndex++;
      } else {
        _tripCompleted = true;
      }
    });
    _updateMap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_carpoolData!['participants'][index]['name']} Picked Up!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final List<Map<String, dynamic>> participants = (_carpoolData!['participants'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Carpool Details', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (c) => _mapController = c,
              initialCameraPosition: const CameraPosition(
                target: LatLng(12.9716, 77.5946),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
            ),
          ),
          
          // Details Panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _carpoolData!['creator'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${_carpoolData!['fare']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Route: ${_carpoolData!['from']} to ${_carpoolData!['to']}'),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _carpoolData!['status'] == 'Full' ? Colors.red.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _carpoolData!['status'] == 'Full' ? 'Full' : '${_carpoolData!['seats']} seats left',
                          style: TextStyle(
                            color: _carpoolData!['status'] == 'Full' ? Colors.red : AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        // Driver
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: _carpoolData!['creator_photo'] != null 
                                ? NetworkImage(_carpoolData!['creator_photo'])
                                : null,
                            backgroundColor: AppTheme.primaryGreen,
                            child: _carpoolData!['creator_photo'] == null 
                                ? const Icon(Icons.drive_eta, color: Colors.black, size: 20)
                                : null,
                          ),
                          title: Text('${_carpoolData!['creator']} (Driver)', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Organizer'),
                          trailing: const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 20),
                        ),
                        ...participants.map((p) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: p['photo'] != null ? NetworkImage(p['photo']) : null,
                              backgroundColor: Colors.grey[300],
                              child: p['photo'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
                            ),
                            title: Text(p['name']),
                            subtitle: const Text('Joined Carpool'),
                            trailing: p['is_me'] == true 
                                ? const Text('You', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold))
                                : null,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  if (_tripCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryGreen),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.flagCheckered, color: AppTheme.primaryGreen),
                            SizedBox(width: 12),
                            Text('Everyone picked up! Heading to destination.', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
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
}
