/// This file outlines the tab bar used through every screen of our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';

class BottomTabBar extends StatefulWidget {
  /// This widget is used to create the bottom tab bar for the application.
  const BottomTabBar({super.key});

  @override
  State<BottomTabBar> createState() => BottomTabBarState();
}

class BottomTabBarState extends State<BottomTabBar> {
  /// Sets up the bottom tab bar for the application
  /// Builds the bottom tab bar
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // sets the button for analytics
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.analytics),
                onPressed: () => Navigator.pushNamed(context, "analytics")),
            // sets the button for the camera
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () => Navigator.pushNamed(context, "camera")),
            // sets the button for the settings
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, "settings")),
          ],
        ),
      ),
    );
  }
}
