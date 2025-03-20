/// This file contains the AnalyticsScreen widget, which is the screen that displays
/// the analytics page.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';
import 'package:frontend/DB/db_service.dart';
import 'package:frontend/tabs_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => AnalyticsScreenState();
}

// a reference to the collection of users in the database

CollectionReference db = FirebaseFirestore.instance.collection('Users');

int viewSwitcher = 0;

class AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
  }

  final DbService _db_service = DbService();

  String getWords(String userName) {
    return "Hi";
  }

  Container listOfWords(List<String> words) {
    return Container(
      height: 400, // Set a fixed height for vertical scrolling
      width: 300, // Set a fixed width for horizontal scrolling (adjust as needed)
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
      ),
      child: Scrollbar( // Optional: Adds a scrollbar for better UX
        child: ListView(
          children: words.map((word) => Text(word,
            style: const TextStyle(fontSize: 30, color: Colors.white),
            textAlign: TextAlign.center,
          )).toList(),
        ),
      ),
    );
  }

  Text getNumWords(List<String> words) {
    return Text("Number of words: ${words.length}",
      style: const TextStyle(fontSize: 20, color: Colors.white),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6, // set the opacity of the background image
              child: Image.asset('assets/images/temp-splash.jpg',
              fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text("Signed Words", style: TextStyle(fontSize: 40, color: Colors.white)),
                //gets the number of users from the db and displays it on screen
               StreamBuilder(
                  stream: _db_service.getUser("Alex517"), // gets the user that is signed in !!HARD CODED FOR TESTING PURPOSES!!
                  builder: (context, snapshot){
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      DocumentSnapshot<Object?>? doc = snapshot.data;
                      // get the list of words from the user document
                      List<String> words = doc?.get('words').cast<String>() ?? [];
                      // print the list of words to the console for debugging purposes
                      if(viewSwitcher == 0){
                        return listOfWords(words);
                      } else {
                        return getNumWords(words);
                      }
                    }
                  }, 
                ),

                const SizedBox(height: 80), // temporary height spacing for skeleton screen
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Switch Stats",
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                    // go back to the welcome/landing page
                    onPressed: () {
                      setState(() {
                        viewSwitcher = (viewSwitcher + 1) % 2; // toggle between the two views  
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // add our bottom tab bar
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
