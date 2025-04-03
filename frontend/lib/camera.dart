/// This file contains all the logic and widgets used to create the Camera screen in our
/// application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 02/07/2025
library;

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:SLAMM/main.dart';
import 'package:SLAMM/tabs_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:torch_light/torch_light.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:path_provider/path_provider.dart';

/// cameras used within the app; int representations of the cameras
/// This is general default values for all phones as far as we know, needs confirmation
const FRONT_CAMERA = 1;
const BACK_CAMERA = 0;
int currentCamera = BACK_CAMERA;

// integer representation of the first album in the gallery
const FIRST_ALBUM = 0;

// integer representations for whether to buffer a video in the server or not
const int BUFFER = 1;
const int NO_BUFFER = 0;

// ratios for the camera preview
const WIDTH_RATIO = 1920;
const HEIGHT_RATIO = 1080;

/// video path for the most recent video recorded
String videoPath = "";

/// boolean used to check when camera is in use
bool _isRecording = false;

// instance of user auth and db
final auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

Future<Map<String, String>> uploadVideo(File videoFile, int bufferVal) async {
  /// This function uploads a video to the server, and returns the prediction 
  /// that is received.
  /// 
  /// Parameters:
  ///  videoFile: the video file to be uploaded
  ///  buffer: 0 if nothing else needs to be buffered, 1 if the prediction should be buffered
  /// 
  /// Returns:
  ///  A map containing the prediction and the LLM message
  
  // create the request
  // NOTE: HAVE TO CHANGE THE IP ADDRESS TO WHATEVER NGROK IS USING TO HOST
  var request = http.MultipartRequest('POST', Uri.parse('https://choice-tops-kite.ngrok-free.app/predict_video'));

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
  print("Response we got from the server is: $jsonResponse");

  // return object to be displayed
  var responseText = Map<String, String>();

  // if the prediction was empty, return an error message
  if (jsonResponse['message'] == "") {
    responseText.addEntries({
      const MapEntry('message', "Error processing the video, please re-record and try again."),
      const MapEntry('llm_message', ""),
      const MapEntry('confidence', "0.0")
    });
  } 
  else { // otherwise get the prediction/message
    responseText.addEntries({
      MapEntry('message', jsonResponse['message']),
      MapEntry('llm_message', jsonResponse['llm_message']),
      MapEntry('confidence', jsonResponse['confidence'])
    });
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

  /// Navigator state used to control the popups
  late NavigatorState _navigator;

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

      // switch the current camera value
      currentCamera = cameraPos;
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

  /// Disposes of the camera controller
  /// NOTE: this cannot be removed or it breaks the camera screen. this is called is called right
  ///       after initState() and before the build. this is responsible for setting up the 
  ///       navigation state of our popups and such.
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initialize the navigator state
    _navigator = Navigator.of(context);
  }

  /// Displays a temporary popup message that video was saved to the phone
  void showVideoSaved(String text, String path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(125),
          title: Text(
                    textAlign: TextAlign.center, 
                    text
                ),
          actions: <Widget>[
            TextButton(
              // ok button to clear the popup
              onPressed: () {
                _navigator.pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
            ),
            TextButton(
              // translate button to get prediction for video recorded
                onPressed: () async {
                  // close the popup
                  _navigator.pop();

                  // if the path is empty, return
                  if (path.isEmpty) { return; }

                  // show loading dialog
                  showLoadingDialog();
                  
                  // upload the video
                  var prediction = await uploadVideo(File(path), NO_BUFFER);

                  try {
                    // get the uid of the current user and a reference to their data
                    String? uid = auth.currentUser?.uid;
                    var userDoc = await db.collection('Users').doc(uid).get();

                    // split the words on white space 
                    var words = prediction['message']!.split(' ');

                    // reference to the original list of words from the database
                    List<dynamic> currentWords = userDoc.data()?['words'] ?? [];
                    // add new word to the database;
                    for (var i = 0; i < words.length; i++) {
                      // append the word to the list
                      currentWords.add(words[i]);
                    
                      // update the database with the new word
                      userDoc.reference.update( {
                        'words': currentWords 
                      } );
                    }

                    // reference to the LLM data from the database and add the new message
                    List<dynamic> currentLLM = userDoc.data()?['LLM'] ?? [];
                    currentLLM.add(prediction['llm_message']);

                    // update the database with the new LLM message
                    userDoc.reference.update({
                      'LLM': currentLLM
                    });

                  } catch (e) {
                    print("Error adding word to database: $e");
                  }

                  // remove the loading dialog
                  if (mounted) {
                    _navigator.pop();
                  }

                  // show the prediction
                  if (mounted) {
                    showPrediction(prediction);
                  }
                },
              // button to translate the video
              child: Text(
                "Translate",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ))
          ],
        );
      },
    );
  }

  /// displays a loading dialog box while the video is being processed
  void showLoadingDialog() {
    // only show the dialog if the screen is mounted
    if (!mounted) { return; }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(125),
          title: Text(
            textAlign: TextAlign.center,
            "Getting the translation...",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          content: const LinearProgressIndicator(),
        );
      },
    );
  }

  /// Displays a dialog box of the prediction the model received
  void showPrediction(Map<String, String> predictionSet) {

    // TODO: store prediction probably around here into the db

    Color getColor(double confidence) {
      if (confidence > 0.7) {
        return Colors.green;
      } else if (confidence > 0.35) {
        return Colors.yellow;
      } else {
        return Colors.red;
      }
    }
    if (!mounted) { return; }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(125),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                textAlign: TextAlign.center,
                "True Prediction:",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                                 fontSize: 22),
                ),

              Text( 
                textAlign: TextAlign.center,
                predictionSet['message']!,
                style: TextStyle(color: getColor(double.parse(predictionSet['confidence']!)),
                                 fontSize: 18),
                ),

              // some space between the two predictions
              const SizedBox(height: 20),

              Text(
                textAlign: TextAlign.center,
                "LLM Reinterpretation:",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                                 fontSize: 22),
                ),

              Text(
                textAlign: TextAlign.center,
                predictionSet['llm_message']!,
                style: TextStyle(color: getColor(double.parse(predictionSet['confidence']!)),
                                 fontSize: 18),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary)
              ),
            ),
          ],
        );
      },
    );
  }


  /// Records the video and saves it to the camera roll
  Future<String> _recordVideo(bool newWord) async {
    if (_isRecording) {
      try {
        // waits for the video to stop recording
        final file = await controller.stopVideoRecording();

        // creates a unique name for each video file
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        videoPath = '${directory.path}/$timeStamp.mp4';

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
                // .5 and .45 are ratios used to fit the camera to the screen without stretching.
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
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(125),
                  side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5)
                ),
                child: Icon(
                  Icons.flip_camera_ios, size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                  ),
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
                    Future.delayed(const Duration(milliseconds: 200), () {
                      showVideoSaved("Video recorded!", videoPath);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(125),
                  side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5)

                ),
                child: _isRecording
                    ? Icon(
                        Icons.stop_circle_outlined, size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : Icon(
                        Icons.fiber_manual_record, size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
              ),
            ),
          ),
          Visibility(
            visible: _isRecording,
            child: Align(
              // sets up the button to record/stop recording a video
              alignment: Alignment.bottomLeft,
              child: Padding(
                // padding to make sure button is correctly placed
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    // begin the recording precess
                    await _recordVideo(true);
                    uploadVideo(File(videoPath), BUFFER); // ignore return value to continue
                    await _recordVideo(true);
            
                    // flashes camera to indicate that another word should be presented
                    if (currentCamera == BACK_CAMERA) { // only flash if the back camera is in use
                      await TorchLight.enableTorch();
                      await Future.delayed(const Duration(milliseconds: 150));
                      await TorchLight.disableTorch();
                    }
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(const CircleBorder()),
                    padding: WidgetStateProperty.all(const EdgeInsets.all(20)),
            
                    // color of the button changes based on the state
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          // visually dimmer when pressed
                          return Theme.of(context).colorScheme.primary.withAlpha(1); 
                        }
                        return Theme.of(context).colorScheme.primary.withAlpha(125);
                        },
                      ),
                    overlayColor: WidgetStateColor.resolveWith(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.transparent; // Prevents unwanted overlay color
                        }
                        return Theme.of(context).colorScheme.secondary.withAlpha(50);
                        },
                    ),
            
                    // border for the button 
                    side: WidgetStateProperty.resolveWith<BorderSide?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(100), width: 1.5);
                        }
                        return BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5);
                      }
                    ),
                  ),
                  child: Icon(
                          Icons.arrow_forward_ios, size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottom navigation bar to navigate between screens
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
