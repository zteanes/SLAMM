/// This file outlines the tab bar used through every screen of our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 04/16/2025
/// Version: 1.0
library;

import 'package:flutter/material.dart';
import 'package:SLAMM/analytics_screen.dart';
import 'package:SLAMM/camera.dart';
import 'package:SLAMM/settings.dart';

/// This file outlines the tab bar used through every screen of our application.
class BottomTabBar extends StatefulWidget {
  /// This widget is used to create the bottom tab bar for the application.
  const BottomTabBar({super.key});

  @override
  State<BottomTabBar> createState() => BottomTabBarState();
}

/// State of the tab bar
class BottomTabBarState extends State<BottomTabBar> {

  /// Builds the bottom tab bar
  /// 
  /// Parameters:
  ///  context - the build context for the widget
  /// 
  /// Returns:
  ///  A widget that is used to build the bottom tab bar
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // sets the button for analytics
            IconButton(
                color: Theme.of(context).colorScheme.secondary,
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
                        const begin = Offset(-0.8, 0.0); // left-to-right transition
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
                },
            ),


            // sets the button for the camera
            IconButton(
                color: Theme.of(context).colorScheme.secondary,
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != "camera") {
                    // we're navigating to the analytics screen, so slide screen in accordingly
                    if (ModalRoute.of(context)?.settings.name == "analytics") {
                      Navigator.of(context).push(PageRouteBuilder(
                        settings: const RouteSettings(name: "camera"),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, animation, 
                                      secondaryAnimation) => const CameraScreen(), 
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.8, 0.0); // left-to-right transition
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
                  }
                },
            ),
            // sets the button for the settings
            IconButton(
                color: Theme.of(context).colorScheme.secondary,
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
                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}
