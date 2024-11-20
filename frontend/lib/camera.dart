import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/tabs_bar.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

// cameras used within the app; int representations of the cameras
int frontCamera = 1;
int backCamera = 0;

// boolean used to check when camera is in use
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
                width: 1920,
                height: 1080,
                child: isCameraFront ? 
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
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