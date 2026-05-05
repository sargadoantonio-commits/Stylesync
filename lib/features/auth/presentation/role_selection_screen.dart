import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/core/router/app_routes.dart";
import "package:stylesync/features/auth/domain/user_role.dart";
import "package:stylesync/features/auth/presentation/providers/auth_providers.dart";

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "Choose Your Role",
                style: AppTypography.orbitronHeading(32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Select whether you're a customer looking for haircuts or a barber offering services",
                style: AppTypography.interBody(16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Customer Card
              _RoleCard(
                title: "Customer",
                description:
                    "Book haircuts, discover styles, and find barbers near you",
                icon: Icons.person,
                isSelected: _selectedRole == UserRole.customer,
                onTap: () => setState(() => _selectedRole = UserRole.customer),
              ),
              const SizedBox(height: 24),
              // Barber Card
              _RoleCard(
                title: "Barber",
                description:
                    "Manage your services, accept bookings, and build your portfolio",
                icon: Icons.work,
                isSelected: _selectedRole == UserRole.barber,
                onTap: () => setState(() => _selectedRole = UserRole.barber),
              ),
              const SizedBox(height: 60),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: StyleButton(
                  label: _loading ? "Setting up..." : "Continue",
                  onPressed: _selectedRole == null || _loading
                      ? null
                      : () => _handleContinue(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_selectedRole == null) return;

    setState(() => _loading = true);

    try {
      final auth = ref.read(firebaseAuthProvider);
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("User not found. Please log in again.")),
          );
          context.go(AppRoutes.login);
        }
        return;
      }

      // Update user role in Firestore
      final authRepository = ref.read(authRepositoryProvider);
      final selectedRole = _selectedRole;
      final navigatorContext = context;

      await authRepository.updateUserRole(currentUser.uid, selectedRole!);

      if (mounted) {
        // Determine navigation route based on role
        final route = switch (selectedRole) {
          UserRole.barber => AppRoutes.barberHome,
          UserRole.customer => AppRoutes.customerHome,
          UserRole.shopOwner => AppRoutes.shopOwnerHome,
        };
        if (mounted) navigatorContext.go(route);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentMagenta.withValues(alpha: 0.15)
              : AppColors.card.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected
                ? AppColors.accentMagenta
                : AppColors.textMuted.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentMagenta.withValues(alpha: 0.2)
                        : AppColors.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.accentMagenta
                        : AppColors.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.orbitronHeading(20,
                            weight: FontWeight.w700)
                        .copyWith(
                      color: isSelected
                          ? AppColors.accentMagenta
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accentMagenta,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.background,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTypography.interBody(14).copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
