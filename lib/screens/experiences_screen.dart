import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Experiences & Activities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilters(),
          Expanded(
            child: _buildExperiencesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.experienceGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover Adventures',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unique local experiences and activities',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search experiences...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildFilterChip('All', Icons.apps),
            _buildFilterChip('Adventure', Icons.hiking),
            _buildFilterChip('Cultural', Icons.museum),
            _buildFilterChip('Nature', Icons.park),
            _buildFilterChip('Water Sports', Icons.surfing),
            _buildFilterChip('Food & Wine', Icons.wine_bar),
            _buildFilterChip('Wellness', Icons.spa),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.experienceRed : (isDark ? Colors.white70 : theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedCategory = label;
          });
        },
        selectedColor: AppTheme.experienceRed.withOpacity(0.2),
        checkmarkColor: AppTheme.experienceRed,
      ),
    );
  }

  Widget _buildExperiencesList() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          return _buildExperienceCard(index);
        },
      ),
    );
  }

  Widget _buildExperienceCard(int index) {
    final theme = Theme.of(context);
    final experiences = [
      {
        'title': 'Mountain Hiking Tour',
        'location': 'Swiss Alps',
        'duration': '6 hours',
        'price': '€89',
        'rating': '4.9',
        'reviews': '234',
        'category': 'Adventure',
        'isEcoFriendly': true,
      },
      {
        'title': 'Wine Tasting Experience',
        'location': 'Tuscany',
        'duration': '4 hours',
        'price': '€120',
        'rating': '4.8',
        'reviews': '567',
        'category': 'Food & Wine',
        'isEcoFriendly': false,
      },
      {
        'title': 'Cultural City Walk',
        'location': 'Kyoto',
        'duration': '3 hours',
        'price': '¥8000',
        'rating': '4.7',
        'reviews': '189',
        'category': 'Cultural',
        'isEcoFriendly': true,
      },
      {
        'title': 'Scuba Diving',
        'location': 'Maldives',
        'duration': '5 hours',
        'price': '\$150',
        'rating': '4.9',
        'reviews': '412',
        'category': 'Water Sports',
        'isEcoFriendly': true,
      },
      {
        'title': 'Yoga & Meditation',
        'location': 'Bali',
        'duration': '2 hours',
        'price': '\$45',
        'rating': '4.8',
        'reviews': '298',
        'category': 'Wellness',
        'isEcoFriendly': true,
      },
      {
        'title': 'Safari Adventure',
        'location': 'Kenya',
        'duration': '8 hours',
        'price': '\$200',
        'rating': '5.0',
        'reviews': '523',
        'category': 'Nature',
        'isEcoFriendly': true,
      },
      {
        'title': 'Cooking Class',
        'location': 'Bangkok',
        'duration': '3 hours',
        'price': '฿2500',
        'rating': '4.7',
        'reviews': '334',
        'category': 'Food & Wine',
        'isEcoFriendly': false,
      },
      {
        'title': 'Paragliding',
        'location': 'Interlaken',
        'duration': '2 hours',
        'price': 'CHF180',
        'rating': '4.9',
        'reviews': '267',
        'category': 'Adventure',
        'isEcoFriendly': false,
      },
      {
        'title': 'Art Museum Tour',
        'location': 'Paris',
        'duration': '4 hours',
        'price': '€75',
        'rating': '4.6',
        'reviews': '445',
        'category': 'Cultural',
        'isEcoFriendly': true,
      },
      {
        'title': 'Rainforest Trek',
        'location': 'Costa Rica',
        'duration': '7 hours',
        'price': '\$110',
        'rating': '4.8',
        'reviews': '378',
        'category': 'Nature',
        'isEcoFriendly': true,
      },
      {
        'title': 'Surfing Lessons',
        'location': 'Bali',
        'duration': '3 hours',
        'price': '\$65',
        'rating': '4.7',
        'reviews': '456',
        'category': 'Water Sports',
        'isEcoFriendly': false,
      },
      {
        'title': 'Spa Day',
        'location': 'Iceland',
        'duration': '5 hours',
        'price': 'kr25000',
        'rating': '4.9',
        'reviews': '289',
        'category': 'Wellness',
        'isEcoFriendly': true,
      },
    ];

    final experience = experiences[index % experiences.length];
    final isEcoFriendly = experience['isEcoFriendly'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.compass,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isEcoFriendly)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.experienceRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        experience['rating'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          experience['location'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        experience['duration'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        experience['price'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.experienceRed,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.experienceRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
