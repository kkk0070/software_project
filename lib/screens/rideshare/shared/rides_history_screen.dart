import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

class RidesHistoryScreen extends StatefulWidget {
  const RidesHistoryScreen({super.key});

  @override
  State<RidesHistoryScreen> createState() => _RidesHistoryScreenState();
}

class _RidesHistoryScreenState extends State<RidesHistoryScreen> {
  // Sample data - replace with actual API call
  final List<Map<String, dynamic>> _rides = [
    {
      'id': 1,
      'date': '2024-01-15',
      'from': 'Downtown',
      'to': 'Airport',
      'fare': 45.00,
      'status': 'Completed',
      'driver': 'John Doe',
      'rating': 4.8,
    },
    {
      'id': 2,
      'date': '2024-01-10',
      'from': 'Home',
      'to': 'Office',
      'fare': 25.00,
      'status': 'Completed',
      'driver': 'Jane Smith',
      'rating': 5.0,
    },
  ];

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
      ),
      body: _rides.isEmpty
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
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
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
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Map<String, dynamic> ride) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ride['date'],
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ride['status'],
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
                  ride['from'],
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
                  ride['to'],
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
                    ride['driver'],
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
                    ride['rating'].toString(),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${ride['fare'].toStringAsFixed(2)}',
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
