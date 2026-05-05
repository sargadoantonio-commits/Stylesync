import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/core/theme/glass_card.dart';

/// Admin unlock modal for barber dashboard
/// Shows a password prompt to unlock admin monitoring view
class AdminUnlockModal extends ConsumerStatefulWidget {
  final VoidCallback onAdminUnlocked;

  const AdminUnlockModal({
    super.key,
    required this.onAdminUnlocked,
  });

  @override
  ConsumerState<AdminUnlockModal> createState() => _AdminUnlockModalState();
}

class _AdminUnlockModalState extends ConsumerState<AdminUnlockModal> {
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String? _error;

  // Admin password (you can change this)
  static const String ADMIN_PASSWORD = 'AdminMaster2024!';

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _checkAdminPassword() {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    // Simulate network delay for security
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final enteredPassword = _passwordCtrl.text.trim();

      if (enteredPassword == ADMIN_PASSWORD) {
        setState(() {
          _isLoading = false;
        });
        // Call the callback to unlock admin view
        widget.onAdminUnlocked();
        Navigator.of(context).pop(); // Close modal
      } else {
        setState(() {
          _isLoading = false;
          _error = '❌ Incorrect admin password. Try again.';
          _passwordCtrl.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text('🔐 Admin Access',
                      style: AppTypography.orbitronHeading(18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Enter the admin password to access the monitoring dashboard',
                style: AppTypography.interBody(13)
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              // Password Field
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Admin Password',
                  hintStyle:
                      AppTypography.interBody(13).copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.card.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.accentMagenta.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentMagenta),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                style: AppTypography.interBody(13),
              ),
              const SizedBox(height: 12),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: AppTypography.interBody(12)
                        .copyWith(color: AppColors.accentRed),
                  ),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.interBody(13, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkAdminPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentMagenta,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.background),
                              ),
                            )
                          : Text(
                              'Unlock',
                              style: AppTypography.interBody(13,
                                  weight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
