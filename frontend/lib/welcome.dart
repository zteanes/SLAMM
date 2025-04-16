/// This file contains all the logic and widgets used to create the Welcome screen in our
/// application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 04/16/2025
library;

import 'package:flutter/material.dart';

/// This file contains all the logic and widgets used to create the Welcome screen in our
/// application.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

/// State class for the Welcome screen
class WelcomeScreenState extends State<WelcomeScreen> {

  /// Builds the welcome screen
  /// 
  /// Parameters:
  ///  context - the build context for the widget
  /// 
  /// Returns:
  ///  A widget that is used to build the welcome screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // background image
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/splash.jpg',
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
