import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Map<String, dynamic>> _checklistItems = [
    {'title': 'Passport', 'checked': true, 'category': 'Essential'},
    {'title': 'Visa Documents', 'checked': true, 'category': 'Essential'},
    {'title': 'Travel Insurance', 'checked': false, 'category': 'Essential'},
    {'title': 'Flight Tickets', 'checked': true, 'category': 'Travel'},
    {'title': 'Hotel Confirmations', 'checked': true, 'category': 'Travel'},
    {'title': 'Vaccination Certificate', 'checked': false, 'category': 'Health'},
    {'title': 'Emergency Contacts', 'checked': false, 'category': 'Safety'},
    {'title': 'Credit Cards', 'checked': true, 'category': 'Finance'},
    {'title': 'Local Currency', 'checked': false, 'category': 'Finance'},
    {'title': 'Phone Chargers', 'checked': false, 'category': 'Electronics'},
    {'title': 'Power Adapters', 'checked': false, 'category': 'Electronics'},
    {'title': 'Medications', 'checked': false, 'category': 'Health'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final completedCount = _checklistItems.where((item) => item['checked'] == true).length;
    final totalCount = _checklistItems.length;
    final progress = completedCount / totalCount;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        title: Text(
          'Travel Checklist',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
            onPressed: () {
              // Add new item
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress card
          FadeInDown(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount / $totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Checklist
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  child: _buildChecklistItem(_checklistItems[index], index, isDark),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add custom item
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item['checked'] 
              ? AppTheme.primaryGreen.withOpacity(0.3) 
              : (isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.grey.shade200),
        ),
      ),
      child: CheckboxListTile(
        value: item['checked'],
        onChanged: (bool? value) {
          setState(() {
            _checklistItems[index]['checked'] = value ?? false;
          });
        },
        title: Text(
          item['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
            decoration: item['checked'] ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item['category'],
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey.shade600,
            ),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(item['category']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item['category']),
            color: _getCategoryColor(item['category']),
            size: 20,
          ),
        ),
        activeColor: AppTheme.primaryGreen,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Essential':
        return Icons.star;
      case 'Travel':
        return Icons.flight;
      case 'Health':
        return Icons.health_and_safety;
      case 'Safety':
        return Icons.shield;
      case 'Finance':
        return Icons.account_balance_wallet;
      case 'Electronics':
        return Icons.electrical_services;
      default:
        return Icons.check_circle;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Essential':
        return AppTheme.errorRed;
      case 'Travel':
        return AppTheme.transportBlue;
      case 'Health':
        return AppTheme.successGreen;
      case 'Safety':
        return AppTheme.warningOrange;
      case 'Finance':
        return AppTheme.hotelPurple;
      case 'Electronics':
        return AppTheme.accentBlue;
      default:
        return AppTheme.textLight;
    }
  }
}
