import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 15️⃣ Green Route Recommendation Page
class GreenRouteScreen extends StatelessWidget {
  const GreenRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Green Routes', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Choose your route', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildRouteOption(context, 'Eco-Optimized Route', '12 min', '2.5 mi', '1.2 kg CO₂', recommended: true),
          const SizedBox(height: 16),
          _buildRouteOption(context, 'Fastest Route', '10 min', '3.1 mi', '2.1 kg CO₂'),
          const SizedBox(height: 16),
          _buildRouteOption(context, 'Scenic Route', '15 min', '2.8 mi', '1.5 kg CO₂'),
        ],
      ),
    );
  }

  Widget _buildRouteOption(BuildContext context, String title, String time, String distance, String carbon, {bool recommended = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: recommended ? AppTheme.primaryGreen : (isDark ? Colors.white : Colors.black).withOpacity(0.1), width: recommended ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.route, color: recommended ? AppTheme.primaryGreen : Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    if (recommended) const Text('Most eco-friendly', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric(FontAwesomeIcons.clock, time),
              const SizedBox(width: 16),
              _buildMetric(FontAwesomeIcons.route, distance),
              const SizedBox(width: 16),
              _buildMetric(FontAwesomeIcons.leaf, carbon),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 14),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}
