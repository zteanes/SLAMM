import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'constants.dart';
import 'analytics_screen.dart';
import 'camera.dart';
import 'theme.dart';
import 'welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ThemeMode themeMode = ThemeMode.system;
    return MaterialApp(
      title: 'Welcome Screen',
      home: const WelcomeScreen(),
      theme: lightmode,
      darkTheme: darkmode,
      routes: {
        "analytics": (context) => const AnalyticsScreen(),
        "welcome": (context) => const WelcomeScreen(),
        "camera": (context) => const CameraScreen(),
        "settings": (context) => const SettingsScreen(),
      }
    );
  }
}

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//       children: [
//         Positioned.fill(
//           child: Opacity(
//             opacity: 0.6,
//             child: Image.asset('assets/images/temp-splash.jpg', fit: BoxFit.cover),
//           ),
//         ),
//         Align(
//           alignment: Alignment.center,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 200),
//               Text(
//                 'Welcome to', 
//                 style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 36),
//               ),
//               Text(
//                 'SLAMM', 
//                 style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 48, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: EdgeInsets.only(left: 45, right: 45),
//                 child: Text(
//                   'Sign Language Analytics and Mobile Machine Learning',
//                   style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 24),
//                   textAlign: TextAlign.center,
//                   ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: 300,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text("Let's Get Started", style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary)), 
//                   // open our next page, the analytics page
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 width: 300,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.secondary,
//                     padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text("Sign In", style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)),
//                   onPressed: () {},
//                 ),
//               )
//             ],
//           ),
//         ),
//       ], 
//     ),
//   );}
// }

