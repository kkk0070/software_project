import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// 16️⃣ Rewards & Gamification Page
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Rewards', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Shop'),
            Tab(text: 'Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, isDark),
          _buildShopTab(context, isDark),
          _buildChallengesTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPointsCard(context),
          const SizedBox(height: 20),
          _buildStreakCard(context, isDark),
          const SizedBox(height: 24),
          Text('Your Badges', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildBadge('Eco Warrior', FontAwesomeIcons.leaf, AppTheme.primaryGreen, true),
              _buildBadge('Pool Pro', FontAwesomeIcons.users, AppTheme.accentBlue, true),
              _buildBadge('EV Champion', FontAwesomeIcons.bolt, AppTheme.warningOrange, true),
              _buildBadge('Night Rider', FontAwesomeIcons.moon, Colors.grey, false),
              _buildBadge('Century', FontAwesomeIcons.star, Colors.grey, false),
              _buildBadge('Carbon Zero', FontAwesomeIcons.seedling, Colors.grey, false),
            ],
          ),
          const SizedBox(height: 24),
          Text('Milestones', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMilestone(context, 'Complete 10 pooled rides', 7, 10, FontAwesomeIcons.users, AppTheme.accentBlue),
          const SizedBox(height: 12),
          _buildMilestone(context, 'Save 100kg CO₂', 42, 100, FontAwesomeIcons.leaf, AppTheme.primaryGreen),
          const SizedBox(height: 12),
          _buildMilestone(context, '50 EV rides', 28, 50, FontAwesomeIcons.bolt, AppTheme.warningOrange),
          const SizedBox(height: 12),
          _buildMilestone(context, '5 Bicycle trips', 2, 5, FontAwesomeIcons.bicycle, AppTheme.darkGreen),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.trophy, color: Colors.black, size: 48),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Eco Points', style: TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(height: 4),
                Text('1,250', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('250 pts to next level', style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Level 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.trending_up, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(FontAwesomeIcons.fire, color: AppTheme.primaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7-Day Green Streak! 🔥', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Keep choosing eco-friendly rides to grow your streak', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              Text('7', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 28, fontWeight: FontWeight.bold)),
              Text('days', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color, bool unlocked) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: unlocked ? color : Colors.grey.withOpacity(0.3), width: 1.5),
            boxShadow: unlocked ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!unlocked)
                const Icon(Icons.lock, color: Colors.grey, size: 16)
              else
                const SizedBox.shrink(),
              Icon(icon, color: unlocked ? color : Colors.grey, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: unlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                  fontSize: 10,
                  fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestone(BuildContext context, String label, int current, int total, IconData icon, Color color) {
    final progress = current / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 13))),
                    Text('$current/$total', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopTab(BuildContext context, bool isDark) {
    final items = [
      _RewardItem('Free Ride Voucher', '500 pts', Icons.directions_car, const Color(0xFF2196F3), '₹50 off your next ride'),
      _RewardItem('Carbon Offset', '300 pts', Icons.eco, AppTheme.primaryGreen, 'Plant 3 trees in your name'),
      _RewardItem('Priority Booking', '800 pts', Icons.star, const Color(0xFFFFC107), 'Skip the queue for 7 days'),
      _RewardItem('EV Upgrade', '1000 pts', Icons.bolt, const Color(0xFF00E5FF), 'Free upgrade to EV ride'),
      _RewardItem('Premium Support', '400 pts', Icons.headset_mic, const Color(0xFF9C27B0), '24/7 dedicated support'),
      _RewardItem('Referral Bonus', '200 pts', Icons.person_add, AppTheme.warningOrange, 'Earn 200 pts per referral'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.coins, color: Color(0xFFFFC107), size: 24),
                const SizedBox(width: 12),
                Text('Your Balance: ', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                const Text('1,250 pts', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Redeem Rewards', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildShopItem(context, item, isDark),
          )),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, _RewardItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(item.description, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showRedeemDialog(context, item),
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(item.points, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, _RewardItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Redeem ${item.name}?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'This will deduct ${item.points} from your balance.\n\n${item.description}',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${item.name} redeemed successfully!'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: item.color),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab(BuildContext context, bool isDark) {
    final challenges = [
      _Challenge('Green Week', 'Complete 5 eco rides this week', 3, 5, FontAwesomeIcons.calendar, AppTheme.primaryGreen, '+150 pts'),
      _Challenge('EV Explorer', 'Take 3 EV rides this month', 1, 3, FontAwesomeIcons.bolt, const Color(0xFF00E5FF), '+200 pts'),
      _Challenge('Carpool King', 'Pool 10 rides with others', 6, 10, FontAwesomeIcons.users, AppTheme.accentBlue, '+300 pts'),
      _Challenge('Zero Emission Day', 'Use only bicycle or EV today', 0, 1, FontAwesomeIcons.bicycle, AppTheme.darkGreen, '+100 pts'),
      _Challenge('Refer & Earn', 'Invite 2 friends to join', 1, 2, FontAwesomeIcons.userPlus, AppTheme.warningOrange, '+200 pts'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF283593)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(FontAwesomeIcons.bolt, color: Color(0xFFFFD54F), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complete challenges to earn bonus Eco Points!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Active Challenges', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...challenges.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChallengeCard(context, c, isDark),
          )),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, _Challenge c, bool isDark) {
    final progress = c.current / c.total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c.icon, color: c.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(c.description, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.reward, style: TextStyle(color: c.color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: c.color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${c.current}/${c.total}', style: TextStyle(color: c.color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardItem {
  final String name;
  final String points;
  final IconData icon;
  final Color color;
  final String description;
  const _RewardItem(this.name, this.points, this.icon, this.color, this.description);
}

class _Challenge {
  final String name;
  final String description;
  final int current;
  final int total;
  final IconData icon;
  final Color color;
  final String reward;
  const _Challenge(this.name, this.description, this.current, this.total, this.icon, this.color, this.reward);
}
