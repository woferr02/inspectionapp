import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/theme_notifier.dart';
import 'package:health_safety_inspection/theme/app_theme.dart';
import 'package:health_safety_inspection/routes.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // TODO: Send to Crashlytics in production
    };

    await AuthService.instance.initialize();

    // Enable offline persistence so inspections work without connectivity.
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {}

    await RevenueCatService.instance.initialize();
    await ThemeNotifier.instance.initialize();
    runApp(const HealthSafetyApp());
  }, (error, stack) {
    // Global catch-all for unhandled async errors.
    // TODO: Send to Crashlytics in production
    debugPrint('Unhandled error: $error\n$stack');
  });
}

class HealthSafetyApp extends StatelessWidget {
  const HealthSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier.instance;

    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Health & Safety Inspector',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.mode,
          initialRoute: Routes.login,
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}
