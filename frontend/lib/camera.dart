/// This file contains all the logic and widgets used to create the Camera screen in our
/// application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 02/07/2025
library;

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/tabs_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// cameras used within the app; int representations of the cameras
/// This is general default values for all phones as far as we know, needs confirmation
const FRONT_CAMERA = 1;
const BACK_CAMERA = 0;

// integer representation of the first album in the gallery
const FIRST_ALBUM = 0;

// ratios for the camera preview
const WIDTH_RATIO = 1920;
const HEIGHT_RATIO = 1080;

/// video path for the most recent video recorded
String videoPath = "";

/// boolean used to check when camera is in use
bool _isRecording = false;

Future<String> uploadVideo(File videoFile, int bufferVal) async {
  /// This function uploads a video to the server, and returns the prediction 
  /// that is received.
  /// 
  /// Parameters:
  ///  videoFile: the video file to be uploaded
  ///  buffer: 0 if nothing else needs to be buffered, 1 if the prediction should be buffered

  // create the request
  // NOTE: HAVE TO CHANGE THE IP ADDRESS TO WHATEVER NGROK IS USING TO HOST
  var request = http.MultipartRequest('POST', Uri.parse('https://3826-152-30-110-47.ngrok-free.app/predict_video'));

  // add the video to the request
  request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

  // add the buffer flag to the request
  request.fields['buffer'] = bufferVal.toString();

  // send the request
  var response = await request.send();

  // return the response from the server  
  var responseString = await response.stream.bytesToString();

  // decode the response as a json object
  var jsonResponse = json.decode(responseString);

  // return object to be displayed
  var responseText = "";

  // if the prediction was empty, return an error message
  if (jsonResponse['message'] == "") {
    responseText = "Error processing the video, please re-record and try again.";
  }
  else { // otherwise get the prediction/message
    responseText = jsonResponse['message'];
  }
  
  // return the prediction
  return responseText;
}

/// --------------- BEGIN CAMERA SCREEN CREATION --------------- ///


class CameraScreen extends StatefulWidget {
  /// Sets up the camera screen for the application
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

// CameraAppState is the state of the CameraApp widget
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
    try{
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
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  /// Switches the camera from front to back and vice versa
  void switchCamera() async {
    // dispose of the current controller
    await controller.dispose();
      
    // flip the camera
    setState(() {
      isCameraFront = !isCameraFront;
    });
    
    // initialize a new controller
    _initializeCamera(isCameraFront ? FRONT_CAMERA : BACK_CAMERA);
  }

  /// Displays a temporary popup message that video was saved to the phone
  void showVideoSaved(String text, String path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: <Widget>[
            TextButton(
              // ok button to clear the popup
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              // translate button to get prediction for video recorded
                onPressed: () async {
                  Navigator.of(context).pop();
                  // make a file of the video from the path
                  if (path == "") {
                    return;
                  }
                  // upload the video
                  var prediction = await uploadVideo(File(path), 0);

                  // remove dialog of video saved
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // show the prediction
                  showPrediction(prediction);
                },
              // button to translate the video
              child: const Text("Translate"))
          ],
        );
      },
    );
  }

  void showPrediction(String prediction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Prediction: ${prediction}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
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

        // creates a unique name for each video file
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

        // saves the newest video to the directory
        videoPath = '$tempDirectoryPath/$timeStamp.mp4';
        await File(file.path).copy(videoPath);

        setState(() => _isRecording = false);
      } catch (e) {
        // show popup that video was not saved, pass "" as path to close it 
        showVideoSaved("Error recording/saving video, please try again.", "");
        setState(() {
          _isRecording = false;
        });
      }
      return "Stopped";

    // if not recording, start recording
    } else {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();

      // delete the temp directory
      if (!newWord){
        //deleteTempDir();
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
                width: controller.value.aspectRatio * WIDTH_RATIO * .5, 
                height: controller.value.aspectRatio * HEIGHT_RATIO * .45,
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
                    // wait like 200 milliseconds
                    Future.delayed(const Duration(milliseconds: 200), () {
                      showVideoSaved("Video recorded!", videoPath);
                    });
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
                  uploadVideo(File(videoPath), 1); // don't need return value to continue recording
                  await _recordVideo(true);
                  // flashes camera to indicate that another word should be presented
                  await controller.setFlashMode(FlashMode.torch);
                  await controller.setFlashMode(FlashMode.off);
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
