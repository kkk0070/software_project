import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String selectedTab = 'Your Reviews';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new review
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          FadeInDown(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 'Your Reviews';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 'Your Reviews'
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Your Reviews',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTab == 'Your Reviews'
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 'Received';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 'Received'
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Received',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTab == 'Received'
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reviews list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (selectedTab == 'Your Reviews') ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildReviewCard(
                      'Hotel Le Grand Paris',
                      'Excellent eco-friendly hotel with great amenities...',
                      5,
                      '2 weeks ago',
                      'Hotel',
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildReviewCard(
                      'Tokyo Sushi Restaurant',
                      'Amazing authentic Japanese cuisine, highly recommend...',
                      4,
                      '1 month ago',
                      'Restaurant',
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildReviewCard(
                      'Mountain Hiking Tour',
                      'Great experience with knowledgeable guide...',
                      5,
                      '2 months ago',
                      'Experience',
                    ),
                  ),
                ] else ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildReceivedReview(
                      'Sarah Johnson',
                      'Great travel companion, very organized and friendly!',
                      5,
                      '1 week ago',
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildReceivedReview(
                      'Mike Chen',
                      'Punctual and respectful traveler.',
                      4,
                      '3 weeks ago',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Write new review
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildReviewCard(
    String title,
    String review,
    int rating,
    String time,
    String category,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(category),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedReview(
    String name,
    String review,
    int rating,
    String time,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryGreen,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade700,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hotel':
        return AppTheme.hotelPurple;
      case 'Restaurant':
        return AppTheme.foodOrange;
      case 'Experience':
        return AppTheme.experienceRed;
      case 'Transport':
        return AppTheme.transportBlue;
      default:
        return AppTheme.primaryGreen;
    }
  }
}
