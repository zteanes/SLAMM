 import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/main.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget{
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

// CameraApp is a StatefulWidget because we may need to 
// change the state later, for example, to switch cameras or take pictures
class CameraApp extends StatefulWidget{
  CameraAppState createState() => CameraAppState();
}

// CameraAppState is the state of the CameraApp widget
class CameraAppState extends State<CameraApp> {
  late CameraController controller;
  @override
  void initState(){
    super.initState();
    // change from front (0) to back (1) camera
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
  // dispose of the controller when the widget is removed
  // to prevent memory leaks
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  // build the camera preview
  // if the controller is not initialized, return an empty container
  @override
  Widget build(BuildContext context){
    if(!controller.value.isInitialized){
      return Container();
    }
    return CameraPreview(controller);
  }
}

class CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraApp(),
      
      // body: Stack(
      //   children: [
      //     Positioned.fill(
      //       child: Opacity(
      //         opacity: 0.6,
      //         child: Image.asset('assets/images/temp-splash.jpg', fit: BoxFit.cover),
      //       ),
      //     ),
      //     Align(
      //       alignment: Alignment.center,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             'Camera', 
      //             style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 36),
      //           ),
      //           const SizedBox(height: 200),
      //           const SizedBox(height: 20),
      //           SizedBox(

      //           )
      //           // SizedBox(
      //           //   width: 300,
      //           //   child: ElevatedButton(
      //           //     style: ElevatedButton.styleFrom(
      //           //       backgroundColor: Colors.white,
      //           //       padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      //           //       shape: RoundedRectangleBorder(
      //           //         borderRadius: BorderRadius.circular(30),
      //           //       ),
      //           //     ),
      //           //     child: const Text("Go back", style: TextStyle(fontSize: 20, color: Colors.black)), 
      //           //     // go back to the welcome/landing page
      //           //     onPressed: () {
      //           //       Navigator.pushNamed(context, "welcome");
      //           //     },
      //           //   ),
      //           // ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      // add our bottom tab bar
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.analytics),
              tooltip: "Analytics",
              onPressed: () => Navigator.pushNamed(context, "analytics")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              tooltip: "Camera",
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => Navigator.pushNamed(context, "camera")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              tooltip: "Settings",
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, "settings")
            ),
          ],
        ),
      ),
    );
  }
}
