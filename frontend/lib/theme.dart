/// This file contains the theme data and colorings we use through our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 04/16/2025
/// Version: 1.0
library;

import 'package:flutter/material.dart';

/// Lightmode coloring used throughout our application
ThemeData lightmode = ThemeData(
  // sets the brightness and colors for light mode
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color.fromARGB(255, 208, 208, 208),
  colorScheme: const ColorScheme.light(
    // title text and icon color
    primary: Color.fromARGB(199, 255, 255, 255),
    secondary: Color.fromARGB(255, 6, 70, 75),
    surface: Color.fromARGB(255, 220, 214, 209),
  ),
  fontFamily: 'MonoLisa',
);

/// Darkmode coloring used throughout our application
ThemeData darkmode = ThemeData(
  // sets the brightness and colors for dark mode
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 2, 38, 41),
  colorScheme: const ColorScheme.dark(
    // title text and icon color
    primary: Color.fromARGB(255, 9, 143, 156),
    secondary: Color.fromARGB(199, 255, 255, 255),
    surface: Color.fromARGB(212, 255, 255, 255),
  ),
  fontFamily: 'MonoLisa',
);
