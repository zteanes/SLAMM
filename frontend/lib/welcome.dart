/// This file contains all the logic and widgets used to create the Welcome screen in our
/// application. 
/// 
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
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
              const SizedBox(height: 200),
              Text(
                'Welcome to', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 36),
              ),
              Text(
                'SLAMM', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary, 
                                 fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 45, right: 45),
                child: Text(
                  'Sign Language Analytics and Mobile Machine Learning',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 24),
                  textAlign: TextAlign.center,
                  ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Let's Get Started", style: TextStyle(fontSize: 20, 
                                                color: Theme.of(context).colorScheme.secondary)), 
                  // open our next page, the analytics page
                  onPressed: () {
                    Navigator.of(context).pushNamed("analytics");
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Sign In", style: TextStyle(fontSize: 20, 
                                                color: Theme.of(context).colorScheme.primary)),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      ], 
    ),
  );}
}

