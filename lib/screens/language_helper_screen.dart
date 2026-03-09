import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class LanguageHelperScreen extends StatefulWidget {
  const LanguageHelperScreen({super.key});

  @override
  State<LanguageHelperScreen> createState() => _LanguageHelperScreenState();
}

class _LanguageHelperScreenState extends State<LanguageHelperScreen> {
  String selectedCategory = 'Common Phrases';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Language Helper',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTranslationCard(),
          _buildLanguageSelector(),
          _buildCategories(),
          Expanded(
            child: _buildPhrasesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.infoBlue, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.infoBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'English',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hello',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'French',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bonjour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type to translate...',
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final theme = Theme.of(context);
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Learning: ',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildLanguageChip('🇫🇷 French', true),
                    _buildLanguageChip('🇪🇸 Spanish', false),
                    _buildLanguageChip('🇮🇹 Italian', false),
                    _buildLanguageChip('🇩🇪 German', false),
                    _buildLanguageChip('🇯🇵 Japanese', false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.infoBlue.withOpacity(0.2),
        onSelected: (selected) {},
      ),
    );
  }

  Widget _buildCategories() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildCategoryChip('Common Phrases'),
            _buildCategoryChip('Directions'),
            _buildCategoryChip('Food & Dining'),
            _buildCategoryChip('Shopping'),
            _buildCategoryChip('Emergency'),
            _buildCategoryChip('Numbers'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            selectedCategory = label;
          });
        },
        selectedColor: AppTheme.infoBlue.withOpacity(0.2),
        checkmarkColor: AppTheme.infoBlue,
      ),
    );
  }

  Widget _buildPhrasesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _getPhrasesForCategory(isDark),
      ),
    );
  }

  List<Widget> _getPhrasesForCategory(bool isDark) {
    final phrases = {
      'Common Phrases': [
        {'en': 'Hello', 'fr': 'Bonjour', 'pronunciation': 'bon-ZHOOR'},
        {'en': 'Goodbye', 'fr': 'Au revoir', 'pronunciation': 'oh ruh-VWAH'},
        {'en': 'Please', 'fr': 'S\'il vous plaît', 'pronunciation': 'see voo PLEH'},
        {'en': 'Thank you', 'fr': 'Merci', 'pronunciation': 'mehr-SEE'},
        {'en': 'Yes', 'fr': 'Oui', 'pronunciation': 'wee'},
        {'en': 'No', 'fr': 'Non', 'pronunciation': 'nohn'},
        {'en': 'Excuse me', 'fr': 'Excusez-moi', 'pronunciation': 'eks-kew-zay-MWAH'},
        {'en': 'I don\'t understand', 'fr': 'Je ne comprends pas', 'pronunciation': 'zhuh nuh kom-PRAHN pah'},
      ],
      'Directions': [
        {'en': 'Where is...?', 'fr': 'Où est...?', 'pronunciation': 'oo eh'},
        {'en': 'How do I get to...?', 'fr': 'Comment puis-je aller à...?', 'pronunciation': 'koh-mahn pweezh ah-lay ah'},
        {'en': 'Left', 'fr': 'Gauche', 'pronunciation': 'gohsh'},
        {'en': 'Right', 'fr': 'Droite', 'pronunciation': 'drwaht'},
        {'en': 'Straight ahead', 'fr': 'Tout droit', 'pronunciation': 'too drwah'},
        {'en': 'Near', 'fr': 'Près', 'pronunciation': 'preh'},
        {'en': 'Far', 'fr': 'Loin', 'pronunciation': 'lwahn'},
      ],
      'Food & Dining': [
        {'en': 'I would like...', 'fr': 'Je voudrais...', 'pronunciation': 'zhuh voo-DREH'},
        {'en': 'The bill, please', 'fr': 'L\'addition, s\'il vous plaît', 'pronunciation': 'lah-dee-SYOHN see voo PLEH'},
        {'en': 'Water', 'fr': 'Eau', 'pronunciation': 'oh'},
        {'en': 'Menu', 'fr': 'Menu', 'pronunciation': 'muh-NEW'},
        {'en': 'Delicious', 'fr': 'Délicieux', 'pronunciation': 'day-lee-SYUH'},
        {'en': 'Coffee', 'fr': 'Café', 'pronunciation': 'ka-FAY'},
      ],
      'Shopping': [
        {'en': 'How much does this cost?', 'fr': 'Combien ça coûte?', 'pronunciation': 'kom-BYAHN sah koot'},
        {'en': 'Too expensive', 'fr': 'Trop cher', 'pronunciation': 'troh shehr'},
        {'en': 'I\'m just looking', 'fr': 'Je regarde seulement', 'pronunciation': 'zhuh ruh-GARD suhl-MAHN'},
        {'en': 'Do you accept credit cards?', 'fr': 'Acceptez-vous les cartes de crédit?', 'pronunciation': 'ak-sep-tay-voo lay kart duh kray-DEE'},
      ],
      'Emergency': [
        {'en': 'Help!', 'fr': 'Au secours!', 'pronunciation': 'oh suh-KOOR'},
        {'en': 'I need a doctor', 'fr': 'J\'ai besoin d\'un médecin', 'pronunciation': 'zhay buh-ZWAHN duhn mayd-SAN'},
        {'en': 'Call the police', 'fr': 'Appelez la police', 'pronunciation': 'ah-puh-lay lah poh-LEES'},
        {'en': 'I\'m lost', 'fr': 'Je suis perdu', 'pronunciation': 'zhuh swee pehr-DEW'},
      ],
      'Numbers': [
        {'en': 'One', 'fr': 'Un', 'pronunciation': 'uhn'},
        {'en': 'Two', 'fr': 'Deux', 'pronunciation': 'duh'},
        {'en': 'Three', 'fr': 'Trois', 'pronunciation': 'trwah'},
        {'en': 'Four', 'fr': 'Quatre', 'pronunciation': 'KAH-truh'},
        {'en': 'Five', 'fr': 'Cinq', 'pronunciation': 'sank'},
        {'en': 'Ten', 'fr': 'Dix', 'pronunciation': 'dees'},
      ],
    };

    final categoryPhrases = phrases[selectedCategory] ?? [];
    return categoryPhrases
        .map((phrase) => _buildPhraseCard(
              phrase['en']!,
              phrase['fr']!,
              phrase['pronunciation']!,
              isDark,
            ))
        .toList();
  }

  Widget _buildPhraseCard(String english, String french, String pronunciation, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      english,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      french,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.record_voice_over,
                          size: 14,
                          color: AppTheme.infoBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pronunciation,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.infoBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: AppTheme.infoBlue,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
