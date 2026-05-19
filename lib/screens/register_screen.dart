import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/features/auth/presentation/widgets/password_strength_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String _selectedRole = "customer";
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  int _passwordStrength = 0;
  String _currentPassword = ""; // Track current password for strength widget

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  int _calcStrength(String pw) {
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r"[A-Z]"))) score++;
    if (pw.contains(RegExp(r"[0-9]"))) score++;
    if (pw.contains(RegExp(r"[!@#$%^&*]"))) score++;
    return score;
  }

  Color _strengthColor() {
    if (_passwordStrength <= 1) return AppColors.kDanger;
    if (_passwordStrength == 2) return AppColors.kGold;
    if (_passwordStrength == 3) return AppColors.kAccent.withOpacity(0.7);
    return AppColors.kAccent;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) return;
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _withRetry(() => FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user!.uid)
          .set({
        "uid": cred.user!.uid,
        "email": _emailController.text.trim(),
        "displayName": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "role": _selectedRole,
        "isVerified": false,
        "xpPoints": 0,
        "level": 1,
        "createdAt": FieldValue.serverTimestamp(),
      }));
      if (_selectedRole == "barber") {
        if (mounted) context.go("/barber/apply");
      } else {
        if (mounted) context.go("/verify-email");
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ?? "Registration failed"),
            backgroundColor: AppColors.kDanger),
      );
    } on FirebaseException catch (e) {
      // Handle Firestore errors (transient/unavailable etc.) with user-friendly message
      final msg = (e.code == 'unavailable')
          ? 'Service currently unavailable. Please try again.'
          : (e.message ?? 'Registration failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.kDanger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<T> _withRetry<T>(Future<T> Function() fn,
      {int maxAttempts = 4}) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        if (e is FirebaseException && e.code == 'unavailable') {
          final backoff = Duration(milliseconds: 500 * (1 << (attempt - 1)));
          await Future.delayed(backoff);
          continue;
        }
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Create Account',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kText),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join the StyleSync community today',
                style: TextStyle(fontSize: 13, color: AppColors.kMuted),
              ),
              const SizedBox(height: 24),
              // Role selector
              const Text(
                'Step 1: Select Your Role',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kText),
              ),
              const Text(
                'Choose how you want to use StyleSync',
                style: TextStyle(fontSize: 13, color: AppColors.kMuted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = "customer"),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedRole == "customer"
                                ? AppColors.kAccent
                                : AppColors.kBorder,
                            width: 1.5,
                          ),
                          color: _selectedRole == "customer"
                              ? AppColors.kAccent.withOpacity(0.1)
                              : AppColors.kCard2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 36,
                                color: _selectedRole == "customer"
                                    ? AppColors.kAccent
                                    : AppColors.kMuted),
                            const SizedBox(height: 8),
                            Text('Customer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == "customer"
                                      ? AppColors.kAccent
                                      : AppColors.kText,
                                )),
                            const Text('Get haircuts & services',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.kMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = "barber"),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedRole == "barber"
                                ? AppColors.kAccent
                                : AppColors.kBorder,
                            width: 1.5,
                          ),
                          color: _selectedRole == "barber"
                              ? AppColors.kAccent.withOpacity(0.1)
                              : AppColors.kCard2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.content_cut,
                                size: 36,
                                color: _selectedRole == "barber"
                                    ? AppColors.kAccent
                                    : AppColors.kMuted),
                            const SizedBox(height: 8),
                            Text('Barber',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == "barber"
                                      ? AppColors.kAccent
                                      : AppColors.kText,
                                )),
                            const Text('Offer haircut services',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.kMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form
              const Text(
                'Step 2: Account Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kText),
              ),
              const Text(
                'Create your login credentials',
                style: TextStyle(fontSize: 13, color: AppColors.kMuted),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.kMuted),
                        filled: true,
                        fillColor: AppColors.kCard2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.kAccent, width: 1.5),
                        ),
                      ),
                      validator: (v) => (v?.trim().length ?? 0) < 2
                          ? "Enter your full name"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.mail_outline,
                            color: AppColors.kMuted),
                        filled: true,
                        fillColor: AppColors.kCard2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.kAccent, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if ((v?.isEmpty ?? true)) return "Email required";
                        if (!(v?.contains("@") ?? false)) {
                          return "Valid email required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AppColors.kMuted),
                        filled: true,
                        fillColor: AppColors.kCard2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                      ),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? "Phone number required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      textCapitalization: TextCapitalization.none,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.kMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.kMuted),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                        filled: true,
                        fillColor: AppColors.kCard2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _currentPassword = v;
                          _passwordStrength = _calcStrength(v);
                        });
                      },
                      validator: (v) =>
                          (v?.length ?? 0) < 8 ? "Min. 8 characters" : null,
                    ),
                    const SizedBox(height: 12),
                    // Advanced password strength indicator with breach detection
                    PasswordStrengthIndicator(
                      password: _currentPassword,
                      onStrengthChanged: (isValid) {
                        setState(() => _passwordStrength = isValid ? 3 : 1);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      textCapitalization: TextCapitalization.none,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.kMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.kMuted),
                          onPressed: () => setState(() =>
                              _showConfirmPassword = !_showConfirmPassword),
                        ),
                        filled: true,
                        fillColor: AppColors.kCard2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.kBorder),
                        ),
                      ),
                      validator: (v) => v != _passwordController.text
                          ? "Passwords do not match"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.kAccent,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v ?? false),
                        ),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                  color: AppColors.kText, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                      color: AppColors.kAccent,
                                      decoration: TextDecoration.underline),
                                ),
                                TextSpan(
                                    text: ' and ',
                                    style: TextStyle(color: AppColors.kText)),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                      color: AppColors.kAccent,
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (!_agreedToTerms ||
                              _passwordStrength < 2 ||
                              _isLoading)
                          ? null
                          : _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kAccent,
                        disabledBackgroundColor:
                            AppColors.kAccent.withOpacity(0.5),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(AppColors.kBg),
                              ),
                            )
                          : const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kBg)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?  ',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.kMuted)),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign In',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kAccent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
