import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'constants.dart';
import 'analytics_screen.dart';
import 'camera.dart';
import 'theme.dart';
import 'welcome.dart';

// Define a ValueNotifier for theme mode
final themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Welcome Screen',
          theme: lightmode,
          darkTheme: darkmode,
          themeMode: currentTheme,
          home: const WelcomeScreen(),
          routes: {
            "analytics": (context) => const AnalyticsScreen(),
            "welcome": (context) => const WelcomeScreen(),
            "camera": (context) => const CameraScreen(),
            "settings": (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}