import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  String selectedCuisine = 'All';
  bool showVeganOnly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Restaurants & Dining',
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
          _buildSearchBar(),
          _buildVeganToggle(),
          _buildCuisineFilters(),
          Expanded(
            child: _buildRestaurantsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.cardColor,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search restaurants, cuisines...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.mic),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVeganToggle() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.successGreen, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.leaf,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vegan & Organic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Plant-based & sustainable dining',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: showVeganOnly,
              onChanged: (value) {
                setState(() {
                  showVeganOnly = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineFilters() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildCuisineChip('All', '🌍'),
            _buildCuisineChip('Italian', '🍕'),
            _buildCuisineChip('Asian', '🍜'),
            _buildCuisineChip('Mexican', '🌮'),
            _buildCuisineChip('Indian', '🍛'),
            _buildCuisineChip('French', '🥐'),
            _buildCuisineChip('Vegan', '🥗'),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineChip(String label, String emoji) {
    final theme = Theme.of(context);
    final isSelected = selectedCuisine == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedCuisine = label;
          });
        },
        selectedColor: AppTheme.foodOrange.withOpacity(0.2),
        checkmarkColor: AppTheme.foodOrange,
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildRestaurantCard(index);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(int index) {
    final theme = Theme.of(context);
    final restaurants = [
      {
        'name': 'Green Garden Bistro',
        'cuisine': 'Vegan',
        'location': 'Downtown',
        'rating': '4.8',
        'reviews': '234',
        'price': '€€',
        'distance': '0.8 km',
        'isVegan': true,
        'isOrganic': true,
        'tags': ['Vegan', 'Organic', 'Local'],
      },
      {
        'name': 'Pasta Paradise',
        'cuisine': 'Italian',
        'location': 'City Center',
        'rating': '4.6',
        'reviews': '445',
        'price': '€€€',
        'distance': '1.2 km',
        'isVegan': false,
        'isOrganic': false,
        'tags': ['Italian', 'Pasta', 'Wine'],
      },
      {
        'name': 'Sushi Zen',
        'cuisine': 'Japanese',
        'location': 'East Side',
        'rating': '4.9',
        'reviews': '678',
        'price': '€€€€',
        'distance': '2.1 km',
        'isVegan': false,
        'isOrganic': true,
        'tags': ['Sushi', 'Fresh Fish', 'Premium'],
      },
      {
        'name': 'Eco Eats',
        'cuisine': 'International',
        'location': 'Green District',
        'rating': '4.7',
        'reviews': '312',
        'price': '€€',
        'distance': '1.5 km',
        'isVegan': true,
        'isOrganic': true,
        'tags': ['Vegan', 'Organic', 'Farm-to-table'],
      },
      {
        'name': 'Taco Fiesta',
        'cuisine': 'Mexican',
        'location': 'South Plaza',
        'rating': '4.5',
        'reviews': '289',
        'price': '€',
        'distance': '0.5 km',
        'isVegan': false,
        'isOrganic': false,
        'tags': ['Mexican', 'Spicy', 'Tacos'],
      },
      {
        'name': 'Spice Route',
        'cuisine': 'Indian',
        'location': 'Little India',
        'rating': '4.8',
        'reviews': '523',
        'price': '€€',
        'distance': '1.8 km',
        'isVegan': false,
        'isOrganic': false,
        'tags': ['Curry', 'Spicy', 'Authentic'],
      },
      {
        'name': 'Farm Fresh Cafe',
        'cuisine': 'Organic',
        'location': 'Farmers Market',
        'rating': '4.9',
        'reviews': '156',
        'price': '€€',
        'distance': '2.3 km',
        'isVegan': true,
        'isOrganic': true,
        'tags': ['Organic', 'Local', 'Seasonal'],
      },
      {
        'name': 'Mediterranean Delights',
        'cuisine': 'Mediterranean',
        'location': 'Harbor View',
        'rating': '4.7',
        'reviews': '398',
        'price': '€€€',
        'distance': '1.1 km',
        'isVegan': false,
        'isOrganic': false,
        'tags': ['Mediterranean', 'Seafood', 'Healthy'],
      },
    ];

    final restaurant = restaurants[index % restaurants.length];
    final isVegan = restaurant['isVegan'] as bool;

    if (showVeganOnly && !isVegan) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          child: Row(
            children: [
              // Restaurant Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.utensils,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Restaurant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (isVegan || (restaurant['isOrganic'] as bool))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: AppTheme.successGreen,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          restaurant['cuisine'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        Text(' • ',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                        Text(
                          restaurant['price'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(' • ',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        Text(
                          restaurant['distance'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.foodOrange,
                            borderRadius: BorderRadius.circular(6),
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
                                restaurant['rating'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${restaurant['reviews']} reviews)',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (restaurant['tags'] as List<String>)
                          .take(3)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
