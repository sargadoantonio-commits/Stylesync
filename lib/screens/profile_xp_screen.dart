import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';
import 'dart:ui' as ui;

class ProfileXPScreen extends StatefulWidget {
  const ProfileXPScreen({super.key});

  @override
  State<ProfileXPScreen> createState() => _ProfileXPScreenState();
}

class _ProfileXPScreenState extends State<ProfileXPScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _levelUpCtrl;

  // Sample data - replace with Firestore
  final currentXP = 3500;
  final levelUpXP = 5000;
  final currentLevel = 7;
  final totalVisits = 23;
  final favBarbers = 5;
  final totalReviews = 12;
  final averageRating = 4.8;

  final achievements = [
    {
      'id': 'first_cut',
      'name': 'First Cut',
      'icon': '✂️',
      'unlocked': true,
      'date': '2024-01-15'
    },
    {
      'id': 'shop_hopper',
      'name': 'Shop Hopper',
      'icon': '🏪',
      'unlocked': true,
      'date': '2024-02-20'
    },
    {
      'id': 'loyal_customer',
      'name': 'Loyal Customer',
      'icon': '⭐',
      'unlocked': true,
      'date': '2024-03-10'
    },
    {
      'id': 'reviewer',
      'name': 'Reviewer',
      'icon': '✍️',
      'unlocked': true,
      'date': '2024-03-28'
    },
    {
      'id': 'weekend_warrior',
      'name': 'Weekend Warrior',
      'icon': '🛫',
      'unlocked': false,
      'date': null
    },
    {
      'id': 'master_barber_fan',
      'name': 'Master Fan',
      'icon': '👑',
      'unlocked': false,
      'date': null
    },
  ];

  final xpHistory = [
    {'action': 'Completed booking', 'xp': 100, 'date': 'Today', 'icon': '✓'},
    {'action': 'Left review', 'xp': 50, 'date': 'Yesterday', 'icon': '⭐'},
    {'action': 'Booked 5th visit', 'xp': 200, 'date': '2 days ago', 'icon': '🎯'},
    {'action': 'Completed booking', 'xp': 100, 'date': '3 days ago', 'icon': '✓'},
    {'action': 'Achievement unlocked', 'xp': 250, 'date': '4 days ago', 'icon': '🏆'},
  ];

  @override
  void initState() {
    super.initState();
    _levelUpCtrl = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _levelUpCtrl.forward();
  }

  @override
  void dispose() {
    _levelUpCtrl.dispose();
    super.dispose();
  }

  String _getLevelTitle() {
    if (currentLevel <= 5) return 'Newcomer';
    if (currentLevel <= 10) return 'Regular';
    if (currentLevel <= 20) return 'VIP';
    return 'Elite';
  }

  @override
  Widget build(BuildContext context) {
    final xpProgress = currentXP / levelUpXP;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        elevation: 0,
        title: Text(
          'Profile & XP',
          style: AppTypography.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.kText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level hero card
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.kCard.withOpacity(0.6),
                  border: Border.all(
                    color: AppColors.kGold.withOpacity(0.45),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kGold.withOpacity(0.15),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Level circle
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0)
                          .animate(_levelUpCtrl),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.kGold.withOpacity(0.3),
                              AppColors.kGold.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.kGold,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$currentLevel',
                            style: AppTypography.orbitron(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.kGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getLevelTitle(),
                      style: AppTypography.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currentXP / $levelUpXP XP',
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: AppColors.kMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // XP progress bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.kCard2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.kGold.withOpacity(0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          backgroundColor: AppColors.kCard2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.kGold.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(xpProgress * 100).toStringAsFixed(0)}% to Level ${currentLevel + 1}',
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: AppColors.kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats grid
            _buildSectionLabel(Icons.trending_up, 'Your Stats'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('$totalVisits', 'Visits', Icons.shopping_bag),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('$favBarbers', 'Favorites', Icons.favorite),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('$totalReviews', 'Reviews', Icons.rate_review),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '$averageRating★',
                    'Rating',
                    Icons.star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Achievements section
            _buildSectionLabel(Icons.emoji_events, 'Achievements'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, idx) {
                final achievement = achievements[idx];
                return _buildAchievementBadge(achievement);
              },
            ),
            const SizedBox(height: 32),

            // Recent XP history
            _buildSectionLabel(Icons.history, 'Recent Activity'),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: xpHistory.length,
              itemBuilder: (context, idx) {
                final item = xpHistory[idx];
                return _buildXPHistoryItem(item);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.kMuted),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.kMuted,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kCard.withOpacity(0.6),
          border: Border.all(
            color: AppColors.kBorder,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.kPrimary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.kText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.inter(
                fontSize: 10,
                color: AppColors.kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> achievement) {
    final unlocked = achievement['unlocked'] as bool;
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.kCard.withOpacity(0.8)
              : AppColors.kCard.withOpacity(0.3),
          border: Border.all(
            color: unlocked ? AppColors.kGold : AppColors.kBorder,
            width: unlocked ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement['icon'] as String,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                achievement['name'] as String,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 9,
                  color: unlocked ? AppColors.kText : AppColors.kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPHistoryItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kCard.withOpacity(0.4),
        border: Border.all(color: AppColors.kBorder, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            item['icon'] as String,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['action'] as String,
                  style: AppTypography.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['date'] as String,
                  style: AppTypography.inter(
                    fontSize: 10,
                    color: AppColors.kMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${item['xp']} XP',
            style: AppTypography.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.kGold,
            ),
          ),
        ],
      ),
    );
  }
}
