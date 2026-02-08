import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  bool showSamplePlan = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: showSamplePlan ? _buildSampleTrip() : _buildEmptyState(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            showSamplePlan = !showSamplePlan;
          });
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.mapLocationDot,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Planning Your Adventure',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Create a personalized itinerary with day-wise plans, activities, and budget tracking',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTrip() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripHeader(),
          const SizedBox(height: 16),
          _buildTripStats(),
          const SizedBox(height: 24),
          _buildDayPlans(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTripHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Day Paris Adventure',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.white70, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Dec 15 - Dec 22, 2024',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderStat('2', 'Travelers'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildHeaderStat('€2,450', 'Budget'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildHeaderStat('45 kg', 'CO₂ Est.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTripStats() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Accommodation',
                '€840',
                Icons.hotel,
                AppTheme.hotelPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Transport',
                '€650',
                Icons.flight,
                AppTheme.transportBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Activities',
                '€560',
                Icons.explore,
                AppTheme.experienceRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Daily Itinerary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDayCard(1, 'Arrival & City Exploration', [
          {'time': '10:00 AM', 'activity': 'Hotel Check-in', 'location': 'Le Marais Hotel', 'cost': '€0'},
          {'time': '12:00 PM', 'activity': 'Lunch at Local Bistro', 'location': 'Café de Flore', 'cost': '€45'},
          {'time': '02:00 PM', 'activity': 'Walking Tour', 'location': 'Historic Marais District', 'cost': '€25'},
          {'time': '06:00 PM', 'activity': 'Dinner & Rest', 'location': 'Hotel Area', 'cost': '€60'},
        ], '€130'),
        
        _buildDayCard(2, 'Iconic Landmarks', [
          {'time': '08:00 AM', 'activity': 'Breakfast', 'location': 'Local Café', 'cost': '€15'},
          {'time': '09:30 AM', 'activity': 'Eiffel Tower Visit', 'location': 'Champ de Mars', 'cost': '€35'},
          {'time': '01:00 PM', 'activity': 'Seine River Cruise', 'location': 'Bateaux Parisiens', 'cost': '€25'},
          {'time': '04:00 PM', 'activity': 'Louvre Museum', 'location': 'Musée du Louvre', 'cost': '€20'},
          {'time': '08:00 PM', 'activity': 'Dinner with View', 'location': 'Montmartre', 'cost': '€70'},
        ], '€165'),
        
        _buildDayCard(3, 'Art & Culture', [
          {'time': '09:00 AM', 'activity': 'Breakfast', 'location': 'Hotel', 'cost': '€12'},
          {'time': '10:30 AM', 'activity': 'Musée d\'Orsay', 'location': 'Orsay Museum', 'cost': '€16'},
          {'time': '02:00 PM', 'activity': 'Latin Quarter Lunch', 'location': 'Le Procope', 'cost': '€50'},
          {'time': '04:00 PM', 'activity': 'Notre-Dame Area', 'location': 'Île de la Cité', 'cost': '€0'},
          {'time': '07:00 PM', 'activity': 'French Cooking Class', 'location': 'Cooking School', 'cost': '€85'},
        ], '€163'),
        
        _buildDayCard(4, 'Day Trip to Versailles', [
          {'time': '08:00 AM', 'activity': 'Train to Versailles', 'location': 'RER C', 'cost': '€8'},
          {'time': '10:00 AM', 'activity': 'Palace of Versailles', 'location': 'Versailles', 'cost': '€20'},
          {'time': '01:00 PM', 'activity': 'Lunch at Versailles', 'location': 'Local Restaurant', 'cost': '€40'},
          {'time': '03:00 PM', 'activity': 'Gardens & Marie Antoinette\'s Estate', 'location': 'Versailles Gardens', 'cost': '€10'},
          {'time': '06:00 PM', 'activity': 'Return & Dinner', 'location': 'Paris', 'cost': '€55'},
        ], '€133'),
      ],
    );
  }

  Widget _buildDayCard(int day, String title, List<Map<String, String>> activities, String totalCost) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInUp(
      delay: Duration(milliseconds: 200 + (day * 50)),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(20),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Day\n$day',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    '${activities.length} activities',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.euro, size: 14, color: AppTheme.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    totalCost,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            children: [
              ...activities.map((activity) => _buildActivityItem(
                activity['time']!,
                activity['activity']!,
                activity['location']!,
                activity['cost']!,
              )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String time, String activity, String location, String cost) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
