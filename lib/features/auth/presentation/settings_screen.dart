import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/router/app_routes.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/responsive_helper.dart";
import "../../../core/theme/style_button.dart";
import "../../../core/theme/glass_card.dart";
import "../../../widgets/bottom_nav_bar.dart";
import "../data/auth_repository.dart";
import "providers/auth_providers.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _newUserCtrl = TextEditingController();
  final _userPassCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _reminders = true;
  bool _queueAlerts = true;
  bool _arRecommendations = false;
  String? _banner;
  bool _bannerError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newUserCtrl.dispose();
    _userPassCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    setState(() {
      _banner = msg;
      _bannerError = error;
    });
  }

  Future<void> _updateUsername() async {
    try {
      await ref.read(authRepositoryProvider).updateUsername(
            newUsername: _newUserCtrl.text,
            currentPassword: _userPassCtrl.text,
          );
      _toast("Username updated.");
      _newUserCtrl.clear();
      _userPassCtrl.clear();
    } catch (e) {
      _toast(e.toString(), error: true);
    }
  }

  Future<void> _updatePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _toast("Passwords do not match.", error: true);
      return;
    }
    try {
      await ref.read(authRepositoryProvider).updatePassword(
            currentPassword: _currentPassCtrl.text,
            newPassword: _newPassCtrl.text,
          );
      _toast("Password updated.");
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    } catch (e) {
      _toast(e.toString(), error: true);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Sign Out?",
            style: AppTypography.orbitronHeading(18)
                .copyWith(color: AppColors.white)),
        content: Text(
          "You will be signed out of your account. You can sign back in anytime.",
          style:
              AppTypography.interBody(14).copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel",
                style: AppTypography.interBody(14)
                    .copyWith(color: AppColors.accentMagenta)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Sign Out",
                style: AppTypography.interBody(14).copyWith(
                    color: AppColors.accentRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      _toast("Failed to sign out: ${e.toString()}", error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        foregroundColor: AppColors.kText,
        elevation: 0,
        title:
            Text("Account Settings", style: AppTypography.orbitronHeading(18)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentMagenta,
          indicatorWeight: 3,
          labelColor: AppColors.accentMagenta,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.settings),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountTab(profile),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildAccountTab(dynamic profile) {
    return Container(
      color: AppColors.background,
      child: ListView(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        children: [
          if (profile != null && !profile.profileComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accentRed.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.accentRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Complete your profile",
                            style: AppTypography.interBody(14,
                                    weight: FontWeight.w700)
                                .copyWith(color: AppColors.accentRed)),
                        const SizedBox(height: 6),
                        Text("Set your username and display name.",
                            style: AppTypography.interBody(12)
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profileSetup),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.accentRed),
                  ),
                ],
              ),
            ),
          if (profile != null && !profile.profileComplete)
            const SizedBox(height: 16),
          if (profile != null)
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: profile.photoUrl.isNotEmpty
                          ? NetworkImage(profile.photoUrl)
                          : null,
                      backgroundColor:
                          AppColors.accentMagenta.withValues(alpha: 0.18),
                      child: profile.photoUrl.isEmpty
                          ? Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName[0].toUpperCase()
                                  : profile.username[0].toUpperCase(),
                              style: AppTypography.orbitronHeading(20)
                                  .copyWith(color: AppColors.accentMagenta),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Signed in as",
                              style: AppTypography.interBody(12)
                                  .copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName
                                  : profile.username,
                              style: AppTypography.interBody(18,
                                  weight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(profile.email,
                              style: AppTypography.interBody(13)
                                  .copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          Text(
                            profile.providerIds.contains("google.com")
                                ? "Google account"
                                : profile.providerIds.contains("facebook.com")
                                    ? "Facebook account"
                                    : "StyleSync account",
                            style: AppTypography.interBody(12)
                                .copyWith(color: AppColors.accentRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_banner != null) ...[
            const SizedBox(height: 12),
            Text(
              _banner!,
              style: AppTypography.interBody(13).copyWith(
                color:
                    _bannerError ? Colors.redAccent : AppColors.accentMagenta,
              ),
            ),
          ],
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Update username",
                    style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _newUserCtrl,
                  textCapitalization: TextCapitalization.none,
                  style: AppTypography.interBody(15),
                  decoration:
                      const InputDecoration(labelText: "New username"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _userPassCtrl,
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  style: AppTypography.interBody(15),
                  decoration:
                      const InputDecoration(labelText: "Current password"),
                ),
                const SizedBox(height: 12),
                StyleButton(
                    label: "Save username",
                    icon: Icons.badge,
                    onPressed: _updateUsername),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Update password",
                    style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentPassCtrl,
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  style: AppTypography.interBody(15),
                  decoration:
                      const InputDecoration(labelText: "Current password"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPassCtrl,
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  style: AppTypography.interBody(15),
                  decoration:
                      const InputDecoration(labelText: "New password"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPassCtrl,
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  style: AppTypography.interBody(15),
                  decoration: const InputDecoration(
                      labelText: "Confirm new password"),
                ),
                const SizedBox(height: 12),
                StyleButton(
                  label: "Save password",
                  icon: Icons.password_rounded,
                  onPressed: () {
                    if (!AuthRepository.isValidPassword(_newPassCtrl.text)) {
                      _toast("Password must be 8–100 characters.",
                          error: true);
                      return;
                    }
                    _updatePassword();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Sign Out", style: AppTypography.orbitronHeading(14)),
                const SizedBox(height: 12),
                Text(
                  "You can sign back in anytime with your email or Google account.",
                  style: AppTypography.interBody(13)
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: Material(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AppColors.accentRed, size: 20),
                          const SizedBox(width: 8),
                          Text("Sign Out",
                              style: AppTypography.interBody(15,
                                      weight: FontWeight.w600)
                                  .copyWith(color: AppColors.accentRed)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Container(
      color: AppColors.background,
      child: ListView(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        children: [
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notification Settings",
                      style: AppTypography.orbitronHeading(14)),
                  const SizedBox(height: 8),
                  Text("Control the alerts you receive from StyleSync.",
                      style: AppTypography.interBody(13)
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                _buildNotificationToggle(
                  title: "Appointment reminders",
                  subtitle: "Get notified before your booking",
                  value: _reminders,
                  onChanged: (value) =>
                      setState(() => _reminders = value),
                ),
                const Divider(height: 24, color: Colors.transparent),
                _buildNotificationToggle(
                  title: "Queue alerts",
                  subtitle: "Updates when your turn is getting closer",
                  value: _queueAlerts,
                  onChanged: (value) =>
                      setState(() => _queueAlerts = value),
                ),
                const Divider(height: 24, color: Colors.transparent),
                _buildNotificationToggle(
                  title: "AR suggestions",
                  subtitle: "New haircut styles that match your face",
                  value: _arRecommendations,
                  onChanged: (value) =>
                      setState(() => _arRecommendations = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recent Activity",
                      style: AppTypography.orbitronHeading(14)),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    icon: Icons.queue_music_rounded,
                    title: "You joined a queue",
                    subtitle: "Kings Cut Studio - 2 hours ago",
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.calendar_today_rounded,
                    title: "Booking confirmed",
                    subtitle: "Downtown Fade - Tomorrow 3:00 PM",
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.login_rounded,
                    title: "Signed in to account",
                    subtitle: "Android device - 1 day ago",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.interBody(14, weight: FontWeight.w600)
                      .copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: AppTypography.interBody(12)
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accentMagenta,
          inactiveTrackColor:
              AppColors.accentMagenta.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentMagenta.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 18, color: AppColors.accentMagenta),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.interBody(13, weight: FontWeight.w600)
                      .copyWith(color: AppColors.white)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTypography.interBody(11)
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
