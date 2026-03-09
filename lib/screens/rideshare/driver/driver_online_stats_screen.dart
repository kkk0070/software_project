import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

class DriverOnlineStatsScreen extends StatefulWidget {
  const DriverOnlineStatsScreen({super.key});

  @override
  State<DriverOnlineStatsScreen> createState() => _DriverOnlineStatsScreenState();
}

class _DriverOnlineStatsScreenState extends State<DriverOnlineStatsScreen> {
  String _selectedFilter = 'This Week';
  String _selectedMonth = 'October 2023';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          ),
        ),
        title: Text(
          'Online Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            color: AppTheme.primaryGreen,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            color: AppTheme.primaryGreen,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Online Time Card
            _buildTotalOnlineCard(),

            const SizedBox(height: 16),

            // Stats Row
            _buildStatsRow(),

            const SizedBox(height: 20),

            // Filter Buttons
            _buildFilterButtons(),

            const SizedBox(height: 20),

            // Daily Activity Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _selectedMonth,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Activity History List
            _buildActivityHistoryList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalOnlineCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [const Color(0xFF1a3a25), const Color(0xFF0f2817)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isDark ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL ONLINE TIME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '42h 35m',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '+8%',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'vs last week',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'AVG DAILY',
                value: '6h 20m',
                icon: Icons.access_time,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'PEAK HOURS',
                value: '8-10 AM',
                icon: Icons.local_fire_department,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a3a25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isDark ? 0.2 : 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = ['This Week', 'This Month', 'Last 3 Months'];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(filters.length, (index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;

            return Padding(
              padding: EdgeInsets.only(
                right: index < filters.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(20),
                    border: !isSelected
                        ? Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[400]!, width: 1)
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActivityHistoryList() {
    final activities = [
      {
        'date': 'MONDAY, OCT 23',
        'title': 'Morning & Afternoon',
        'time': '6h 35m online',
        'sessions': [
          {'period': 'Morning Session', 'time': '6:00 AM - 10:30 AM', 'duration': '4h 30m'},
          {'period': 'Afternoon Session', 'time': '2:00 PM - 4:05 PM', 'duration': '2h 5m'},
        ],
        'trips': '15 trips',
        'breaks': '45m',
      },
      {
        'date': 'SUNDAY, OCT 22',
        'title': 'Full Day',
        'time': '10h 15m online',
        'trips': '22 trips',
        'breaks': '1h 20m',
      },
      {
        'date': 'SATURDAY, OCT 21',
        'title': 'Evening Shift',
        'time': '6h 45m online',
        'trips': '12 trips',
        'breaks': '30m',
      },
    ];

    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        return FadeInUp(
          delay: Duration(milliseconds: 300 + (index * 100)),
          child: _buildActivityCard(activity),
        );
      }),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a3a25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(isDark ? 0.1 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['date'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.route,
                              size: 12,
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity['trips'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.coffee_outlined,
                              size: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity['breaks'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sessions list (if available)
          if (activity['sessions'] != null)
            _buildSessionsList(activity['sessions'] as List<Map<String, String>>),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<Map<String, String>> sessions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(sessions.length, (index) {
        final session = sessions[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0f2817) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppTheme.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['period'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session['time'] ?? '',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                session['duration'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
