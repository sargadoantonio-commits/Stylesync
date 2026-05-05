import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/core/theme/glass_card.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _userCtrl = TextEditingController();
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _message = null;
      _isError = false;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetForUsername(_userCtrl.text);
      setState(() {
        _message = "Reset email dispatched to the address on file (Firebase Auth).";
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Forgot Password", style: AppTypography.orbitronHeading(20)),
                    const SizedBox(height: 8),
                    Text(
                      "Maps Laravel username lookup → Firebase sendPasswordResetEmail.",
                      style: AppTypography.interBody(13).copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _userCtrl,
                      textCapitalization: TextCapitalization.none,
                      style: AppTypography.interBody(15),
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        style: AppTypography.interBody(13).copyWith(
                          color: _isError ? Colors.redAccent : AppColors.accentMagenta,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    StyleButton(label: "Send reset link", icon: Icons.mail_outline, onPressed: _send),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text("Back", style: AppTypography.interBody(14).copyWith(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

