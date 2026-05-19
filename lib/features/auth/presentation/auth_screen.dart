import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:stylesync/core/router/app_routes.dart";
import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/responsive_helper.dart";
import "package:stylesync/core/theme/glass_card.dart";
import "package:stylesync/core/oauth_config.dart";
import "package:stylesync/features/auth/data/auth_repository.dart";
import "package:stylesync/features/auth/domain/password_security_engine.dart";
import "package:stylesync/features/auth/domain/user_role.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";
import "package:stylesync/features/auth/presentation/widgets/password_strength_indicator.dart";

enum AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  String _currentPassword = ""; // Track current password for strength widget
  UserRole _selectedRole = UserRole.customer;

  bool get _isLogin => widget.mode == AuthMode.login;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // For login mode, clear email field if it has data
    if (_isLogin) {
      _usernameCtrl.clear();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    final authRepository = ref.read(authRepositoryProvider);
    try {
      if (_isLogin) {
        // Login with email
        await authRepository.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        // Signup with comprehensive error handling
        await authRepository.register(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole,
          isPremium: false,
        );
      }

      if (!mounted) return;

      // Verify profile was created/updated successfully
      final currentUser = ref.read(firebaseAuthProvider).currentUser;
      if (currentUser == null) {
        throw StateError("Authentication failed: User not found.");
      }

      final profile = await authRepository.fetchProfile(currentUser.uid);
      if (profile == null) {
        throw StateError("Profile creation failed. Please try again.");
      }

      HapticFeedback.lightImpact();

      if (!_isLogin) {
        // Enhanced signup success notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Account Created Successfully!',
                          style: AppTypography.interBody(15,
                                  weight: FontWeight.w700)
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      'Verification email sent. Redirecting to login...',
                      style: AppTypography.interBody(13)
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        // Wait 2 seconds before navigating to show success notification clearly
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // After successful signup, redirect to login page
          context.go(AppRoutes.login);
        }
      } else {
        // Login success notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✓ Login Successful",
                style: AppTypography.interBody(15)
                    .copyWith(color: AppColors.white),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          // Navigate to landing so router redirect sends user to role-specific home
          context.go(AppRoutes.landing);
        }
      }
    } on StateError catch (e) {
      // Handle signup-specific errors (duplicate accounts, service issues, etc.)
      if (mounted) {
        HapticFeedback.vibrate();
        final errorMsg = e.message;
        _showErrorNotification(
          title: _isLogin ? "Login Failed" : "Signup Failed",
          message: errorMsg,
          isDuplicate: errorMsg.toLowerCase().contains("already") ||
              errorMsg.toLowerCase().contains("duplicate") ||
              errorMsg.toLowerCase().contains("email already"),
        );
        setState(() => _error = errorMsg);
      }
    } on AuthCredentialException catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        _showErrorNotification(
          title: _isLogin ? "Login Failed" : "Signup Failed",
          message: e.message,
        );
        setState(() => _error = e.message);
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        _showErrorNotification(
          title: _isLogin ? "Login Failed" : "Signup Failed",
          message: e.message ?? "Invalid input",
        );
        setState(() => _error = e.message);
      }
    } catch (e) {
      final errorMessage = _userFriendlyErrorMessage(e);
      if (mounted) {
        HapticFeedback.vibrate();
        _showErrorNotification(
          title: _isLogin ? "Login Failed" : "Signup Failed",
          message: errorMessage,
        );
        setState(() => _error = errorMessage);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Show error notification with specific styling based on error type
  void _showErrorNotification({
    required String title,
    required String message,
    bool isDuplicate = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDuplicate ? Icons.block : Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.interBody(15, weight: FontWeight.w700)
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                message,
                style: AppTypography.interBody(13)
                    .copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor:
            isDuplicate ? Colors.orange.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isDuplicate ? 5 : 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _userFriendlyErrorMessage(Object error) {
    String message = error.toString();
    if (error is Exception && message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    if (message.startsWith('PlatformException(')) {
      final start = message.indexOf('(');
      final end = message.lastIndexOf(')');
      if (start >= 0 && end > start) {
        message = message.substring(start + 1, end);
      }
    }
    message = message.replaceAll('Bad state: ', '').trim();
    if (message.isEmpty) {
      return 'Authentication failed. Please try again.';
    }
    return message;
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your email to reset your password.",
            style: AppTypography.interBody(14).copyWith(color: AppColors.white),
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    try {
      HapticFeedback.lightImpact();
      // Send password reset email
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✓ Password reset email sent! Check your inbox.",
            style: AppTypography.interBody(14).copyWith(color: AppColors.white),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      
      String errorMessage = "Failed to send password reset email.";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No account found with this email.";
      } else if (e.toString().contains("too-many-requests")) {
        errorMessage = "Too many attempts. Try again later.";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✗ Error: $errorMessage",
            style: AppTypography.interBody(14).copyWith(color: AppColors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _socialSignIn(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      HapticFeedback.selectionClick();
      await action();
      if (!mounted) return;
      final currentUser = ref.read(firebaseAuthProvider).currentUser;
      final profile = currentUser != null
          ? await ref.read(authRepositoryProvider).fetchProfile(currentUser.uid)
          : null;
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✓ Login Successful",
            style: AppTypography.interBody(15).copyWith(color: AppColors.white),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      if (profile != null && profile.profileComplete == false) {
        context.go(AppRoutes.profileSetup);
      } else {
        // Go to landing to let the router redirect based on role/profile
        context.go(AppRoutes.landing);
      }
    } catch (e) {
      String errorMessage = _userFriendlyErrorMessage(e);
      // Provide user-friendly error messages
      if (e.toString().contains('ClientID not set')) {
        errorMessage =
            'Google Sign-In is not configured. Contact support or use Facebook.';
      } else if (e.toString().contains('Instagram OAuth')) {
        errorMessage =
            'Instagram sign-in not available. Please use Google or Facebook.';
      }
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✗ Social Login Failed: $errorMessage",
              style:
                  AppTypography.interBody(14).copyWith(color: AppColors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        setState(() => _error = errorMessage);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _headline {
    return _isLogin
        ? "Welcome back! Ready for a fresh fade?"
        : "Join the list. Your best look starts here.";
  }

  String get _actionLabel => _isLogin ? "Login" : "Sign Up";

  String get _switchLabel => _isLogin
      ? "Don't have an account? Sign up"
      : "Already have an account? Login";

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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 2.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.4),
      ),
      labelStyle:
          AppTypography.interBody(14).copyWith(color: AppColors.textMuted),
      errorStyle: AppTypography.interBody(13, weight: FontWeight.w600).copyWith(
        color: const Color(0xFFFF5252),
        height: 1.4,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      errorMaxLines: 2,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    double width = 56,
    double height = 56,
  }) {
    return _SocialButtonWidget(
      icon: icon,
      label: label,
      enabled: enabled && !_busy,
      onTap: enabled && !_busy ? onTap : null,
      width: width,
      height: height,
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentMagenta.withValues(alpha: 0.15)
              : AppColors.card.withValues(alpha: 0.4),
          border: Border.all(
            color: isSelected
                ? AppColors.accentMagenta
                : AppColors.textMuted.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentMagenta : AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style:
                  AppTypography.interBody(13, weight: FontWeight.w600).copyWith(
                color: isSelected
                    ? AppColors.accentMagenta
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing =
        ResponsiveHelper.getResponsiveSpacing(context, 24);
    final responsiveButtonHeight =
        ResponsiveHelper.getResponsiveButtonHeight(context);
    final logoDimension =
        ResponsiveHelper.isSmallDevice(context) ? 120.0 : 162.0;
    final headlineFontSize =
        ResponsiveHelper.getResponsiveFontSize(context, 26);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final maxCardWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, AppColors.deepTeal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: responsivePadding, vertical: responsiveSpacing),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCardWidth),
                  child: GlassCard(
                    padding: EdgeInsets.all(responsivePadding + 6),
                    borderRadius:
                        ResponsiveHelper.getResponsiveBorderRadius(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: logoDimension,
                            height: logoDimension,
                            padding: EdgeInsets.all(responsivePadding * 0.75),
                            decoration: BoxDecoration(
                              color: AppColors.card.withValues(alpha: 0.22),
                              borderRadius:
                                  BorderRadius.circular(logoDimension * 0.2),
                              border: Border.all(
                                  color: AppColors.accentMagenta
                                      .withValues(alpha: 0.24),
                                  width: 1.4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentMagenta
                                      .withValues(alpha: 0.14),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.content_cut,
                                  size: logoDimension * 0.3,
                                  color: AppColors.goldAccent,
                                ),
                                SizedBox(height: responsiveSpacing * 0.4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'StyleSync',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.orbitronHeading(
                                            headlineFontSize * 0.7)
                                        .copyWith(
                                      color: AppColors.goldAccent,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveSpacing),
                        Text(
                          _headline,
                          textAlign: TextAlign.center,
                          style: AppTypography.orbitronHeading(headlineFontSize)
                              .copyWith(
                                  color: AppColors.textPrimary, height: 1.2),
                        ),
                        SizedBox(height: responsiveSpacing * 0.5),
                        Text(
                          'Welcome to StyleSync — book your next haircut in seconds and stay ready for your best look.',
                          textAlign: TextAlign.center,
                          style: AppTypography.interBody(bodyFontSize).copyWith(
                              color: AppColors.textMuted, height: 1.5),
                        ),
                        SizedBox(height: responsiveSpacing + 4),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isLogin)
                                TextFormField(
                                  controller: _emailCtrl,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTypography.interBody(15)
                                      .copyWith(color: AppColors.textPrimary),
                                  decoration: _fieldDecoration("Email"),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Email is required.";
                                    }
                                    if (!value.contains("@")) {
                                      return "Enter a valid email address.";
                                    }
                                    return null;
                                  },
                                )
                              else
                                TextFormField(
                                  controller: _usernameCtrl,
                                  textCapitalization: TextCapitalization.none,
                                  style: AppTypography.interBody(15)
                                      .copyWith(color: AppColors.textPrimary),
                                  decoration: _fieldDecoration("Username"),
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
                              if (!_isLogin) ...[
                                SizedBox(height: responsiveSpacing * 0.6),
                                TextFormField(
                                  controller: _emailCtrl,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTypography.interBody(15)
                                      .copyWith(color: AppColors.textPrimary),
                                  decoration: _fieldDecoration("Email"),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Email is required.";
                                    }
                                    if (!value.contains("@")) {
                                      return "Enter a valid email address.";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: responsiveSpacing * 0.6),
                                Text(
                                  "What's your role?",
                                  style: AppTypography.interBody(14,
                                          weight: FontWeight.w600)
                                      .copyWith(color: AppColors.textPrimary),
                                ),
                                SizedBox(height: responsiveSpacing * 0.4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRoleButton(
                                        role: UserRole.customer,
                                        label: "Customer",
                                        icon: Icons.person,
                                        isSelected:
                                            _selectedRole == UserRole.customer,
                                      ),
                                    ),
                                    SizedBox(width: responsiveSpacing * 0.6),
                                    Expanded(
                                      child: _buildRoleButton(
                                        role: UserRole.barber,
                                        label: "Barber",
                                        icon: Icons.work,
                                        isSelected:
                                            _selectedRole == UserRole.barber,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: responsiveSpacing * 0.6),
                              TextFormField(
                                controller: _passwordCtrl,
                                textCapitalization: TextCapitalization.none,
                                obscureText: !_showPassword,
                                style: AppTypography.interBody(15)
                                    .copyWith(color: AppColors.textPrimary),
                                onChanged: (value) {
                                  setState(() => _currentPassword = value);
                                },
                                decoration:
                                    _fieldDecoration("Password").copyWith(
                                  suffixIcon: IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.accentMagenta,
                                    ),
                                    onPressed: () => setState(
                                        () => _showPassword = !_showPassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password is required.";
                                  }
                                  if (!AuthRepository.isValidPassword(value)) {
                                    return "Use 8–100 characters.";
                                  }
                                  return null;
                                },
                              ),
                              if (!_isLogin) ...[
                                SizedBox(height: responsiveSpacing * 0.5),
                                PasswordStrengthIndicator(
                                  password: _currentPassword,
                                  onStrengthChanged: (isValid) {
                                    // Strength validation callback for future use
                                  },
                                ),
                              ],
                              if (!_isLogin) ...[
                                SizedBox(height: responsiveSpacing * 0.6),
                                TextFormField(
                                  controller: _confirmCtrl,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: !_showPassword,
                                  style: AppTypography.interBody(15)
                                      .copyWith(color: AppColors.textPrimary),
                                  decoration:
                                      _fieldDecoration("Confirm password"),
                                  validator: (value) {
                                    if (value != _passwordCtrl.text) {
                                      return "Passwords must match.";
                                    }
                                    return null;
                                  },
                                ),
                              ] else ...[
                                SizedBox(height: responsiveSpacing * 0.4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _handleForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Forgot password?",
                                      style: AppTypography.interBody(13,
                                              weight: FontWeight.w600)
                                          .copyWith(
                                        color: AppColors.accentMagenta,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: responsiveSpacing),
                        Text(
                          "— Continue with —",
                          textAlign: TextAlign.center,
                          style: AppTypography.interBody(13,
                                  weight: FontWeight.w500)
                              .copyWith(color: AppColors.textMuted),
                        ),
                        if (_error != null) ...[
                          SizedBox(height: responsiveSpacing * 0.7),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsivePadding,
                                vertical: responsivePadding * 0.75),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.shade700.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveBorderRadius(
                                      context)),
                              border: Border.all(
                                  color: Colors.red.shade700
                                      .withValues(alpha: 0.32)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 22),
                                SizedBox(width: responsivePadding * 0.75),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: AppTypography.interBody(13,
                                            weight: FontWeight.w600)
                                        .copyWith(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: responsiveSpacing * 0.75),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            children: [
                              _buildSocialButton(
                                icon: Icons.g_mobiledata,
                                label: "Sign in with Google",
                                enabled: OAuthConfig.isGoogleConfigured,
                                width: double.infinity,
                                height: responsiveButtonHeight,
                                onTap: () => _socialSignIn(() => ref
                                    .read(authRepositoryProvider)
                                    .signInWithGoogle(
                                      roleForNewAccount: _isLogin
                                          ? null
                                          : _selectedRole,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsiveSpacing),
                        SizedBox(
                          width: double.infinity,
                          height: responsiveButtonHeight,
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentMagenta,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor: AppColors.textMuted,
                              disabledForegroundColor: AppColors.background,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              _isLogin
                                  ? Icons.login_rounded
                                  : Icons.person_add_rounded,
                              size: 22,
                            ),
                            label: Text(
                              _actionLabel,
                              style: AppTypography.interBody(16,
                                  weight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveSpacing * 0.7),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    HapticFeedback.selectionClick();
                                    // Prevent redirect loop when already signed in.
                                    final current = ref
                                        .read(firebaseAuthProvider)
                                        .currentUser;
                                    final target = _isLogin
                                        ? AppRoutes.register
                                        : AppRoutes.login;
                                    if (current == null) {
                                      context.go(target);
                                      return;
                                    }

                                    // If user is already signed in, confirm sign out
                                    final doSignOut = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.card,
                                        title: Text('Already signed in',
                                            style: AppTypography.orbitronHeading(
                                                16)),
                                        content: Text(
                                          'You are currently signed in. Sign out to create a new account?',
                                          style: AppTypography.interBody(14)
                                              .copyWith(
                                                  color: AppColors.textMuted),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text('Cancel',
                                                  style: AppTypography.interBody(14)
                                                      .copyWith(
                                                          color: AppColors.textMuted))),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: Text('Sign out & continue',
                                                  style: AppTypography.interBody(14,
                                                          weight: FontWeight.w700))),
                                        ],
                                      ),
                                    );

                                    if (doSignOut == true) {
                                      await ref
                                          .read(authRepositoryProvider)
                                          .signOut();
                                      if (!mounted) return;
                                      // After sign-out, navigate to target (register/login)
                                      context.go(target);
                                    }
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentMagenta,
                              disabledForegroundColor: AppColors.textMuted,
                              padding: EdgeInsets.symmetric(
                                  vertical: responsivePadding * 0.75),
                            ),
                            child: Text(
                              _switchLabel,
                              textAlign: TextAlign.center,
                              style: AppTypography.interBody(14,
                                  weight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive social login button with hover effects and animations
class _SocialButtonWidget extends StatefulWidget {
  const _SocialButtonWidget({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.width = 56,
    this.height = 56,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  State<_SocialButtonWidget> createState() => _SocialButtonWidgetState();
}

class _SocialButtonWidgetState extends State<_SocialButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (widget.onTap == null) return;
    setState(() => _isHovering = true);
    _scaleController.forward();
  }

  void _onExit() {
    setState(() => _isHovering = false);
    _scaleController.reverse();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => enabled ? _onEnter() : null,
        onExit: (_) => enabled ? _onExit() : null,
        child: GestureDetector(
          onTap: enabled ? _onTap : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(widget.width > 120 ? 12 : 28),
                color: widget.width > 120
                    ? (enabled
                        ? AppColors.card
                        : AppColors.card.withValues(alpha: 0.5))
                    : null,
                shape:
                    widget.width > 120 ? BoxShape.rectangle : BoxShape.circle,
                gradient: widget.width > 120
                    ? LinearGradient(
                        colors: enabled
                            ? (_isHovering
                                ? [
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.20),
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.08)
                                  ]
                                : [
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.12),
                                    AppColors.card.withValues(alpha: 0.98)
                                  ])
                            : [
                                AppColors.card.withValues(alpha: 0.3),
                                AppColors.card.withValues(alpha: 0.15)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : RadialGradient(
                        colors: enabled
                            ? (_isHovering
                                ? [
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.42),
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.18)
                                  ]
                                : [
                                    AppColors.accentMagenta
                                        .withValues(alpha: 0.26),
                                    AppColors.card.withValues(alpha: 0.92)
                                  ])
                            : [
                                AppColors.card.withValues(alpha: 0.18),
                                AppColors.card.withValues(alpha: 0.12)
                              ],
                        center: const Alignment(-0.3, -0.3),
                        radius: 0.95,
                      ),
                border: Border.all(
                  color: widget.width > 120
                      ? (enabled
                          ? (_isHovering
                              ? AppColors.accentMagenta.withValues(alpha: 0.60)
                              : AppColors.accentMagenta.withValues(alpha: 0.40))
                          : AppColors.textMuted.withValues(alpha: 0.28))
                      : enabled
                          ? (_isHovering
                              ? AppColors.accentMagenta.withValues(alpha: 0.55)
                              : AppColors.accentMagenta.withValues(alpha: 0.35))
                          : AppColors.textMuted.withValues(alpha: 0.28),
                  width: _isHovering && enabled ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: enabled
                        ? (_isHovering
                            ? AppColors.accentMagenta.withValues(alpha: 0.16)
                            : AppColors.accentMagenta.withValues(alpha: 0.10))
                        : AppColors.textMuted.withValues(alpha: 0.12),
                    blurRadius: _isHovering && enabled ? 20 : 12,
                    spreadRadius: _isHovering && enabled ? 2 : 1,
                  ),
                ],
              ),
              child: widget.width > 120
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            size: 24,
                            color: enabled
                                ? AppColors.accentMagenta
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: AppTypography.interBody(14,
                                      weight: FontWeight.w600)
                                  .copyWith(
                                color: enabled
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Icon(
                      widget.icon,
                      size: 26,
                      color: enabled
                          ? (_isHovering
                              ? AppColors.accentMagenta
                              : AppColors.white)
                          : AppColors.textMuted,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
