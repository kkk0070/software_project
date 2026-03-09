import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildNotificationCard(
              context,
              'Booking Confirmed',
              'Your hotel booking in Paris has been confirmed',
              '2 hours ago',
              Icons.check_circle,
              AppTheme.successGreen,
              false,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildNotificationCard(
              context,
              'Special Offer',
              'Get 20% off on eco-friendly hotels this month!',
              '5 hours ago',
              Icons.local_offer,
              AppTheme.accentBlue,
              true,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildNotificationCard(
              context,
              'Eco Achievement Unlocked',
              'You\'ve saved 50kg of CO₂ this month! 🌿',
              '1 day ago',
              Icons.eco,
              AppTheme.primaryGreen,
              true,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildNotificationCard(
              context,
              'Trip Reminder',
              'Your trip to Tokyo starts in 3 days',
              '2 days ago',
              Icons.flight_takeoff,
              AppTheme.warningOrange,
              true,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: _buildNotificationCard(
              context,
              'New Review',
              'You have a new review on your recent trip',
              '3 days ago',
              Icons.star,
              Colors.amber.shade700,
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isRead,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead 
            ? (isDark ? AppTheme.cardDark : Colors.white)
            : AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? (isDark ? Colors.grey[800]! : Colors.grey.shade200) : AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
