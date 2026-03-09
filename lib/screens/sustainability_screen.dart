import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SustainabilityScreen extends StatelessWidget {
  const SustainabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sustainability Impact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share impact
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Impact Summary
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  gradient: AppTheme.ecoGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.earthAmericas,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Carbon Impact',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '45.8 kg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'CO₂ saved this year',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ImpactMetric(
                            icon: FontAwesomeIcons.tree,
                            value: '5',
                            label: 'Trees\nEquivalent',
                          ),
                          _ImpactMetric(
                            icon: FontAwesomeIcons.route,
                            value: '350',
                            label: 'km\nShared',
                          ),
                          _ImpactMetric(
                            icon: FontAwesomeIcons.fire,
                            value: '12',
                            label: 'Day\nStreak',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Trend Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly CO₂ Savings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: AppTheme.textLight.withOpacity(0.1),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}kg',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textLight,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                                        return Text(
                                          months[value.toInt()],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textLight,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 5,
                              minY: 0,
                              maxY: 10,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 3),
                                    FlSpot(1, 5),
                                    FlSpot(2, 4),
                                    FlSpot(3, 7),
                                    FlSpot(4, 6),
                                    FlSpot(5, 8),
                                  ],
                                  isCurved: true,
                                  color: AppTheme.primaryGreen,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.primaryGreen.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: const [
                    StatCard(
                      icon: FontAwesomeIcons.users,
                      title: 'Pooled Rides',
                      value: '24',
                      subtitle: 'This month',
                      color: AppTheme.accentBlue,
                    ),
                    StatCard(
                      icon: FontAwesomeIcons.award,
                      title: 'Eco Score',
                      value: '850',
                      subtitle: 'Top 15%',
                      color: AppTheme.warningOrange,
                    ),
                    StatCard(
                      icon: FontAwesomeIcons.seedling,
                      title: 'Green Rides',
                      value: '32',
                      subtitle: 'All time',
                      color: AppTheme.successGreen,
                    ),
                    StatCard(
                      icon: FontAwesomeIcons.coins,
                      title: 'Money Saved',
                      value: '₹1,250',
                      subtitle: 'By pooling',
                      color: AppTheme.primaryGreen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: const Column(
                      children: [
                        AchievementBadge(
                          icon: FontAwesomeIcons.trophy,
                          title: 'First Pool',
                          description: 'Completed your first pooled ride',
                          isUnlocked: true,
                        ),
                        AchievementBadge(
                          icon: FontAwesomeIcons.star,
                          title: 'Eco Warrior',
                          description: 'Saved 50kg of CO₂',
                          isUnlocked: false,
                        ),
                        AchievementBadge(
                          icon: FontAwesomeIcons.fire,
                          title: 'Week Streak',
                          description: '7 day pooling streak',
                          isUnlocked: true,
                        ),
                        AchievementBadge(
                          icon: FontAwesomeIcons.heartCircleCheck,
                          title: 'Community Hero',
                          description: '100 pooled rides',
                          isUnlocked: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comparison Section
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentBlue.withOpacity(0.1),
                      AppTheme.primaryGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Impact vs Average User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ComparisonItem(
                          label: 'You',
                          value: '45.8 kg',
                          icon: FontAwesomeIcons.user,
                          color: AppTheme.primaryGreen,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: AppTheme.textLight,
                        ),
                        _ComparisonItem(
                          label: 'Average',
                          value: '28.5 kg',
                          icon: FontAwesomeIcons.users,
                          color: AppTheme.accentBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You\'re saving 60% more CO₂ than average! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaIcon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ComparisonItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
