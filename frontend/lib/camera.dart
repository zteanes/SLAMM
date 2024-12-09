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

/// cameras used within the app; int representations of the cameras
/// This is general default values for all phons as far as we know, needs confirmation
int FRONT_CAMERA = 1;
int BACK_CAMERA = 0;

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
          await albums[0].getAssetListPaged(page: 0, size: 1);

      if (videos.isNotEmpty) {
        // Most recent video
        final AssetEntity recentVideo = videos.first;

        // Get file for the video
        final File? videoFile = await recentVideo.file;
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
              // when ok button is pressed, the popup is closed
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
                onPressed: () async {
                  final recentVideo = await getMostRecentVideo();
                  //! start of a video replay, not yet implemented
                  if (recentVideo != null) {
                    final VideoPlayerController videoController =
                        VideoPlayerController.file(
                      recentVideo,
                    );
                  }
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
                width: controller.value.aspectRatio * 1920 * .3,
                height: controller.value.aspectRatio * 1080 * 0.4,
                //? if the camera is front, flip the camera preview so that it is mirrored (0?)
                child: isCameraFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(0),
                        child: CameraPreview(controller),
                      )
                    : CameraPreview(controller),
              ),
            ),
          Align(
            // button to switch front and back cameras
            alignment: Alignment.topRight,
            child: Padding(
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
