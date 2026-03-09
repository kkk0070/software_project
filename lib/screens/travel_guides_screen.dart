import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class TravelGuidesScreen extends StatefulWidget {
  const TravelGuidesScreen({super.key});

  @override
  State<TravelGuidesScreen> createState() => _TravelGuidesScreenState();
}

class _TravelGuidesScreenState extends State<TravelGuidesScreen> {
  String selectedSpecialization = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Guides',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSpecializationFilters(),
          Expanded(
            child: _buildGuidesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Perfect Guide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Local experts ready to make your trip unforgettable',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by location or language...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationFilters() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildFilterChip('All', Icons.apps),
            _buildFilterChip('Historical', Icons.museum),
            _buildFilterChip('Adventure', Icons.hiking),
            _buildFilterChip('Cultural', Icons.theater_comedy),
            _buildFilterChip('Nature', Icons.park),
            _buildFilterChip('Food', Icons.restaurant),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = selectedSpecialization == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.guideGreen : AppTheme.textLight,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedSpecialization = label;
          });
        },
        selectedColor: AppTheme.guideGreen.withOpacity(0.2),
        checkmarkColor: AppTheme.guideGreen,
      ),
    );
  }

  Widget _buildGuidesList() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildGuideCard(index);
        },
      ),
    );
  }

  Widget _buildGuideCard(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final guides = [
      {
        'name': 'Maria Garcia',
        'location': 'Paris, France',
        'rating': '4.9',
        'reviews': '156',
        'price': '€80/day',
        'experience': '8 years',
        'languages': ['English', 'French', 'Spanish'],
        'specializations': ['Historical', 'Art', 'Food'],
        'certified': true,
        'bio': 'Passionate about Parisian history and art',
      },
      {
        'name': 'Kenji Tanaka',
        'location': 'Kyoto, Japan',
        'rating': '5.0',
        'reviews': '243',
        'price': '¥12000/day',
        'experience': '12 years',
        'languages': ['English', 'Japanese', 'Mandarin'],
        'specializations': ['Cultural', 'Temples', 'Tea Ceremony'],
        'certified': true,
        'bio': 'Traditional Japanese culture expert',
      },
      {
        'name': 'Alex Thompson',
        'location': 'Reykjavik, Iceland',
        'rating': '4.8',
        'reviews': '98',
        'price': 'kr15000/day',
        'experience': '5 years',
        'languages': ['English', 'Icelandic'],
        'specializations': ['Nature', 'Adventure', 'Photography'],
        'certified': true,
        'bio': 'Nature and adventure specialist',
      },
      {
        'name': 'Sofia Martinez',
        'location': 'Barcelona, Spain',
        'rating': '4.7',
        'reviews': '187',
        'price': '€75/day',
        'experience': '10 years',
        'languages': ['English', 'Spanish', 'Catalan'],
        'specializations': ['Architecture', 'Food', 'Nightlife'],
        'certified': true,
        'bio': 'Barcelona local with insider knowledge',
      },
      {
        'name': 'Raj Patel',
        'location': 'Jaipur, India',
        'rating': '4.9',
        'reviews': '312',
        'price': '₹4000/day',
        'experience': '15 years',
        'languages': ['English', 'Hindi', 'Rajasthani'],
        'specializations': ['Historical', 'Cultural', 'Palaces'],
        'certified': true,
        'bio': 'Expert in Rajasthani heritage',
      },
      {
        'name': 'Emma Wilson',
        'location': 'London, UK',
        'rating': '4.8',
        'reviews': '234',
        'price': '£90/day',
        'experience': '7 years',
        'languages': ['English', 'French'],
        'specializations': ['Historical', 'Museums', 'Royal Family'],
        'certified': true,
        'bio': 'British history and culture enthusiast',
      },
      {
        'name': 'Marco Rossi',
        'location': 'Rome, Italy',
        'rating': '4.9',
        'reviews': '289',
        'price': '€85/day',
        'experience': '11 years',
        'languages': ['English', 'Italian', 'German'],
        'specializations': ['Historical', 'Art', 'Food'],
        'certified': true,
        'bio': 'Ancient Rome and Italian cuisine expert',
      },
      {
        'name': 'Luna Santos',
        'location': 'Rio de Janeiro, Brazil',
        'rating': '4.8',
        'reviews': '145',
        'price': 'R\$350/day',
        'experience': '6 years',
        'languages': ['English', 'Portuguese', 'Spanish'],
        'specializations': ['Beach', 'Carnival', 'Nightlife'],
        'certified': false,
        'bio': 'Rio local with vibrant energy',
      },
    ];

    final guide = guides[index % guides.length];
    final isCertified = guide['certified'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Guide Photo
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.guideGreen.withOpacity(0.2),
                        child: Text(
                          (guide['name'] as String)[0],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.guideGreen,
                          ),
                        ),
                      ),
                      if (isCertified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.ecoGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Guide Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                guide['name'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.guideGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    guide['rating'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              guide['location'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              size: 14,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${guide['experience']} experience',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${guide['reviews']} reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Bio
              Text(
                guide['bio'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              
              // Languages
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.language,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: (guide['languages'] as List<String>)
                          .map((lang) => Chip(
                                label: Text(
                                  lang,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Specializations
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (guide['specializations'] as List<String>)
                    .map((spec) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.guideGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            spec,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.guideGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Price and Book Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting from',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        guide['price'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.guideGreen,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Book Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.guideGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
