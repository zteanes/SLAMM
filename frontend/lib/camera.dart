import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/tabs_bar.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pytorch_mobile/pytorch_mobile.dart';
import 'package:pytorch_mobile/model.dart';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:image/image.dart' as img;

int frontCamera = 1; // int representation of front camera
int backCamera = 0; // int representation of back camera
var videoPath = ''; // path to the saved video 
bool _isRecording = false; // boolean used to check when camera is in use
Model? customModel; // variable to hold our model; accessed throughout the app

// function to load our model
Future<void> loadModel() async {
  customModel = await PyTorchMobile.loadModel('assets/models/asl100.pt', type = ModelType.torchscript);
}

Future<void> processVideo(String videoPath) async {
  try {
    // extract frames
    final frames = await extractVideoToFrames(videoPath);

    // predict most common sign
    final prediction = await getBestPrediction(frames);

    // show prediction
    print('Prediction: $prediction');
  } catch (e) {
    print('Error processing video: $e');
  }
}

// function to process video
Future<List<File>> extractVideoToFrames(String videoPath) async {
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


// function to process frames
Future<File> processFrame(File frame) async {
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

// function to predict! 
Future<Map<String, int>> predictFrames(List<File> frames) async {
  // map to save predictions and have an associated count to each
  Map<String, int> cnt = {};

  for(final frame in frames) {
    final preFrame = await preprocessFrame(frame);

    // get prediction
    final prediction = await customModel.getImagePrediction(preFrame, 224, 224, "mean,std");

    // count prediction
    if(cnt.containsKey(prediction)) {
      cnt[prediction] = cnt[predict]! + 1;
    } else {
      cnt[prediction] = 1;
    }
  }

  return cnt;
}


// finds the best prediction
Future<String> getBestPrediction(List<File> frames) async {
  final cnt = await predictFrames(frames);

  // get most common prediction
  return cnt.entries.reduce((a, b) => a.value > b.value ? a : b).key;
}



/***** BEGIN CAMERA SCREEN CREATION *****/

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

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
    controller = CameraController(cameras[cameraPos], ResolutionPreset.high,);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    //Permission.camera.request();
    //Permission.storage.request();
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

// displays a temporary popup message that video was saved to camera roll or errored out
void showVideoSaved(text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text),
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

  _recordVideo() async {
  if (_isRecording) {

    try{
      final file = await controller.stopVideoRecording();
      
      Directory? directory;

      if (Platform.isAndroid) {
        // Save to Movies directory on Android
        directory = await getExternalStorageDirectory();
        directory = Directory('${directory!.path}/Movies');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
      } else if (Platform.isIOS) {
        // Use Documents directory for iOS
        directory = await getApplicationDocumentsDirectory();
      }
      // Saves the video as a mp4 file with the current timestamp
      final newPath = '${directory?.path ?? ''}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      videoPath = newPath; // used to load video later
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
            Center(
              child: SizedBox(
                width: controller.value.aspectRatio * 1920 * .3,
                height: controller.value.aspectRatio * 1080 * 0.4,
                child: isCameraFront ? 
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(0),
                        child: CameraPreview(controller),
                      )
                    : CameraPreview(controller),
              ),
            ),
            // if(isCameraFront)
            //     SizedBox.expand(
            //       child:
            //         Transform(
            //           alignment: Alignment.center,
            //           transform: Matrix4.rotationY(math.pi),
            //           child: CameraPreview(controller),
            //         )
            //     )
            //   else
            //     SizedBox.expand(child:
            //       CameraPreview(controller)
            //     ),
          Align( // button to switch front and back cameras
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right:20, top:50),
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
                  if (_isRecording) {
                    // show popup that video was recorded 
                    showVideoSaved("Video saved to camera roll!");
                  }
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
      bottomNavigationBar: BottomTabBar(),
    );
  }
}