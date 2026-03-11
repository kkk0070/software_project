import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/ride_service.dart';
import '../../../theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DownloadedMapsScreen extends StatefulWidget {
  const DownloadedMapsScreen({super.key});

  @override
  State<DownloadedMapsScreen> createState() => _DownloadedMapsScreenState();
}

class _DownloadedMapsScreenState extends State<DownloadedMapsScreen> {
  bool _isLoading = true;
  List<dynamic> _maps = [];

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    setState(() => _isLoading = true);
    final res = await RideService.getDownloadedMaps();
    if (res['success'] == true && res['data'] != null) {
      _maps = res['data'];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteMap(int mapId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Map'),
        content: const Text('Are you sure you want to delete this downloaded map?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await RideService.deleteDownloadedMap(mapId);
      _loadMaps();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Maps'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _maps.isEmpty
              ? const Center(child: Text('No downloaded maps available. Maps might have expired.'))
              : ListView.builder(
                  itemCount: _maps.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final mapData = _maps[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: ${mapData['pickup'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('To: ${mapData['dropoff'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Expires: ${DateTime.parse(mapData['expires_at']).toLocal()}'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMap(mapData['id']),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final encoded = mapData['encoded_polyline'];
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => _MapViewerScreen(encodedPolyline: encoded)));
                                  },
                                  child: const Text('View Map'),
                                ),
                              ],
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

class _MapViewerScreen extends StatelessWidget {
  final String encodedPolyline;

  const _MapViewerScreen({required this.encodedPolyline});

  @override
  Widget build(BuildContext context) {
    List<LatLng> points = [];
    try {
      final list = jsonDecode(encodedPolyline) as List;
      points = list.map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble())).toList();
    } catch (e) {
      // Decode error
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Map View')),
      body: points.isEmpty
          ? const Center(child: Text('Invalid map data'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: points.isNotEmpty ? points[0] : const LatLng(0, 0),
                zoom: 14,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: points,
                  color: AppTheme.primaryGreen,
                  width: 5,
                )
              },
            ),
    );
  }
}
