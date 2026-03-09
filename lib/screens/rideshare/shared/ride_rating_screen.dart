import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 12️⃣ Ride Rating & Feedback Page
class RideRatingScreen extends StatefulWidget {
  const RideRatingScreen({super.key});

  @override
  State<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends State<RideRatingScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : AppTheme.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Rate Your Ride', style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
              child: const Icon(FontAwesomeIcons.user, color: Colors.black, size: 32),
            ),
            const SizedBox(height: 16),
            Text('John Driver', style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star, size: 48, color: index < _rating ? AppTheme.warningOrange : (isDark ? Colors.grey[700] : Colors.grey[300])),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? AppTheme.cardDark : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3))),
              child: TextField(
                controller: _feedbackController,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience (optional)',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: AppTheme.primaryGreen),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Submit Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
