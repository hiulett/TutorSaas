import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class TutorSaaSApp extends StatelessWidget {
  const TutorSaaSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TutorSaaS',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to premium dark mode
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
