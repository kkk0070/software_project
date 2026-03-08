import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ride_service.dart';
import '../../../services/storage_service.dart';

class RidesHistoryScreen extends StatefulWidget {
  const RidesHistoryScreen({super.key});

  @override
  State<RidesHistoryScreen> createState() => _RidesHistoryScreenState();
}

class _RidesHistoryScreenState extends State<RidesHistoryScreen> {
  List<Map<String, dynamic>> _rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      final result = await RideService.getRides(
        riderId: userId.toString(), // Might need to check role later, assumed rider for now
        status: 'Completed',
      );
      
      if (result['success'] == true && result['data'] != null) {
        if (mounted) {
          setState(() {
            _rides = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Export rides history as CSV and copy to clipboard
  void _downloadHistory() {
    if (_rides.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ride history to export'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('Date,From,To,Driver,Fare,Rating,Status');
    for (final ride in _rides) {
      buffer.writeln(
        '"${ride['date']}","${ride['from']}","${ride['to']}",'
        '"${ride['driver']}","${ride['fare']}","${ride['rating']}","${ride['status']}"',
      );
    }
    final csvContent = buffer.toString();

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csvContent)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride history copied to clipboard as CSV'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Ride History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download History',
            onPressed: _downloadHistory,
            color: colorScheme.primary,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _rides.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rides.length,
                  itemBuilder: (context, index) {
                    final ride = _rides[index];
                    return _buildRideCard(context, ride);
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.clockRotateLeft,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No rides yet',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ride history will appear here',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
    final rating = ride['rating'] ?? 5.0;
    final fare = ride['fare'] != null ? double.tryParse(ride['fare'].toString()) ?? 0.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.locationDot,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  from,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.flagCheckered,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  to,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
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
                  Icon(
                    FontAwesomeIcons.user,
                    color: colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    driverName,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${fare.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
