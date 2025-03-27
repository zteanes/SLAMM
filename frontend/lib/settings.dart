/// This file outlines the settings screen used for our application and the
/// necessary logic associated with it.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 12/06/2024
library;

import 'dart:io';

import 'package:SLAMM/DB/db_service.dart';
import 'package:flutter/material.dart';
import 'package:SLAMM/tabs_bar.dart';
import 'package:SLAMM/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



/// used for the theme notifier
import 'main.dart';

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference db = FirebaseFirestore.instance.collection('Users');


class SettingsScreen extends StatefulWidget {
  /// Sets up the settings screen for the application
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  DbService _dbService = DbService();
  Map<String, dynamic>? userData; // Store user data, setup in initialization

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// This function is used to get the user data from the database, allowing us
  /// to query and use it later in the settings.
  Future<void> fetchUserData() async {
    // get the user id
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      // get the user's document of data
      DocumentSnapshot doc = await db.doc(uid).get();

      if (doc.exists) {
        setState(() { // update userData with the user's data
          userData = doc.data() as Map<String, dynamic>; // Updates state and UI
        });
      }
    }
  }

  /// This function exports the user information to a PDF file.
  void exportToPDF() async {
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No data available to export!",
            style: TextStyle(color: Colors.black),
          ),
        )
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text('SLAMM Data Export',
                  style: const pw.TextStyle(fontSize: 30),
                ),
                pw.Text('User Data:',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                for (var key in userData!.keys)
                  pw.Text('$key: ${userData![key]}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
              ],
            ),
          );
        },
      ),
    );

    // save the pdf to the device
    Directory? output;

    // check if it's ios or android and save to correct directory 
    if (Platform.isIOS) {
      output = await getApplicationSupportDirectory();
    } else {
      output = await getExternalStorageDirectory();
    }
    final file = File('${output?.path}/SLAMM_Data_Export.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // message to user letting them know data was exported
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Data exported to PDF!", 
          style: TextStyle(color: Colors.black)
        )
      )  
    );
  }

  /// Builds the settings screen including all buttons, text, options
  @override
  Widget build(BuildContext context) {
    /// Get the system brightness
    var brightness = MediaQuery.of(context).platformBrightness;

    // change the value of the themeNotifier based on the system brightness
    if (themeNotifier.value == ThemeMode.system) {
      themeNotifier.value =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    // The scaffold is the main container for the settings screen
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/temp-splash.jpg',
                  fit: BoxFit.cover),
            ),
          ),
          // button to explain what application is
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 25),
              child: ElevatedButton(
                // when pressed navigate to explanation screen
                onPressed: () {
                  Navigator.of(context).pushNamed("explanation");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: CircleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary,
                    width: 2
                    ),
                  ), 
                ),
                child: const Icon(Icons.question_mark_rounded, size: 20),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text that says "Settings" in the middle of the screen
                Text(
                  'Settings',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 36),
                ),
                // spacing box to separate elements
                const SizedBox(height: 20), 
                // Text that says "Toggle between Light and Dark mode"
                Text(
                  'Toggle between Light and Dark mode',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16),
                ),
                // listen to the theme notifier and update the switch accordingly
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // add light mode icon surrounding the switch
                    const Icon(Icons.light_mode),

                    // spacing to separate
                    const SizedBox(width: 10),

                    // our switch to change the theme of the app
                    ValueListenableBuilder(
                      valueListenable: themeNotifier,
                      builder: (context, ThemeMode currentTheme, _) {
                        // switch to actually go between light and dark mode
                        return Switch(
                          // if the current theme is dark, set the switch to true
                          value: currentTheme == ThemeMode.dark,
                          onChanged: (isDarkMode) {
                            setState(() {
                              // change value of themeNotifier based on the switch
                              themeNotifier.value =
                                  isDarkMode ? ThemeMode.dark : ThemeMode.light;
                            });
                          },
                          activeTrackColor:
                              Theme.of(context).colorScheme.secondary,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),

                    // another spacing
                    const SizedBox(width: 10),

                    // icon for dark mode
                    const Icon(Icons.dark_mode),
                  ],
                ),
                const SizedBox(height: 220), // temporary height spacing for skeleton screen

                // button to export data to a pdf
                ElevatedButton( 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    exportToPDF();
                  },
                  child: Text('Export Data',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                      )),
                ),

                // button to sign out of the application
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    // sign out of the application
                    auth.signOut();
                    // navigate to the welcome screen
                    Navigator.pushReplacementNamed(context, "welcome");
                  },
                  child: Text('Sign Out',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
      // add the bottom navigation bar to the bottom of the screen
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
