import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/features/auth/domain/password_breach_checker.dart';

/// Password strength indicator with breach detection
class PasswordStrengthIndicator extends ConsumerStatefulWidget {
  final String password;
  final Function(bool isValid) onStrengthChanged;

  const PasswordStrengthIndicator({
    required this.password,
    required this.onStrengthChanged,
    super.key,
  });

  @override
  ConsumerState<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState
    extends ConsumerState<PasswordStrengthIndicator> {
  late Future<PasswordBreachResult> _breachCheckFuture;

  @override
  void didUpdateWidget(PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      if (widget.password.length >= 8) {
        _breachCheckFuture = PasswordBreachChecker.checkPassword(widget.password);
      } else {
        // Reset to incomplete check for shorter passwords
        _breachCheckFuture = Future.value(
          PasswordBreachResult(isCompromised: false, timesCompromised: 0, message: 'Password too short to check'),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.password.length >= 8) {
      _breachCheckFuture = PasswordBreachChecker.checkPassword(widget.password);
    } else {
      // Initialize with a completed future for passwords < 8 chars
      _breachCheckFuture = Future.value(
        PasswordBreachResult(isCompromised: false, timesCompromised: 0, message: 'Password too short to check'),
      );
    }
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{};:,.<>?]').hasMatch(password)) {
      strength++;
    }

    return strength;
  }

  String _getStrengthLabel(int strength) {
    if (strength < 2) return 'Weak';
    if (strength < 4) return 'Fair';
    if (strength < 5) return 'Good';
    return 'Strong';
  }

  Color _getStrengthColor(int strength) {
    if (strength < 2) return AppColors.kDanger;
    if (strength < 4) return AppColors.accentGold;
    if (strength < 5) return AppColors.accentCyan;
    return AppColors.kSuccess;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _calculatePasswordStrength(widget.password);
    final strengthColor = _getStrengthColor(strength);
    final strengthLabel = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength indicator bar
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 6,
                backgroundColor: AppColors.card,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthLabel,
              style: AppTypography.interBody(12, weight: FontWeight.w600)
                  .copyWith(color: strengthColor),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Password requirements checklist
        _buildRequirement(
          'At least 8 characters',
          widget.password.length >= 8,
        ),
        _buildRequirement(
          'Mix of uppercase and lowercase',
          RegExp(r'[a-z]').hasMatch(widget.password) &&
              RegExp(r'[A-Z]').hasMatch(widget.password),
        ),
        _buildRequirement(
          'Contains numbers',
          RegExp(r'[0-9]').hasMatch(widget.password),
        ),
        _buildRequirement(
          r'Contains special characters (! @ # $ % etc)',
          RegExp(r'[!@#$%^&*()_+\-=\[\]{};:,.<>?]')
              .hasMatch(widget.password),
        ),
        const SizedBox(height: 8),

        // Breach detection
        if (widget.password.length >= 8)
          FutureBuilder<PasswordBreachResult>(
            future: _breachCheckFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.kMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checking password security...',
                        style: AppTypography.interBody(12)
                            .copyWith(color: AppColors.kMuted),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Could not verify password security.',
                          style: AppTypography.interBody(12)
                              .copyWith(color: AppColors.accentGold),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final result = snapshot.data!;

              if (result.isCompromised) {
                widget.onStrengthChanged(false);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.kDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.kDanger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          size: 16,
                          color: AppColors.kDanger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🔓 ${result.message}',
                            style: AppTypography.interBody(11)
                                  .copyWith(color: AppColors.kDanger),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                widget.onStrengthChanged(strength >= 4);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.kSuccess,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '✓ ${result.message}',
                          style: AppTypography.interBody(11)
                              .copyWith(color: AppColors.kSuccess),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildRequirement(String label, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppColors.kSuccess : AppColors.kMuted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.interBody(12).copyWith(
              color: isMet ? AppColors.kSuccess : AppColors.kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
