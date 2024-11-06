import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

int frontCamera = 1;
int backCamera = 0;
int cameraInUse = frontCamera;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

// CameraApp is a StatefulWidget because we may need to
// change the state later, for example, to switch cameras or take pictures
class CameraApp extends StatefulWidget {
  const CameraApp({super.key});
  @override
  CameraAppState createState() => CameraAppState();
}

// CameraAppState is the state of the CameraApp widget
class CameraAppState extends State<CameraApp> {
  late CameraController controller;
  @override
  void initState() {
    super.initState();
    // change from front camera (1) to back camera (0)
    controller = CameraController(cameras[cameraInUse], ResolutionPreset.medium,);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  // dispose of the controller when the widget is removed
  // to prevent memory leaks
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // build the camera preview
  // if the controller is not initialized, return an empty container
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return CameraPreview(controller);
  }
}

class CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
            if (cameraInUse == frontCamera) 
              Transform(transform: Matrix4.rotationY(math.pi), alignment: Alignment.center, child: const SizedBox.expand( child: CameraApp(),),) 
            else 
              Transform(transform: Matrix4.rotationY(0), alignment: Alignment.center, child: const SizedBox.expand( child: CameraApp(),),),
              
            // const Align(
            //   alignment: Alignment.center,
            //   child: SizedBox.expand(
            //     child: CameraApp(),
            //   ),
            // ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // take a picture
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.play_arrow, size: 20),
              ),
            ),
          )

          // body: Stack(
          //   children: [
          //     Positioned.fill(
          //       child: Opacity(
          //         opacity: 0.6,
          //         child: Image.asset('assets/images/temp-splash.jpg', fit: BoxFit.cover),
          //       ),
          //     ),
          //     Align(
          //       alignment: Alignment.center,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             'Camera',
          //             style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 36),
          //           ),
          //           const SizedBox(height: 200),
          //           const SizedBox(height: 20),
          //           SizedBox(

          //           )
          // SizedBox(
          //   width: 300,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //     ),
          //     child: const Text("Go back", style: TextStyle(fontSize: 20, color: Colors.black)),
          //     // go back to the welcome/landing page
          //     onPressed: () {
          //       Navigator.pushNamed(context, "welcome");
          //     },
          //   ),
          // ),
        ],
      ),
      //     ),
      //   ],
      // ),
      // add our bottom tab bar
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.analytics),
                tooltip: "Analytics",
                onPressed: () => Navigator.pushNamed(context, "analytics")),
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                tooltip: "Camera",
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () => Navigator.pushNamed(context, "camera")),
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                tooltip: "Settings",
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, "settings")),
          ],
        ),
      ),
    );
  }
}
