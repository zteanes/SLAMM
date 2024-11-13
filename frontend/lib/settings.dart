import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'main.dart'; // used for the theme notifier

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/temp-splash.jpg', fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'Toggle between light and dark mode',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                ),
                // listen to the theme notifier and update the switch accordingly
                ValueListenableBuilder(
                  valueListenable: themeNotifier,
                  builder: (context, ThemeMode currentTheme, _) {
                    // switch to actually go between light and dark mode
                    return Switch(
                      value: currentTheme == ThemeMode.dark, // if the current theme is dark, set the switch to true
                      onChanged: (isDarkMode) {
                        setState(() {
                          // change value of themeNotifier based on the switch
                          themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                        });
                      },
                      activeTrackColor: Theme.of(context).colorScheme.secondary,
                      activeColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
                const SizedBox(height: 200),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Go back", style: TextStyle(fontSize: 20, color: Colors.black)), 
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.analytics),
              tooltip: "Analytics",
              onPressed: () => Navigator.pushNamed(context, "analytics")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              tooltip: "Camera",
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => Navigator.pushNamed(context, "camera")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              tooltip: "Settings",
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, "settings")
            ),
          ],
        ),
      ),
    );
  }
}
