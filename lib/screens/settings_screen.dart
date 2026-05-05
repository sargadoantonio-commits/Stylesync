import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = false;
  bool _profilePublic = true;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kCard,
        title: const Text('Sign Out?',
            style: TextStyle(
              color: AppColors.kText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.kAccent, fontSize: 14)),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.kDanger, fontSize: 14)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.kDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kCard,
        title: const Text('Delete Account?',
            style: TextStyle(
              color: AppColors.kDanger,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppColors.kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.kAccent, fontSize: 14)),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Delete Permanently',
                style: TextStyle(color: AppColors.kDanger, fontSize: 14)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        // Delete Firestore document
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete Firebase Auth user
        await FirebaseAuth.instance.currentUser!.delete();

        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e'),
              backgroundColor: AppColors.kDanger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        title: const Text('Settings', style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account card
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.kAccent.withOpacity(0.2),
                    child: const Icon(Icons.person,
                        size: 32, color: AppColors.kAccent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.kMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined,
                      color: AppColors.kAccent, size: 20),
                ],
              ),
            ),

            // Account Settings Section
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Update Username',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature coming soon'),
                    backgroundColor: AppColors.kMuted,
                  ),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Update Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature coming soon'),
                    backgroundColor: AppColors.kMuted,
                  ),
                );
              },
            ),

            // Preferences Section
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildSwitchItem(
              icon: Icons.notifications,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildSwitchItem(
              icon: Icons.location_on_outlined,
              title: 'Location Sharing',
              value: _locationSharingEnabled,
              onChanged: (v) => setState(() => _locationSharingEnabled = v),
            ),
            _buildSwitchItem(
              icon: Icons.visibility_outlined,
              title: 'Public Profile',
              value: _profilePublic,
              onChanged: (v) => setState(() => _profilePublic = v),
            ),

            // About Section
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: () {},
              trailing: true,
            ),
            _buildSettingItem(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),

            // Danger Zone
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kDanger,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildSettingItem(
              icon: Icons.logout_outlined,
              title: 'Sign Out',
              color: AppColors.kDanger,
              onTap: _logout,
            ),
            _buildSettingItem(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              color: AppColors.kDanger,
              onTap: _deleteAccount,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF00F5D4),
    bool trailing = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kText,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.kMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!trailing)
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.kMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.kAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kText,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.kAccent,
              activeTrackColor: AppColors.kAccent.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
