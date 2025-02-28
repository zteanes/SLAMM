/// This is the main file used to launch our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 02/25/2025
library;

import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'analytics_screen.dart';
import 'camera.dart';
import 'theme.dart';
import 'welcome.dart';
import 'explanation.dart';
import 'package:camera/camera.dart';
import 'signup.dart';
import 'login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Define a ValueNotifier for theme mode
final themeNotifier = ValueNotifier(ThemeMode.system);

// list of the cameras available
List<CameraDescription> cameras = [];

// path to the temp directory to store all files
String tempDirectoryPath = "";

Future<void> main() async {
  /// This function initializes the cameras available on the device.
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  // initialize the firebase application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// This widget is the root of our application, used to create the application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Welcome Screen',
          // sets the themed modes for the application
          theme: lightmode,
          darkTheme: darkmode,
          // sets the mode to the system mode
          themeMode: currentTheme,
          home: const WelcomeScreen(),
          routes: {
            // routes to every screen in the application
            "analytics": (context) => const AnalyticsScreen(),
            "welcome": (context) => const WelcomeScreen(),
            "camera": (context) => const CameraScreen(),
            "settings": (context) => const SettingsScreen(),
            "explanation": (context) => const ExplanationScreen(),
            "signup" : (context) => Signup(),
            "login" : (context) => Login(),
          },
        );
      },
    );
  }
}
