import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  bool showEcoFriendlyOnly = false;
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hotels & Stays',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchSection(),
          
          // Eco Filter Toggle
          _buildEcoToggle(),
          
          // Category Filters
          _buildCategoryFilters(),
          
          // Hotels List
          Expanded(
            child: _buildHotelsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final theme = Theme.of(context);
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.cardColor,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Where are you going?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Check-in', '12 Dec'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('Check-out', '15 Dec'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('Guests', '2 Adults'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoToggle() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.ecoGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.eco,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eco-Friendly Hotels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Green certified & sustainable',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: showEcoFriendlyOnly,
              onChanged: (value) {
                setState(() {
                  showEcoFriendlyOnly = value;
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

  Widget _buildCategoryFilters() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 300),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip('All', Icons.apps),
            _buildFilterChip('Hotels', Icons.hotel),
            _buildFilterChip('Resorts', Icons.villa),
            _buildFilterChip('Hostels', Icons.bed),
            _buildFilterChip('Apartments', Icons.apartment),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.primaryColor : (isDark ? Colors.white70 : theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        selectedColor: theme.primaryColor.withOpacity(0.2),
        checkmarkColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildHotelsList() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildHotelCard(index);
        },
      ),
    );
  }

  Widget _buildHotelCard(int index) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hotels = [
      {
        'name': 'Green Oasis Hotel',
        'location': 'Downtown, Paris',
        'rating': '4.8',
        'reviews': '328',
        'price': '€120',
        'eco': true,
        'ecoRating': 'Gold',
        'amenities': ['WiFi', 'Pool', 'Spa'],
      },
      {
        'name': 'Eco Lodge Resort',
        'location': 'Mountain View, Switzerland',
        'rating': '4.9',
        'reviews': '512',
        'price': '€180',
        'eco': true,
        'ecoRating': 'Gold',
        'amenities': ['Breakfast', 'Gym', 'Restaurant'],
      },
      {
        'name': 'Urban Comfort Inn',
        'location': 'City Center, Tokyo',
        'rating': '4.5',
        'reviews': '234',
        'price': '€95',
        'eco': false,
        'ecoRating': 'None',
        'amenities': ['WiFi', 'Parking', 'AC'],
      },
      {
        'name': 'Sustainable Stays',
        'location': 'Beach Front, Bali',
        'rating': '4.7',
        'reviews': '445',
        'price': '€150',
        'eco': true,
        'ecoRating': 'Silver',
        'amenities': ['Beach Access', 'Pool', 'Breakfast'],
      },
      {
        'name': 'Grand Plaza Hotel',
        'location': 'Business District, Dubai',
        'rating': '4.6',
        'reviews': '892',
        'price': '€200',
        'eco': false,
        'ecoRating': 'None',
        'amenities': ['Spa', 'Restaurant', 'Bar'],
      },
      {
        'name': 'Nature\'s Retreat',
        'location': 'Countryside, Iceland',
        'rating': '4.9',
        'reviews': '156',
        'price': '€165',
        'eco': true,
        'ecoRating': 'Gold',
        'amenities': ['Hot Spring', 'Hiking', 'WiFi'],
      },
      {
        'name': 'Boutique Residence',
        'location': 'Historic Quarter, Rome',
        'rating': '4.4',
        'reviews': '267',
        'price': '€110',
        'eco': false,
        'ecoRating': 'Bronze',
        'amenities': ['WiFi', 'Breakfast', 'Tour Desk'],
      },
      {
        'name': 'Green Valley Hotel',
        'location': 'Rainforest, Costa Rica',
        'rating': '4.8',
        'reviews': '389',
        'price': '€140',
        'eco': true,
        'ecoRating': 'Gold',
        'amenities': ['Eco Tours', 'Wildlife', 'Restaurant'],
      },
    ];

    final hotel = hotels[index % hotels.length];
    final isEco = hotel['eco'] as bool;

    if (showEcoFriendlyOnly && !isEco) {
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
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.hotel,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isEco)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ecoGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel['ecoRating']} Eco',
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
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: theme.textTheme.bodyLarge?.color,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel['name'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
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
                            hotel['rating'] as String,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel['location'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${hotel['reviews']} reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: (hotel['amenities'] as List<String>)
                      .map((amenity) => Chip(
                            label: Text(
                              amenity,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
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
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        Text(
                          '${hotel['price']}/night',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
