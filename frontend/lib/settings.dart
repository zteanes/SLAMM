/// This file outlines the settings screen used for our application and the
/// necessary logic associated with it.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';
import 'package:frontend/tabs_bar.dart';

/// used for the theme notifier
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  /// Sets up the settings screen for the application
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  /// Builds the settings screen including all buttons, text, options
  @override
  Widget build(BuildContext context) {
    /// Get the system brightness
    var brightness = MediaQuery.of(context).platformBrightness;

    // change the value of the themeNotifier based on the system brightness
    if (themeNotifier.value == ThemeMode.system) {
      themeNotifier.value =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    // The scaffold is the main container for the settings screen
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Positioned.fill(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text that says "Settings" in the middle of the screen
                Text(
                  'Settings',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 36),
                ),
                // spacing box to separate elements
                const SizedBox(height: 20), 
                // Text that says "Toggle between Light and Dark mode"
                Text(
                  'Toggle between Light and Dark mode',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16),
                ),
                // listen to the theme notifier and update the switch accordingly
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // add light mode icon surrounding the switch
                    const Icon(Icons.light_mode),

                    // spacing to separate
                    const SizedBox(width: 10),

                    // our switch to change the theme of the app
                    ValueListenableBuilder(
                      valueListenable: themeNotifier,
                      builder: (context, ThemeMode currentTheme, _) {
                        // switch to actually go between light and dark mode
                        return Switch(
                          // if the current theme is dark, set the switch to true
                          value: currentTheme == ThemeMode.dark,
                          onChanged: (isDarkMode) {
                            print(currentTheme);
                            setState(() {
                              // change value of themeNotifier based on the switch
                              themeNotifier.value =
                                  isDarkMode ? ThemeMode.dark : ThemeMode.light;
                            });
                          },
                          activeTrackColor:
                              Theme.of(context).colorScheme.secondary,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),

                    // another spacing
                    const SizedBox(width: 10),

                    // icon for dark mode
                    const Icon(Icons.dark_mode),
                  ],
                ),
                const SizedBox(height: 220), // temporary height spacing for skeleton screen
                // makes the button to go back to the welcome page
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
      // add the bottom navigation bar to the bottom of the screen
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
