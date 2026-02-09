import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 9️⃣ Route Optimization & Updates Page
class RouteOptimizationScreen extends StatelessWidget {
  const RouteOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Route Optimization',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAlertCard(
            context,
            'Traffic Ahead',
            'Heavy traffic on Market St. Rerouting suggested.',
            FontAwesomeIcons.triangleExclamation,
            AppTheme.warningOrange,
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            context,
            'Faster Route',
            'New route available, saves 3 minutes',
            FontAwesomeIcons.bolt,
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            context,
            'Pickup Sequence',
            'Optimized pickup order for pooled rides',
            FontAwesomeIcons.listCheck,
            AppTheme.accentBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'Current Route',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStopCard(context, '1', 'Pickup: John Doe', '123 Main St', true),
          const SizedBox(height: 12),
          _buildStopCard(
            context,
            '2',
            'Pickup: Jane Smith',
            '456 Oak Ave',
            false,
          ),
          const SizedBox(height: 12),
          _buildStopCard(
            context,
            '3',
            'Dropoff: Jane Smith',
            '789 Elm St',
            false,
          ),
          const SizedBox(height: 12),
          _buildStopCard(
            context,
            '4',
            'Dropoff: John Doe',
            '321 Pine Rd',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    String number,
    String title,
    String address,
    bool active,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primaryGreen.withOpacity(0.2)
            : (isDark ? AppTheme.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? AppTheme.primaryGreen
              : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.primaryGreen
                  : (isDark ? AppTheme.surfaceDark : Colors.grey[200]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: active
                      ? Colors.black
                      : (isDark ? Colors.white : AppTheme.textDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    color: active
                        ? AppTheme.primaryGreen
                        : (isDark ? Colors.white : AppTheme.textDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
