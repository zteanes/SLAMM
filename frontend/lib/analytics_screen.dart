/// This file contains the AnalyticsScreen widget, which is the screen that displays
/// the analytics page.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 12/06/2024
library;

import 'package:flutter/material.dart';
import 'package:SLAMM/DB/db_service.dart';
import 'package:SLAMM/tabs_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// how to change: 
//  - add a pie chart with the most used words, listing the 5 most used words beside it
//  - total number of words translated 
//  - ability to list/scroll through all the words translated
//  - ...
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => AnalyticsScreenState();
}

// a reference to the collection of users in the database
CollectionReference db = FirebaseFirestore.instance.collection('Users');

// reference to the user authentication 
final auth = FirebaseAuth.instance;

class AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
  }

  final DbService _db_service = DbService();

  String getWords(String userName) {
    return "Hi";
  }

  Container listOfStats(DocumentSnapshot? doc, List<String> words) {
    return Container(
      height: 600, // Set a fixed height for vertical scrolling // Set a fixed width for horizontal scrolling (adjust as needed)
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Scrollbar( // Optional: Adds a scrollbar for better UX
        child: ListView(
          children: <Widget>[
            Text("${doc?.get("firstName")}'s Analytics", 
              style: const TextStyle(fontSize: 28, color: Colors.white),
              textAlign: TextAlign.center,
            ),

            const Text("All Words Signed:",
              style: TextStyle(fontSize: 30, color: Colors.white),
              textAlign: TextAlign.center,
            ),

            for (var word in words)
              getWord(word),

            const Text("\nNumber of Words:",
              style: TextStyle(fontSize: 30, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            getNumWords(words),
            const Text("\nMost Used Word:",
              style: TextStyle(fontSize: 30, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            getMostUsedWord(words),
            
          ]
        ),
      ),
    );
  }

  Text getNumWords(List<String> words) {
    return Text("${words.length}",
      style: const TextStyle(fontSize: 20, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  Text getWord(word){
    return Text(word,
      style: const TextStyle(fontSize: 20, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  Text getMostUsedWord(List<String> words) {
    Map<String, int> wordCount = {};
    for (var word in words) { 
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    String mostUsedWord = "";
    int maxCount = 0;
    
    wordCount.forEach((word, int count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedWord = word;
      }
    });

    if (mostUsedWord == ""){
      return const Text("No words signed yet!",
          style: TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.center,
        );
    } else{ 
      return Text(mostUsedWord,
          style: const TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.center,
        );
    }
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
                //gets the number of users from the db and displays it on screen
                StreamBuilder(
                  stream: _db_service.getUser(auth.currentUser?.uid), // gets the user that is signed in !!HARD CODED FOR TESTING PURPOSES!!
                  builder: (context, snapshot){
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      // display the user's name from the db
                      DocumentSnapshot<Object?>? doc = snapshot.data;

                      // get the list of words from the user document
                      List<String> words = doc?.get('words').cast<String>() ?? [];
                      
                      return listOfStats(doc,words);
                    }
                  }, 
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
