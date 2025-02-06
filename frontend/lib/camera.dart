/// This file contains all the logic and widgets used to create the Camera screen in our
/// application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/tabs_bar.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// cameras used within the app; int representations of the cameras
/// This is general default values for all phons as far as we know, needs confirmation
int FRONT_CAMERA = 1;
int BACK_CAMERA = 0;

// integer representation of the first album in the gallery
int FIRST_ALBUM = 0;

// ratios for the camera preview
int WIDTH_RATIO = 1920;
int HEIGHT_RATIO = 1080;

/// 

///
String videoPath = "";


/// boolean used to check when camera is in use
bool _isRecording = false;

class CameraScreen extends StatefulWidget {
  /// Sets up the camera screen for the application
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  /// CameraAppState is the state of the CameraApp widget
  /// controller used to control the camera
  late CameraController controller;

  /// Used for flipping the camera properly
  bool isCameraFront = false;

  /// Initializes the camera controller
  @override
  void initState() {
    super.initState();
    // starts the camera with the back camera (most used)
    _initializeCamera(BACK_CAMERA);
  }

  /// Initializes the camera controller
  void _initializeCamera(int cameraPos) {
    controller = CameraController(
      cameras[cameraPos],
      ResolutionPreset.high,
    );
    controller.initialize().then((_) {
      // makes sure the camera exists
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// Switches the camera from front to back and vice versa
  void switchCamera() {
    setState(() {
      isCameraFront = !isCameraFront;
    });
    // dispose of the current controller
    controller.dispose();
    // initialize a new controller
    _initializeCamera(isCameraFront ? FRONT_CAMERA : BACK_CAMERA);
  }

  /// Displays a temporary popup message that video was saved to the phone
  void showVideoSaved(text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: <Widget>[
            TextButton(
              // when ok button is pressed, the popup is closed
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                // button to translate the video
                child: const Text("Translate"))
          ],
        );
      },
    );
  }

  Future<String> tempDirPath() async {
    final Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  void deleteTempDir() {
    final Directory tempDir = Directory(tempDirectoryPath);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }


  /// Records the video and saves it to the camera roll
  Future<String> _recordVideo(bool newWord) async {
    if (_isRecording) {
      try {
        // waits for the video to stop recording
        final file = await controller.stopVideoRecording();

        //creates a unique name for each video file
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        //saves the newest video to the directory
        final newPath = '$tempDirectoryPath/$timeStamp.mp4';
        final newFile = await File(file.path).copy(newPath);
        // get the path of the saved video
        videoPath = newFile.path;

        // Use Gal to process the saved video
        await Gal.putVideo(videoPath);

        setState(() => _isRecording = false);
      } catch (e) {
        // show popup that video was not saved
        showVideoSaved("Error recording/saving video, please try again.");
        setState(() {
          _isRecording = false;
        });
      }
      return "Stopped";
      // if not recording, start recording
    } else {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      //delete the temp directory
      if (!newWord){
        deleteTempDir();
        tempDirectoryPath = await tempDirPath();
      }
      setState(() => _isRecording = true);
      return "Started";
    }
  }

  /// Builds the camera screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // if the camera is initialized, show the camera preview with the correct aspect ratio
          if (controller.value.isInitialized)
            Center(
              // box to hold the camera preview
              child: SizedBox(
                // .3 and .4 are ratios used to fit the camera to the screen without stretching.
                // they were found by guessing and checking
                width: controller.value.aspectRatio * WIDTH_RATIO * .3, 
                height: controller.value.aspectRatio * HEIGHT_RATIO * .4,
                // if the camera is front, flip the camera preview so that it is mirrored
                child: isCameraFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(0), // necessary rotation even if not used
                        child: CameraPreview(controller),
                      )
                    : CameraPreview(controller),
              ),
            ),
          Align(
            // button to switch front and back cameras
            alignment: Alignment.topRight,
            child: Padding(
              // padding to make sure button is correctly placed
              padding: const EdgeInsets.only(right: 20, top: 50),
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
            // sets up the button to record/stop recording a video
            alignment: Alignment.bottomCenter,
            child: Padding(
              // padding to make sure button is correctly placed
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _recordVideo(false);
                  if (_isRecording) {
                    // show popup that video was recorded
                    showVideoSaved("Video Saved Successfully!");
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: _isRecording
                    ? const Icon(Icons.stop_circle_outlined, size: 20)
                    : const Icon(Icons.fiber_manual_record, size: 20),
              ),
            ),
          ),
          Align(
            // sets up the button to record/stop recording a video
            alignment: Alignment.bottomLeft,
            child: Padding(
              // padding to make sure button is correctly placed
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  await _recordVideo(true);
                  await _recordVideo(true);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 20),
              ),
            ),
          )
        ],
      ),
      // bottom navigation bar to navigate between screens
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
