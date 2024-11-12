import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

int frontCamera = 1;
int backCamera = 0;


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

// // CameraApp is a StatefulWidget because we may need to
// // change the state later, for example, to switch cameras or take pictures
// class CameraApp extends StatefulWidget {
//   const CameraApp({super.key});
//   @override
//   CameraScreenState createState() => CameraAppState();
// }

// CameraAppState is the state of the CameraApp widget
class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isCameraFront = true;
  @override
  void initState() {
    super.initState();
    _initializeCamera(backCamera);
  }

  void _initializeCamera(int cameraPos) {
    controller = CameraController(cameras[cameraPos], ResolutionPreset.medium,);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
  void switchCamera() {
    setState(() {
      isCameraFront = !isCameraFront;
    });
    controller.dispose(); // dispose of the current controller
    _initializeCamera(isCameraFront ? frontCamera:backCamera); // initialize a new controller

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if(controller.value.isInitialized)
            if(isCameraFront)
              SizedBox.expand(
                child:
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: CameraPreview(controller),
                  )
              )
              else
                SizedBox.expand(child:
                  CameraPreview(controller)
                ),
          Align( // button to switch front and back cameras
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  switchCamera();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.flip_camera_ios, size: 20),
              ),
            ),
          ),
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
        ],
      ),
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