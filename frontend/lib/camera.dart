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
import 'package:photo_manager/photo_manager.dart';

import 'package:pytorch_mobile/pytorch_mobile.dart';
import 'package:pytorch_mobile/model.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';

/// cameras used within the app; int representations of the cameras
/// This is general default values for all phons as far as we know, needs confirmation
const FRONT_CAMERA = 1;
const BACK_CAMERA = 0;

// integer representation of the first album in the gallery
const FIRST_ALBUM = 0;

// ratios for the camera preview
const WIDTH_RATIO = 1920;
const HEIGHT_RATIO = 1080;

/// boolean used to check when camera is in use
bool _isRecording = false;

// path to the saved video 
var videoPath = ''; 

// variable to hold our model; accessed throughout the app
Model? customModel; 


// ------------------ MODEL PREDICTION FUNCTIONALITY ------------------ //

// function to load our model
Future<void> loadModel() async {
  /// This function loads the model from the assets folder and stores it in 
  /// the customModel variable
  print('Loading model...');
  customModel = await PyTorchMobile.loadModel('assets/models/asl100.pt');
  print('Model loaded!'); 
}

Future<String> processVideo(String videoPath) async {
  /// This function processes a video by extracting frames, predicting the sign in each frame,
  /// and returning the most common sign. It accomplishes this by calling many helper 
  /// functions that are defined below.
  try {
    // check to see if the model is loaded. if not, load it 
    if(customModel == null) {
      await loadModel();
    }

    // extract frames
    final frames = await extractVideoToFrames(videoPath);

    // predict most common sign
    final prediction = await getBestPrediction(frames);

    // show prediction
    print('Prediction: $prediction');

    // return prediction to be used in the app
    return prediction;
  } catch (e) {
    // print out the error for debugging
    print('Error processing video: $e');

    // return that an error occurred
    return 'Error processing the video, please try again.';
  }
}

// function to process video
Future<List<File>> extractVideoToFrames(String videoPath) async {
  /// This function extracts frames from a video and returns a list of files

  // get video from directory 
  final directory = await getTemporaryDirectory();
  final outputDirectory = '${directory.path}/frames';
  final outputDirectoryFile = Directory(outputDirectory);

  // create directory
  if(!outputDirectoryFile.existsSync()) {
    outputDirectoryFile.createSync();
  }

  // used ffmpeg command to extract frames
  final command = '-i $videoPath $outputDirectory/frame_%04d.png';
  await FFmpegKit.execute(command);

  // list all files that end with png and put it to a list 
  final frames = outputDirectoryFile.listSync().where((file) => file.path.endsWith('.png'))
      .map((file) => File(file.path)).toList();

  return frames;
}

Future<File> processFrame(File frame) async {
  /// This function processes a frame by resizing it to 224x224 and saving it to a temp file
  /// which can then be used to predict the sign

  // read image
  final bytes = await frame.readAsBytes();
  final image = img.decodeImage(bytes);

  // resize
  final resized = img.copyResize(image!, width: 224, height: 224);

  // save to a temp file 
  final directory = await getTemporaryDirectory();
  final resizedPath = '${directory.path}/${frame.uri.pathSegments.last}';
  final resizedFile = File(resizedPath);
  resizedFile.writeAsBytesSync(img.encodePng(resized));

  return resizedFile;
}

Future<Map<String, int>> predictFrames(List<File> frames) async {
  /// This function predicts the sign in each frame and returns a map with the predictions 
  /// and their counts

  // map to save predictions and have an associated count to each
  Map<String, int> cnt = {};

  for(final frame in frames) {
    final preFrame = await processFrame(frame);

    // get prediction
    final prediction = await customModel?.getImagePrediction(preFrame, 224, 224, "mean,std");

    // count prediction
    if(cnt.containsKey(prediction)) {
      cnt[prediction!] = (cnt[prediction!] ?? 0) + 1;
    } else {
      cnt[prediction!] = 1;
    }
  }
  return cnt;
}

Future<String> getBestPrediction(List<File> frames) async {
  /// This function gets the prediction of each frame and returns the most common prediction
  final cnt = await predictFrames(frames);

  // get most common prediction
  return cnt.entries.reduce((a, b) => a.value > b.value ? a : b).key;
}


/// ------------ END MODEL PREDICTION FUNCTIONALITY ------------ ///
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

  /// Gets the most recent video from the gallery
  Future<File?> getMostRecentVideo() async {
    //! currently not working, gives access to the gallery no matter what the user selects
    // final PermissionState permission = await PhotoManager.requestPermissionExtend();

    //if (permission.isAuth) {
    // Get all albums (gallery collections)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.video, // Specify to fetch only videos
      filterOption: FilterOptionGroup(
        orders: [
          // Sort by creation date descending
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isNotEmpty) {
      // Fetch videos from the first album
      final List<AssetEntity> videos =
          await albums[FIRST_ALBUM].getAssetListPaged(page: 0, size: 1);

      if (videos.isNotEmpty) {
        // Most recent video
        final AssetEntity recentVideo = videos.first;

        // Get file for the video
        final File? videoFile = await recentVideo.file;

        print('got video file: $videoFile');
        // Return the video file
        return videoFile;
      } else {
        print('No videos found in the gallery.');
        return null;
      }
    } else {
      print('No albums found in the gallery.');
      return null;
    }
  }

  /// Displays a temporary popup message that video was saved to camera roll or errored out
  void showVideoSaved(text) {
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
                  print('Translating video...');
                  final recentVideo = await getMostRecentVideo();
                  print('got video');

                  //! start of a video replay, not yet implemented
                  if (recentVideo != null) {
                    final VideoPlayerController videoController =
                        VideoPlayerController.file(
                      recentVideo,
                    );
                  }

                  // process the video
                  String prediction = await processVideo(recentVideo!.path);

                  // show the prediction
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Prediction: $prediction'),
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

                  // clear the popup
                  Navigator.of(context).pop();
                },
                // button to translate the video
                child: const Text("Translate"))
          ],
        );
      },
    );
  }

  /// Records the video and saves it to the camera roll
  void _recordVideo() async {
    if (_isRecording) {
      try {
        // waits for the video to stop recording
        final file = await controller.stopVideoRecording();

        /// Directory where the video will be saved
        Directory? directory;

        // Check platform to determine where to save the video
        if (Platform.isAndroid) {

          // Save to Movies directory on Android
          directory = await getExternalStorageDirectory();
          directory = Directory('${directory!.path}/Movies');
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
          }
        // Saving is slightly different on iOS
        } else if (Platform.isIOS) {
          // Use Documents directory for iOS
          directory = await getApplicationDocumentsDirectory();
        }
        // Saves the video as a mp4 file with the current timestamp
        final newPath =
            '${directory?.path ?? ''}/${DateTime.now().millisecondsSinceEpoch}.mp4';
        final newFile = await File(file.path).copy(newPath);

        // Use Gal to process the saved video
        await Gal.putVideo(newFile.path);

        setState(() => _isRecording = false);
      } catch (e) {
        // show popup that video was not saved
        showVideoSaved("Error recording/saving video, please try again.");
        setState(() {
          _isRecording = false;
        });
      }
      // if not recording, start recording
    } else {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      setState(() => _isRecording = true);
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
                  _recordVideo();
                  if (_isRecording) {
                    // show popup that video was recorded
                    showVideoSaved("Video saved to camera roll!");
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
          )
        ],
      ),
      // bottom navigation bar to navigate between screens
      bottomNavigationBar: BottomTabBar(),
    );
  }
}
