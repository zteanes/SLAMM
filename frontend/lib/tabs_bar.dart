import 'package:flutter/material.dart';

class BottomTabBar extends StatefulWidget {
  const BottomTabBar({Key? key}) : super(key: key);

  @override
  State<BottomTabBar> createState() => BottomTabBarState();
}

class BottomTabBarState extends State<BottomTabBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.pushNamed(context, "analytics")
          ),
          IconButton( 
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => Navigator.pushNamed(context, "camera")
          ),
          IconButton( 
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, "settings")
          ),
        ],
      ),
    );
  }
}