import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 9, 1, 156),
    secondary: Colors.white,
    surface: Colors.black,
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 9, 143, 156),
    secondary: Colors.white,
    surface: Colors.black,
  ),
);