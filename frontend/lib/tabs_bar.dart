import 'package:flutter/material.dart';

class BottomTabBar extends StatefulWidget {
  const BottomTabBar({super.key});

  @override
  State<BottomTabBar> createState() => BottomTabBarState();
}

class BottomTabBarState extends State<BottomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.analytics),
              onPressed: () => Navigator.pushNamed(context, "analytics")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => Navigator.pushNamed(context, "camera")
            ),
            IconButton( 
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, "settings")
            ),
          ],
        ),
      ),
    );
  }
}