import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screenfix_ai/routing/route_paths.dart';

class AppRouter {
  final GoRouter router;

  AppRouter()
    : router = GoRouter(
        initialLocation: RoutePaths.home,
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (_, __) => const _HomePage(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (_, __) => const _SettingsPage(),
          ),
        ],
        errorBuilder: (_, __) => const _NotFoundPage(),
      );
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ScreenFix AI'),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('The requested page does not exist.')),
    );
  }
}
