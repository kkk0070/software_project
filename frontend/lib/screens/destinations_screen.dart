import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  String selectedCategory = 'All';
  
  final List<String> categories = [
    'All',
    'Beach',
    'Mountains',
    'Cities',
    'Nature',
    'Historical',
  ];

  final List<Map<String, String>> destinations = [
    {'name': 'Santorini', 'country': 'Greece', 'category': 'Beach', 'activities': '120+', 'eco': '⭐ 4.8'},
    {'name': 'Tokyo', 'country': 'Japan', 'category': 'Cities', 'activities': '250+', 'eco': '🌿 Green'},
    {'name': 'New York', 'country': 'USA', 'category': 'Cities', 'activities': '300+', 'eco': '⭐ 4.5'},
    {'name': 'Barcelona', 'country': 'Spain', 'category': 'Cities', 'activities': '180+', 'eco': '⭐ 4.6'},
    {'name': 'Dubai', 'country': 'UAE', 'category': 'Cities', 'activities': '200+', 'eco': '⭐ 4.4'},
    {'name': 'Maldives', 'country': 'Asia', 'category': 'Beach', 'activities': '90+', 'eco': '🌿 Green'},
    {'name': 'Swiss Alps', 'country': 'Switzerland', 'category': 'Mountains', 'activities': '150+', 'eco': '♻️ Carbon Neutral'},
    {'name': 'Iceland', 'country': 'Nordic', 'category': 'Nature', 'activities': '110+', 'eco': '♻️ Carbon Neutral'},
    {'name': 'Bali', 'country': 'Indonesia', 'category': 'Beach', 'activities': '140+', 'eco': '⭐ 4.7'},
    {'name': 'Rome', 'country': 'Italy', 'category': 'Historical', 'activities': '220+', 'eco': '⭐ 4.5'},
    {'name': 'Paris', 'country': 'France', 'category': 'Cities', 'activities': '280+', 'eco': '⭐ 4.8'},
    {'name': 'Kyoto', 'country': 'Japan', 'category': 'Historical', 'activities': '160+', 'eco': '🌿 Green'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final filteredDestinations = selectedCategory == 'All'
        ? destinations
        : destinations.where((d) => d['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Popular Destinations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          FadeInDown(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = categories[index] == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? theme.primaryColor : theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Destinations grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredDestinations.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * (index % 6)),
                  child: _buildDestinationCard(filteredDestinations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, String> destination) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Placeholder for image
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.landscape,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination['country']!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${destination['activities']} Activities',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ecoGold.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          destination['eco']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
