/// This file outlines the settings screen used for our application and the
/// necessary logic associated with it.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 04/16/2025
/// Version: 1.0
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:SLAMM/tabs_bar.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

/// instance of the firebase auth and firestore
FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference db = FirebaseFirestore.instance.collection('Users');

/// Class for the settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

/// Class state for the settings screen
class SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData; // Store user data, setup in initialization
  
  /// This function is used to initialize the state of the settings screen.
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
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            "No data available to export!",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        )
      );
      return;
    }

    // create the pdf document
    final pdf = pw.Document();

    // change the font 
    final font = await rootBundle.load('assets/fonts/MonoLisa-Regular.ttf');
    final ttf = pw.Font.ttf(font);

    // add a page to the pdf
    pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // Aligns content to the left
          children: [
            // title for export centered at the top
            pw.Center(
              child: pw.Text('SLAMM Data Export', 
              style: pw.TextStyle(
                fontSize: 26, 
                font: ttf, 
                color: const PdfColor.fromInt(0x085D64),
                decoration: pw.TextDecoration.underline,
                ),
              ),
            ),

            // slight spacing
            pw.SizedBox(height: 15),

            // subheading about the user specific data
            pw.Text("${userData!["firstName"]} ${userData!["lastName"]}'s Data:", 
              style: pw.TextStyle(fontSize: 18, font: ttf)
            ),

            // iterate every user key and value and add to the pdf
            for (var key in userData!.keys) 
                pw.Text('\n$key: ${userData![key]}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            ],
          );
        },
      ),
    );
    

    // save the pdf to the device
    Directory? output;

    // check if it's ios or android and save to correct directory 
    if (Platform.isIOS) {
      // get ios specific directory to save to
      output = await getApplicationSupportDirectory();
      final file = File('${output.path}/SLAMM_Data_Export.pdf');
      await file.writeAsBytes(await pdf.save());

      // prompts on iphone for the user to save/share the file where ever they please
      Share.shareXFiles([XFile(file.path)]);
    } else {
      // get android specific directory to save to 
      // the directory that it saves to is really out of the way
      // /storage/emulated/0/Android/data/com.example.frontend/files/SLAMM_Data_Export.pdf
      output = await getExternalStorageDirectory();
      final file = File('${output?.path}/SLAMM_Data_Export.pdf');
      await file.writeAsBytes(await pdf.save());
    }
    
    // message to user letting them know data was exported
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          "Data exported to PDF!", 
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        )
      )  
    );
  }

  /// Builds the settings screen including all buttons, text, options
  /// 
  /// returns:
  ///  The settings screen with all the options and buttons
  @override
  Widget build(BuildContext context) {
    // Get the system brightness
    var brightness = MediaQuery.of(context).platformBrightness;

    // change the value of the themeNotifier based on the system brightness
    if (themeNotifier.value == ThemeMode.system) {
      themeNotifier.value =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    // The scaffold is the main container for the settings screen
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
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
                      color: Theme.of(context).colorScheme.secondary,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
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
