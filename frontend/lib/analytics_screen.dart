/// This file contains the AnalyticsScreen widget, which is the screen that displays
/// the analytics page.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';
import 'package:frontend/tabs_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6, // set the opacity of the background image
              child: Image.asset('assets/images/temp-splash.jpg',
                  fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Analytics',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 36),
                ),
                const SizedBox(height: 220), // temporary height spacing for skeleton screen
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Go back",
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                    // go back to the welcome/landing page
                    onPressed: () {
                      Navigator.pushNamed(context, "welcome");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // add our bottom tab bar
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
