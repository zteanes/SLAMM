/// This file contains the theme data and colorings we use through our application.
///
/// Authors: Alex Charlot and Zach Eanes
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  // sets the brightness and colors for light mode
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color.fromARGB(255, 107, 107, 107),
  colorScheme: const ColorScheme.light(
    // title text and icon color
    primary: Color.fromARGB(255, 8, 93, 100),
    secondary: Colors.white,
    surface: Color.fromARGB(255, 220, 214, 209),
  ),
);

ThemeData darkmode = ThemeData(
  // sets the brightness and colors for dark mode
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    // title text and icon color
    primary: Color.fromARGB(255, 9, 143, 156),
    secondary: Color.fromARGB(199, 255, 255, 255),
    surface: Color.fromARGB(212, 255, 255, 255),
  ),
);
