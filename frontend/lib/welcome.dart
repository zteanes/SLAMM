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
          // button to explain what application is
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 25),
              child: ElevatedButton(
                // when pressed navigate to explanation screen
                onPressed: () {
                  Navigator.of(context).pushNamed("explanation");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: CircleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary,
                    width: 2
                    ),
                  ), 
                ),
                child: const Icon(Icons.question_mark_rounded, size: 20),
              ),
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
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.secondary,
                        )
                    ),
                    // open to the signup page 
                    onPressed: () {
                      Navigator.of(context).pushNamed("signup");
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 300,
                  // button and text to sign in
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Sign In",
                      style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.primary,
                        )
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("login");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
