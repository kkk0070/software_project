import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a ride?',
      'answer': 'Navigate to the Rides tab in the bottom navigation, select your pickup and drop-off locations, choose your ride type (Solo, Pool, or EV), and confirm your booking. You can also schedule rides for later.',
    },
    {
      'question': 'What makes a hotel eco-friendly?',
      'answer': 'Eco-friendly hotels are certified based on their environmental practices including energy efficiency, water conservation, waste management, and sustainable sourcing. Look for Gold, Silver, or Bronze certifications.',
    },
    {
      'question': 'How is my carbon footprint calculated?',
      'answer': 'We calculate your carbon footprint based on the mode of transport, distance traveled, and fuel efficiency. EV rides and public transport have lower carbon emissions compared to traditional vehicles.',
    },
    {
      'question': 'Can I cancel my booking?',
      'answer': 'Yes, you can cancel bookings from the Bookings tab. Cancellation policies vary by service type. For rides, you can cancel free of charge up to 5 minutes before pickup. Hotel and experience cancellations follow the provider\'s policy.',
    },
    {
      'question': 'How do I earn Eco Points?',
      'answer': 'Earn Eco Points by choosing sustainable options like EV rides, eco-certified hotels, and public transport. Points unlock badges and special offers. Track your progress in the Impact tab.',
    },
    {
      'question': 'Is my payment information secure?',
      'answer': 'Yes, all payment information is encrypted and securely processed through industry-standard payment gateways. We never store your complete card details on our servers.',
    },
    {
      'question': 'How do I contact a travel guide?',
      'answer': 'Browse certified guides in the Travel Guides section, view their profiles, ratings, and specializations. You can send a message or book directly through the app.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'Some features like viewing saved trips and bookings are available offline. However, booking and real-time updates require an internet connection.',
    },
    {
      'question': 'How do I change my language preferences?',
      'answer': 'Go to Settings > Language and select from available languages. The Language Helper also provides quick translations for common phrases.',
    },
    {
      'question': 'What should I do in an emergency?',
      'answer': 'Use the Emergency SOS button in the Support section. It provides quick access to local emergency numbers, nearby hospitals, and your emergency contacts.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Help & FAQ',
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
            // Header with search
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleQuestion,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find answers to common questions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search FAQ...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? AppTheme.cardDark : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Help Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Help',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: FontAwesomeIcons.book,
                          title: 'User Guide',
                          gradient: AppTheme.transportGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: FontAwesomeIcons.video,
                          title: 'Video Tutorials',
                          gradient: AppTheme.experienceGradient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: FontAwesomeIcons.headset,
                          title: 'Live Chat',
                          gradient: AppTheme.ecoGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: FontAwesomeIcons.envelope,
                          title: 'Email Support',
                          gradient: AppTheme.hotelGradient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // FAQ List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: _buildFAQItem(
                          index: index,
                          question: _faqs[index]['question']!,
                          answer: _faqs[index]['answer']!,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Support Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.commentDots,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Still need help?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Our support team is available 24/7',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Contact support
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                        child: const Text('Contact Support'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required int index,
    required String question,
    required String answer,
    required bool isDark,
  }) {
    final isExpanded = _expandedIndex == index;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppTheme.cardDark : Colors.white,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.q,
                      color: AppTheme.primaryGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : AppTheme.textLight,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
