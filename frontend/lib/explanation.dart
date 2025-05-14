/// This file contains the ExplanationScreen widget, which is the screen that displays
/// the explanations such as how to use the application and it's intended purpose.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 04/16/2025
/// Version: 1.0
library;

import 'package:flutter/material.dart';

// textual constant used to explain what slamm is
// ignore: constant_identifier_names
const WHAT_IS_SLAMM = 
    "SLAMM, standing for Sign Language Analysis and Mobile Machine Learning, is the result of a "
    "capstone project at Western Carolina University. It's created by Zachary Eanes and Alexander "
    "Charlot, both senior students in the Computer Science Program. \n\n"

    "SLAMM is a mobile app designed with the goal of allowing simple and quick translation of "
    "American Sign Language, or ASL for short. This is inspired by the lack of widely available "
    "tools to translate ASL in the iOS or Android app stores. There are many translation tools "
    "which are available for spoken language, but when it comes to ASL it's been neglected. It's "
    "important as there are many people who rely on ASL as a primary form of communication, and "
    "SLAMM is designed to be a solution in allowing people to feel included and understood. "
    "Currently, our model recognizes 100 terms.";


// textual constant used to explain how to use the application
const HOW_TO_USE = 
    "In order to use the app effectively, let's first consider how SLAMM actually works! It's done "
    "by recording short videos of a person signing a single term, and then receiving a prediction "
    "from a machine learning model trained to recognize ASL. \n\n"

    "We recommend recording a video which contains only one sign at a time, and ensuring that " 
    "as much of the sign is in the video as possible. Try to eliminate as much video and after "
    "the sign to sure the highest level of accuracy. This is because the model is trained to "
    "recognize a single sign, and if there is \"dead space\" in the video, it will confuse the "
    "model and lead to a lower accuracy or a wrong translation. \n\n"

    "Whenever you receive a translation and reinterpretation back, you'll notice the coloring of "
    "the text. The text is colored so that a user will know how confident the model is in its "
    "prediction. The colors are as follows: \n\n"
    "Green: The model is very confident in its prediction. (70%+) \n"
    "Yellow: The model is somewhat confident in its prediction. (35%-69%) \n"
    "Red: The model is not confident in its prediction. (0%-34%) \n\n"

    "Otherwise, simply navigate to the camera screen, use the camera switch button in the upper-right "
    "to select the camera you wish to use. Then, click the button in the bottom-middle of the screen "
    "to begin recording! Once you begin recording, you'll notice a new button appears in the "
    "bottom-left of the screen. This is our \"next word\" button, and it allows you to begin"
    "signing a new word without having to stop the recording. In essence, it allows you to "
    "translation a sentence in a single video! Whenever you're done recording, simply click the "
    "\"stop recording\" button in the bottom-middle of the screen. This will stop the "
    "recording and can then hit translate to receive a translation! \n\n";



/// This widget is used to create the Explanation screen for the application. It extends the 
/// state of what the explanation screen actually looks like.
class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => ExplanationScreenState();
}

/// This widget is used to create the Explanation screen state for the application. This actually
/// defines the formatting and information present on the page.
class ExplanationScreenState extends State<ExplanationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 50), // box to separate the top of the screen
              Text(
                "Wait...what is SLAMM?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold
                )
              ),
                const SizedBox(height: 15), // box just to separate some elements of the column
                SizedBox(
                  width: 325,
                  child: 
                    Center(
                      child: Text( 
                        WHAT_IS_SLAMM,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ),
              const SizedBox(height: 30),
              Text(
                "That sounds awesome! But how do I use it?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 15), // separation box again 
              SizedBox(
                  width: 325,
                  child: 
                    Center(
                      child: Text( 
                        HOW_TO_USE,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ),
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
                    child: Text("Go back",
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)),

                    // return to the screen the user was last on
                    onPressed: () => Navigator.pop(context) 
                  ),
                ),
              const SizedBox(height: 200) // box to separate the bottom of the screen
            ],
          ),
        ),
      )
    );
  }
}