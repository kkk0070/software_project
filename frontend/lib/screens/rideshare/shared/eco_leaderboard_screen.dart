import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

/// Eco Leaderboard Screen – shows top green riders
class EcoLeaderboardScreen extends StatefulWidget {
  const EcoLeaderboardScreen({super.key});

  @override
  State<EcoLeaderboardScreen> createState() => _EcoLeaderboardScreenState();
}

class _EcoLeaderboardScreenState extends State<EcoLeaderboardScreen> {
  int _selectedFilter = 0; // 0=Weekly, 1=Monthly, 2=All Time

  static const List<_LeaderEntry> _weekly = [
    _LeaderEntry('Arjun S.', 980, 'EV Champion', '12.4 kg', 1, false),
    _LeaderEntry('Priya M.', 940, 'Pool Pro', '11.8 kg', 2, false),
    _LeaderEntry('Rahul K.', 910, 'Eco Warrior', '10.5 kg', 3, false),
    _LeaderEntry('Sneha T.', 875, 'Green Rider', '9.2 kg', 4, false),
    _LeaderEntry('You', 850, 'Eco Rider', '8.7 kg', 5, true),
    _LeaderEntry('Anil P.', 820, 'Pool Rider', '7.9 kg', 6, false),
    _LeaderEntry('Meena R.', 790, 'Green Newbie', '7.1 kg', 7, false),
    _LeaderEntry('Kiran V.', 760, 'Eco Starter', '6.5 kg', 8, false),
  ];

  static const List<_LeaderEntry> _monthly = [
    _LeaderEntry('Priya M.', 3800, 'Pool Pro', '46.2 kg', 1, false),
    _LeaderEntry('Arjun S.', 3650, 'EV Champion', '44.8 kg', 2, false),
    _LeaderEntry('You', 3400, 'Eco Rider', '42.0 kg', 3, true),
    _LeaderEntry('Rahul K.', 3200, 'Eco Warrior', '39.5 kg', 4, false),
    _LeaderEntry('Sneha T.', 3050, 'Green Rider', '37.8 kg', 5, false),
    _LeaderEntry('Anil P.', 2900, 'Pool Rider', '35.2 kg', 6, false),
    _LeaderEntry('Meena R.', 2750, 'Green Newbie', '33.6 kg', 7, false),
    _LeaderEntry('Kiran V.', 2600, 'Eco Starter', '31.0 kg', 8, false),
  ];

  static const List<_LeaderEntry> _allTime = [
    _LeaderEntry('Priya M.', 12500, 'Pool Pro', '186 kg', 1, false),
    _LeaderEntry('Rahul K.', 11800, 'Eco Warrior', '175 kg', 2, false),
    _LeaderEntry('Arjun S.', 11200, 'EV Champion', '168 kg', 3, false),
    _LeaderEntry('Sneha T.', 10600, 'Green Rider', '158 kg', 4, false),
    _LeaderEntry('Anil P.', 9900, 'Pool Rider', '147 kg', 5, false),
    _LeaderEntry('You', 8500, 'Eco Rider', '126 kg', 6, true),
    _LeaderEntry('Meena R.', 7800, 'Green Newbie', '115 kg', 7, false),
    _LeaderEntry('Kiran V.', 7200, 'Eco Starter', '106 kg', 8, false),
  ];

  List<_LeaderEntry> get _entries {
    switch (_selectedFilter) {
      case 1: return _monthly;
      case 2: return _allTime;
      default: return _weekly;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top3 = _entries.take(3).toList();
    final rest = _entries.skip(3).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Eco Leaderboard', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: ['Weekly', 'Monthly', 'All Time'].asMap().entries.map((e) {
                  final selected = _selectedFilter == e.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          e.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.black : (isDark ? Colors.white60 : Colors.black54),
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Podium
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildPodium(context, top3, isDark),
          ),
          // Rest of list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: rest.length,
              itemBuilder: (ctx, i) => _buildListItem(ctx, rest[i], isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<_LeaderEntry> top3, bool isDark) {
    final order = [top3[1], top3[0], top3[2]]; // 2nd, 1st, 3rd for podium layout
    final heights = [90.0, 110.0, 70.0];
    final colors = [AppTheme.accentBlue, const Color(0xFFFFC107), AppTheme.warningOrange];
    final medals = ['🥈', '🥇', '🥉'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final entry = order[i];
        return Expanded(
          child: Column(
            children: [
              Text(medals[i], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 22,
                backgroundColor: colors[i].withOpacity(0.2),
                child: Text(
                  entry.name.substring(0, 1),
                  style: TextStyle(color: colors[i], fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.name,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text('${entry.score}', style: TextStyle(color: colors[i], fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: heights[i],
                decoration: BoxDecoration(
                  color: colors[i].withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border.all(color: colors[i].withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(color: colors[i], fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListItem(BuildContext context, _LeaderEntry entry, bool isDark) {
    final isMe = entry.isMe;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primaryGreen.withOpacity(0.12)
            : (isDark ? AppTheme.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppTheme.primaryGreen : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.backgroundDark : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('#${entry.rank}', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
            child: Text(entry.name.substring(0, 1), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 13)),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(6)),
                        child: const Text('You', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(entry.badge, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.score} pts', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(entry.co2Saved, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final int score;
  final String badge;
  final String co2Saved;
  final int rank;
  final bool isMe;

  const _LeaderEntry(this.name, this.score, this.badge, this.co2Saved, this.rank, this.isMe);
}
