import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/router/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        border: Border(
          top: BorderSide(
            color: AppColors.accentMagenta.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _NavBarItem(
                icon: Icons.home_rounded,
                label: "Home",
                isActive: currentRoute == AppRoutes.home,
                onTap: () => context.go(AppRoutes.home),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.explore_rounded,
                label: "Discover",
                isActive: currentRoute == AppRoutes.discover,
                onTap: () => context.push(AppRoutes.discover),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.calendar_today_rounded,
                label: "Bookings",
                isActive: currentRoute == AppRoutes.booking || currentRoute == AppRoutes.myBookings,
                onTap: () => context.push(AppRoutes.myBookings),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.palette_outlined,
                label: "Styles",
                isActive: currentRoute == AppRoutes.styleLibrary,
                onTap: () => context.push(AppRoutes.styleLibrary),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.person_rounded,
                label: "Account",
                isActive: currentRoute == AppRoutes.settings,
                onTap: () => context.push(AppRoutes.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accentMagenta.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    isActive ? AppColors.accentMagenta : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.interBody(9, weight: FontWeight.w600)
                  .copyWith(
                color:
                    isActive ? AppColors.accentMagenta : AppColors.textMuted,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.accentMagenta,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
