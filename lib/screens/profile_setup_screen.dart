import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:stylesync/core/router/app_routes.dart";
import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/responsive_helper.dart";
import "package:stylesync/core/theme/glass_card.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/features/auth/data/auth_repository.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _usernameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser != null) {
      _displayNameCtrl.text = currentUser.displayName ?? "";
      _usernameCtrl.text = currentUser.email?.split("@").first ?? "";
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.card.withValues(alpha: 0.24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
            color: AppColors.accentMagenta.withValues(alpha: 0.22), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            BorderSide(color: AppColors.accentMagenta.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            const BorderSide(color: AppColors.accentMagenta, width: 1.6),
      ),
      labelStyle:
          AppTypography.interBody(14).copyWith(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final authRepository = ref.read(authRepositoryProvider);
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await authRepository.completeProfile(
        username: _usernameCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile completed successfully",
              style:
                  AppTypography.interBody(15).copyWith(color: AppColors.white)),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    final email = currentUser?.email ?? "";
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing =
        ResponsiveHelper.getResponsiveSpacing(context, 20);
    final responsiveButtonHeight =
        ResponsiveHelper.getResponsiveButtonHeight(context);
    final maxCardWidth = ResponsiveHelper.getMaxContentWidth(context);
    final headlineFontSize =
        ResponsiveHelper.getResponsiveFontSize(context, 22);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text("Complete your profile",
            style: AppTypography.orbitronHeading(18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentMagenta),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(responsivePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: GlassCard(
                padding: EdgeInsets.all(responsivePadding + 2),
                borderRadius:
                    ResponsiveHelper.getResponsiveBorderRadius(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Just one last step",
                        style: AppTypography.orbitronHeading(headlineFontSize)
                            .copyWith(color: AppColors.accentMagenta)),
                    SizedBox(height: responsiveSpacing * 0.5),
                    Text(
                      "Create a StyleSync username and display name so your barber can recognize you.",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.textMuted, height: 1.5),
                    ),
                    SizedBox(height: responsiveSpacing),
                    if (email.isNotEmpty)
                      Text("Signed in as $email",
                          style: AppTypography.interBody(13)
                              .copyWith(color: AppColors.textMuted)),
                    SizedBox(height: responsiveSpacing * 0.9),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameCtrl,
                            style: AppTypography.interBody(15)
                                .copyWith(color: AppColors.textPrimary),
                            decoration: _fieldDecoration("Choose a username"),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Username is required.";
                              }
                              if (!AuthRepository.isValidUsername(
                                  value.trim())) {
                                return "Use 3–50 letters, numbers, or underscore.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: responsiveSpacing * 0.7),
                          TextFormField(
                            controller: _displayNameCtrl,
                            style: AppTypography.interBody(15)
                                .copyWith(color: AppColors.textPrimary),
                            decoration: _fieldDecoration("Display name"),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Display name is required.";
                              }
                              if (value.trim().length < 2) {
                                return "Use at least two characters.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: responsiveSpacing),
                      Text(_error!,
                          style: AppTypography.interBody(13)
                              .copyWith(color: Colors.redAccent)),
                    ],
                    SizedBox(height: responsiveSpacing),
                    SizedBox(
                      height: responsiveButtonHeight,
                      child: StyleButton(
                        label: _busy ? "Saving…" : "Create profile",
                        icon: Icons.check_circle_outline,
                        onPressed: _busy ? null : _completeProfile,
                      ),
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
