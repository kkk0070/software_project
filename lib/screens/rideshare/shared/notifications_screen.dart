import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 17️⃣ Notifications Page
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Notifications', style: TextStyle(color: colorScheme.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(context, 'Ride Completed', 'Your ride to Office has been completed. Rate your experience!', FontAwesomeIcons.circleCheck, colorScheme.primary, '2 min ago'),
          _buildNotificationCard(context, 'Eco Milestone', 'Congratulations! You\'ve saved 50kg of CO₂ this month!', FontAwesomeIcons.leaf, colorScheme.primary, '1 hour ago'),
          _buildNotificationCard(context, 'Driver Arriving', 'Your driver is 2 minutes away', FontAwesomeIcons.car, colorScheme.secondary, '3 hours ago'),
          _buildNotificationCard(context, 'Safety Alert', 'Remember to wear your seatbelt', FontAwesomeIcons.shield, colorScheme.tertiary, '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, String title, String message, IconData icon, Color color, String time) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outline.withOpacity(0.1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
