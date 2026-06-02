import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenfix_ai/core/constants/app_constants.dart';
import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/routing/app_router.dart';

class ScreenFixApp extends StatelessWidget {
  const ScreenFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}
