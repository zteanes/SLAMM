import 'package:flutter/material.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Screen',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: bgColor,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
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
              const SizedBox(height: 200),
              const Text(
                'Welcome to', 
                style: TextStyle(color: primaryColor, fontSize: 36),
              ),
              const Text(
                'SLAMM', 
                style: TextStyle(color: primaryColor, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 45, right: 45),
                child: Text(
                  'Sign Language Analytics and Mobile Machine Learning',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                  ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // darken color on hover 
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Let's Get Started", style: TextStyle(fontSize: 20, color: Colors.white)), 
                onPressed: () {},
              ),
            ],
          ),
        ),
      ], 
    ),
  );}
}

