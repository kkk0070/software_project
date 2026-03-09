import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';
import 'rewards_screen.dart';
import 'green_route_screen.dart';

/// 14️⃣ Sustainability Dashboard (User)
class SustainabilityDashboardScreen extends StatelessWidget {
  const SustainabilityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Your Impact', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(context),
            const SizedBox(height: 24),
            _buildCarbonChart(context),
            const SizedBox(height: 24),
            _buildStatGrid(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF00A344)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.leaf, color: Colors.black, size: 24),
              const SizedBox(width: 12),
              const Text('Eco Score', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('850', style: TextStyle(color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold)),
          Text('Top 10% of riders', style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCarbonChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Carbon Saved (Last 7 Days)', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2), const FlSpot(1, 3), const FlSpot(2, 1.5),
                      const FlSpot(3, 4), const FlSpot(4, 3.5), const FlSpot(5, 5), const FlSpot(6, 4.5),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryGreen.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, '28', 'Total Rides', FontAwesomeIcons.car)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, '42kg', 'CO₂ Saved', FontAwesomeIcons.leaf)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionButton(context, 'View Rewards', FontAwesomeIcons.trophy, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsScreen()));
        }),
        const SizedBox(height: 12),
        _buildActionButton(context, 'Green Routes', FontAwesomeIcons.route, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GreenRouteScreen()));
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
