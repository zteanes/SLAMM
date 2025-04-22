/// This is the main file used to launch our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 04/16/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SLAMM/settings.dart';
import 'package:lock_orientation_screen/lock_orientation_screen.dart';
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

/// Define a ValueNotifier for theme mode
final themeNotifier = ValueNotifier(ThemeMode.system);

/// list of the cameras available
List<CameraDescription> cameras = [];

/// path to the temp directory to store all files
String tempDirectoryPath = "";

/// Main function that is our entry point to initialize the application.
Future<void> main() async {
  // ensures that the widgets are initialized
  WidgetsFlutterBinding.ensureInitialized(); 

  // get the list of available cameras
  cameras = await availableCameras(); 

  // initialize the firebase/firestore application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  

  // ensure settings carry over between sessions
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );

  // start the app
  runApp(const MyApp());
}

/// This is the main widget for the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the application from the main widget.
  /// 
  /// Returns:
  ///  Either the welcome page or analytics page depending on if a user is logged in.
  @override
  Widget build(BuildContext context) {
    return LockOrientation (
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, _) {
          User? user = FirebaseAuth.instance.currentUser;
          return MaterialApp(
            title: 'Welcome Screen',
            // sets the themed modes for the application
            theme: lightmode,
            darkTheme: darkmode,
      
            // sets the mode to the system mode
            themeMode: currentTheme,
      
            // go to the analytics screen if a user is logged in, otherwise the welcome screen
            home: user != null ? const AnalyticsScreen() : const WelcomeScreen(),
            routes: {
              // routes to every screen in the application
              "analytics": (context) => const AnalyticsScreen(),
              "welcome": (context) => const WelcomeScreen(),
              "camera": (context) => const CameraScreen(),
              "settings": (context) => const SettingsScreen(),
              "explanation": (context) => const ExplanationScreen(),
              "signup" : (context) => const Signup(),
              "login" : (context) => Login(),
            },
          );
        },
      ),
    );
  }
}
