import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';


import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

int frontCamera = 1;
int backCamera = 0;

bool _isRecording = false;


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
  bool isCameraFront = false;
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

  _recordVideo() async {
  if (_isRecording) {
    
    XFile file = await controller.stopVideoRecording();
    setState(() => _isRecording = false);
    // final route = MaterialPageRoute(
    //   fullscreenDialog: true,
    //   builder: (_) => VideoPage(filePath: file.path),
    // );
    //Navigator.push(context, route);
        // Save the video file to a permanent location
    print('-----------------------------------------------------------------------------');
    print(file.path);
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }
    
    
    // directory = Directory('${directory!.path}/Videos');
    // final String newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    // await file.saveTo(newPath);
    
    await Gal.putVideo(directory!.path);

  } else {
    await controller.prepareForVideoRecording();
    await controller.startVideoRecording();
    setState(() => _isRecording = true);
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
                  _recordVideo();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: _isRecording ? const Icon(Icons.stop_circle_outlined, size: 20) : 
                                      const Icon(Icons.fiber_manual_record, size: 20),
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