/// This file contains all the logic and widgets used to create the Welcome screen in our
/// application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  /// This widget is used to create the welcome screen for the application.
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // used to check if we're in light or dark mode
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // background image
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/temp-splash.jpg',
                  fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.center,
            // Title welcome text
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                Text(
                  'Welcome to',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 36),
                ),
                Text(
                  'SLAMM',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 45, right: 45),
                  // Subtitle welcome text
                  child: Text(
                    'Sign Language Analytics and Mobile Machine Learning',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  // button and text to start the application
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Let's Get Started",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary)),
                    // open our next page, the analytics page
                    onPressed: () {
                      Navigator.of(context).pushNamed("analytics");
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 300,
                  // button and text to sign in
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Sign In",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary)),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
