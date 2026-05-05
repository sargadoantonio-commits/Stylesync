import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/shop_selection/shop_selection_providers.dart";
import "../domain/user_role.dart";
import "../../../screens/customer/home_screen.dart";
import "auth_screen.dart";
import "providers/auth_providers.dart";

/// Single entrypoint that decides where to send the user:
/// - unauthenticated -> login
/// - email/password & not verified -> verify screen (Format C)
/// - verified -> role-based dashboard
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  Future<void>? _ensureFuture;

  @override
  Widget build(BuildContext context) {
    // Load persisted shop selection once per session.
    ref.watch(selectedShopIdLoaderProvider);

    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      loading: () => const _GateScaffold(child: _GateLoading()),
      error: (e, _) => _GateScaffold(child: _GateError(message: e.toString())),
      data: (user) {
        if (user == null) return const AuthScreen(mode: AuthMode.login);

        _ensureFuture ??=
            ref.read(authRepositoryProvider).ensureUserDocument(user);
        return FutureBuilder<void>(
          future: _ensureFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const _GateScaffold(child: _GateLoading());
            }

            final profileAsync = ref.watch(userProfileProvider);
            return profileAsync.when(
              loading: () => const _GateScaffold(child: _GateLoading()),
              error: (e, _) =>
                  _GateScaffold(child: _GateError(message: e.toString())),
              data: (profile) {
                if (profile == null) {
                  return const _GateScaffold(child: _GateLoading());
                }

                switch (profile.role) {
                  case UserRole.shopOwner:
                  case UserRole.barber:
                  case UserRole.customer:
                    return const HomeScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}

class _GateScaffold extends StatelessWidget {
  const _GateScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text("Syncing your session…", style: AppTypography.interBody(14)),
      ],
    );
  }
}

class _GateError extends StatelessWidget {
  const _GateError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Text(message,
        style: AppTypography.interBody(14).copyWith(color: Colors.redAccent));
  }
}
