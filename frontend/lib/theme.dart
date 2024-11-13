import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 9, 255, 156),
    secondary: Colors.black,
    surface: Colors.white,
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