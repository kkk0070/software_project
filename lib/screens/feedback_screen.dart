import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'General Feedback';
  int _rating = 0;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  // Email regex as static final to avoid recompilation
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Booking Issue',
    'Payment Problem',
    'App Performance',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Send Feedback',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  gradient: AppTheme.experienceGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.comments,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We value your feedback!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help us improve your experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Feedback Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Card(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        elevation: isDark ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How would you rate your experience?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: FaIcon(
                                        _rating > index
                                            ? FontAwesomeIcons.solidStar
                                            : FontAwesomeIcons.star,
                                        color: _rating > index
                                            ? AppTheme.ecoGold
                                            : AppTheme.textLight,
                                        size: 36,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              if (_rating > 0) ...[
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    _getRatingText(),
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category Selection
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Card(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        elevation: isDark ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feedback Category',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                                dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.category,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Information
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Card(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        elevation: isDark ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  // Use static regex for better performance
                                  if (!_emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Message
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Card(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        elevation: isDark ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 6,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tell us what you think...',
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your feedback';
                                  }
                                  if (value.length < 10) {
                                    return 'Please provide more details';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.paperPlane, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Submit Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Alternative Contact Methods
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Other ways to reach us',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContactOption(
                              icon: FontAwesomeIcons.headset,
                              title: 'Live Chat',
                              subtitle: 'Available 24/7',
                              gradient: AppTheme.accentGradient,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildContactOption(
                              icon: FontAwesomeIcons.phone,
                              title: 'Phone Support',
                              subtitle: '+1 (555) 123-4567',
                              gradient: AppTheme.transportGradient,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildContactOption(
                              icon: FontAwesomeIcons.envelope,
                              title: 'Email',
                              subtitle: 'support@travelhub.com',
                              gradient: AppTheme.ecoGradient,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a rating'),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
        return;
      }

      // Show success message
      showDialog(
        context: context,
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          final isDark = themeProvider.isDarkMode;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your feedback has been submitted successfully. We appreciate your input!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.dividerGrey,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.grey[400] : AppTheme.textLight,
          ),
        ],
      ),
    );
  }
}
