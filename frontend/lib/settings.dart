import 'package:flutter/material.dart';
import 'package:frontend/tabs_bar.dart';
import 'main.dart'; // used for the theme notifier

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
  // get the system brightness
  var brightness = MediaQuery.of(context).platformBrightness;

  // change the value of the themeNotifier based on the system brightness
  if (themeNotifier.value == ThemeMode.system) {
    themeNotifier.value = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
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
                  'Toggle between Light and Dark mode',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                ),
                // listen to the theme notifier and update the switch accordingly
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // add light mode icon surrounding the switch
                    const Icon(Icons.light_mode),

                    // spacing to separate
                    const SizedBox(width:10),

                    // our switch to change the theme of the app
                    ValueListenableBuilder(
                      valueListenable: themeNotifier,
                      builder: (context, ThemeMode currentTheme, _) {
                        // switch to actually go between light and dark mode
                        return Switch(
                          value: currentTheme == ThemeMode.dark, // if the current theme is dark, set the switch to true
                          onChanged: (isDarkMode) {
                            print(currentTheme);
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

                    // another spacing 
                    const SizedBox(width:10),

                    // icon for dark mode
                    const Icon(Icons.dark_mode),
                  ],
                ),
                const SizedBox(height: 200),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
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
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
