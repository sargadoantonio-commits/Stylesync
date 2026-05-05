import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "core/bootstrap/firebase_bootstrap.dart";
import "core/router/app_router.dart";
import "core/theme/app_theme.dart";

Future<void> main() async {
  await bootstrapFirebase();
  runApp(const ProviderScope(child: StyleSyncApp()));
}

class StyleSyncApp extends ConsumerWidget {
  const StyleSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "StyleSync",
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
    );
  }
}
