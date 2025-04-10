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

// used for a pie chart 
import 'package:fl_chart/fl_chart.dart';

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

  // instance of the db to reference throughout this screen
  final DbService _db_service = DbService();

  // screen is an entire scrollable container, with a static header of user's name 
  // and a list of their analytics
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // static header 
                StreamBuilder(
                  stream: _db_service.getUser(auth.currentUser?.uid), // gets the user that is signed in
                  builder: (context, snapshot){
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      // reference of the data document to use 
                      DocumentSnapshot<Object?>? doc = snapshot.data;

                      return Text("${doc?.get("firstName")}'s Analytics", 
                        softWrap: true,
                        style:  TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.secondary),
                        textAlign: TextAlign.center,
                      );
                    }
                  }, 
                ),

                // gets the number of users from the db and displays it on screen
                StreamBuilder(
                  stream: _db_service.getUser(auth.currentUser?.uid), // gets the user that is signed in
                  builder: (context, snapshot){
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      // reference of the data document to use
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


  /// Creates a container that holds the list of analytics for the user.
  /// 
  /// @param doc: the user's document from the database
  /// @param words: the list of words that the user has signed
  /// @return a container that holds the list of analytics for the user
  Container listOfStats(DocumentSnapshot? doc, List<String> words) {
    return Container(
      height: 600, // Set a fixed height for vertical scrolling (adjust as needed)
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Scrollbar( 
        child: ListView(
          children: <Widget>[

            // most common words signed with a pie chart
            Text("Most Common Words:",
              style: TextStyle(fontSize: 26, color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
            getMostCommonWords(words),

            // number of words signed by the user
            Text("\nNumber of Words:",
              style: TextStyle(fontSize: 26, color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
            getNumWords(words),
            
            // most used word by the user
            Text("\nMost Used Word:",
              style: TextStyle(fontSize: 26, color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
            getMostUsedWord(words),

            // space
            const SizedBox(height: 20),
            
            // list of all words signed by the user
            Text("All Words:",
              style: TextStyle(fontSize: 26, color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
            getAllWords(words),

          ]
        ),
      ),
    );
  } // end ---listOfStats---


  /// Creates a Text widget that displays the most common words signed by the user.
  /// 
  /// @param words: the list of words that the user has signed
  /// @return a Text widget that displays the most common words signed by the user
  Row getMostCommonWords(List<String> words) {
    // map the count of each word
    Map<String, int> wordCount = {};

    // iterate the words with a map, incrementing the count of each word
    for (var word in words) { 
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // sort the map by count of each word
    wordCount = Map.fromEntries(wordCount.entries
                        .toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));

    // get the top 5 most common words
    List<String> mostCommonWords = [];
    int count = 0;
    while (count < 5 && count < wordCount.length) {
      mostCommonWords.add("${wordCount.keys.elementAt(count)} (${wordCount.values.elementAt(count)})");
      count++;
    }

    // if no words are signed, display a message
    if (mostCommonWords.isEmpty){
      return Row(
        children: [
          Text("No words signed yet!",
              style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
        ],
      );
    }

    // list of colors to use be used for the pie chart
    const List<Color> col = [
      Color.fromARGB(255, 7, 80, 86),
      Color.fromARGB(255, 10, 114, 123),
      Color.fromARGB(255, 13, 147, 159),
      Color.fromARGB(255, 15, 178, 193),
      Color.fromARGB(255, 18, 209, 227),
    ];

    // make a pie chart of the most common words
    var pie = SizedBox(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(mostCommonWords.length, (i) {
            return PieChartSectionData(
              // get a color from the list of primary colors
              color: col[i % col.length],

              // set the value of the pie chart to the count of the word
              value: wordCount[mostCommonWords[i].split(" ")[0]]!.toDouble(),

              // set the title of the pie chart to the word
              title: mostCommonWords[i].split(" ")[0],

              // set the radius of the pie chart
              radius: 100,
            );
          }),
        ),
      
      ),
    );

    // refactor the words to read like "1) Word - count"
    var wordList = mostCommonWords.asMap().entries.map((entry) {
      int index = entry.key + 1;
      String word = entry.value.split(" ")[0]; // Extract only the word, not count

      return Text("$index) $word - ${wordCount[word]}",
        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
        textAlign: TextAlign.left, // Ensure text is left-aligned
      );
    }).toList();

    // combine all the formatted words into a column
    var finalWords = Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
      children: wordList.map((word) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0), // Add some spacing
        child: word,
      )).toList(),
    );

    // return text and pie chart side by side
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns both pie chart and text at the top
      children: [
        pie,
        const SizedBox(width: 16), // Add spacing between the chart and text
        finalWords,
      ],
    );
  } // end getMostCommonWords


  /// Creates a Text widget that displays the number of words signed by the user.
  /// 
  /// @param words: the list of words that the user has signed
  /// @return a Text widget that displays the number of words signed by the user
  Text getNumWords(List<String> words) {
    return Text("${words.length}",
      style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
      textAlign: TextAlign.center,
    );
  } // end getNumWords


/// Creates a widget that displays all the words signed by the user.
/// 
/// @param words: the list of words that the user has signed
/// @return a widget that displays all the words signed by the user
Widget getAllWords(List<String> words) {
  // ensure user has signed words, if not display a message
  if (words.isEmpty) {
    return Text(
      "No words signed yet!",
      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
      textAlign: TextAlign.center,
    );
  }

  // display the words in a wrap widget
  return LayoutBuilder(
    builder: (context, constraints) {
      // calculate the width of each column necessary
      double columnWidth = constraints.maxWidth / 3;

      // put everything in a wrap widget to display words in 3 columns 
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: words
            .map((word) => SizedBox(
                  width: columnWidth - 10,
                  child: Text(
                    word,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      );
    },
  );
}

  /// Creates a Text widget that displays the most used word by the user.
  /// 
  /// @param words: the list of words that the user has signed
  /// @return a Text widget that displays the most used word by the user
  Text getMostUsedWord(List<String> words) {
    Map<String, int> wordCount = {};

    // iterate the words with a map, incrementing the count of each word
    for (var word in words) { 
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // find the most used word
    String mostUsedWord = "";
    int maxCount = 0;
    
    // iterate every map element and find the most used word
    wordCount.forEach((word, int count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedWord = word;
      }
    });

    // if no words are signed, display a message
    if (mostUsedWord == ""){
      return  Text("No words signed yet!",
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
          textAlign: TextAlign.center,
        );
    } else { 
      // otherwise, return the most used word as a widget
      return Text(mostUsedWord,
          style:  TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
          textAlign: TextAlign.center,
        );
    }
  } // end getMostUsedWord
}