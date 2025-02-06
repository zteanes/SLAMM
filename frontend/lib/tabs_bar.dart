/// This file outlines the tab bar used through every screen of our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';
import 'package:frontend/analytics_screen.dart';
import 'package:frontend/camera.dart';
import 'package:frontend/settings.dart';

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
    return SizedBox(
      height: 80,
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // sets the button for analytics
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.analytics),
                // navigate to screen unless we're only on that screen
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != "analytics") {
                    Navigator.of(context).push(PageRouteBuilder(
                      settings: const RouteSettings(name: "analytics"),
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animation, 
                                    secondaryAnimation) => const AnalyticsScreen(), 
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-0.8, 0.0); // Left-to-right transition
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ));
                    CameraScreenState().deleteTempDir();
                  }
                },
            ),


            // sets the button for the camera
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != "camera") {
                    if (ModalRoute.of(context)?.settings.name == "analytics") {
                      Navigator.of(context).push(PageRouteBuilder(
                        settings: const RouteSettings(name: "camera"),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, animation, 
                                      secondaryAnimation) => const CameraScreen(), 
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.8, 0.0); // Right-to-left transition
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ));
                    } 
                    else {
                      Navigator.of(context).push(PageRouteBuilder(
                        settings: const RouteSettings(name: "camera"),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, animation, 
                                      secondaryAnimation) => const CameraScreen(), 
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-0.8, 0.0); // Right-to-left transition
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ));
                    }
                    CameraScreenState().deleteTempDir();
                  }
                },
            ),
            // sets the button for the settings
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.settings),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != "settings") {
                    Navigator.of(context).push(PageRouteBuilder(
                      settings: const RouteSettings(name: "settings"),
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animation, 
                                    secondaryAnimation) => const SettingsScreen(), 
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.8, 0.0); // Right-to-left transition
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ));
                    CameraScreenState().deleteTempDir();
                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}
