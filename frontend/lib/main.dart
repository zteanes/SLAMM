/// This is the main file used to launch our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'analytics_screen.dart';
import 'camera.dart';
import 'theme.dart';
import 'welcome.dart';
import 'explanation.dart';
import 'package:camera/camera.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
    );
  // gets the path and creates the temp directory
  //tempDirectoryPath = await CameraScreenState().tempDirPath();
  // delete anything left over from a previous run
  //CameraScreenState().deleteTempDir();
  // remake it for this run
  //tempDirectoryPath = await CameraScreenState().tempDirPath();
  print("about to run the app");
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
          },
        );
      },
    );
  }
}
