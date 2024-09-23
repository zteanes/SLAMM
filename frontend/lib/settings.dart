import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

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
                const Text(
                  'Settings',
                  style: TextStyle(color: primaryColor, fontSize: 36),
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
              color: primaryColor,
              icon: const Icon(Icons.analytics),
              tooltip: "Analytics",
              onPressed: () => Navigator.pushNamed(context, "analytics")
            ),
            IconButton( 
              color: primaryColor,
              tooltip: "Camera",
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => Navigator.pushNamed(context, "camera")
            ),
            IconButton( 
              color: primaryColor,
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
