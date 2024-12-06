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
import 'package:video_player/video_player.dart';

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

  Future<File?> getMostRecentVideo() async {
    // Request permissions to access media files
    // final PermissionState permission = await PhotoManager.requestPermissionExtend();

    //if (permission.isAuth) {
      // Get all albums (gallery collections)
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video, // Specify to fetch only videos
        filterOption: FilterOptionGroup(
          orders: [ // Sort by creation date descending
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (albums.isNotEmpty) {
        // Fetch videos from the first album
        final List<AssetEntity> videos = await albums[0].getAssetListPaged(page: 0, size: 1);

        if (videos.isNotEmpty) {
          // Most recent video
          final AssetEntity recentVideo = videos.first;

          // Get file for the video
          final File? videoFile = await recentVideo.file;

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
            TextButton(
              onPressed: () async {
                final recentVideo = await getMostRecentVideo();
                if (recentVideo != null) {
                  final VideoPlayerController videoController = VideoPlayerController.file(
                  recentVideo,
                  );
                }
                print('---------------------------------$recentVideo----------------------');
              }, child: const Text("Translate"))
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