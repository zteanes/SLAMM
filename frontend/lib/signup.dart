/// This file contains the code for the signup page. It uses Firebase Authentication 
/// to create a new user account. The user is then redirected to the analytics page.
/// 
/// Authors: Zach Eanes
/// date: 04/16/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:SLAMM/analytics_screen.dart';
import 'package:SLAMM/login.dart';

/// Class to create the signup screen
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

/// State class for the signup screen
class _SignupState extends State<Signup> {
  // create the FirebaseAuth instance and key
  final auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  // database instance
  final db = FirebaseFirestore.instance;

  // variables for necessary user information
  String email = '';
  String password = '';
  String error = '';
  String firstName = '';
  String lastName = '';

  /// Builds the signup screen
  /// 
  /// Parameters:
  ///  context - the build context for the widget
  /// 
  /// Returns:
  ///  the widget for our signup screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          Padding(padding: const EdgeInsets.all(20),
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Title of the page
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      // Text field where for the user to enter their first name
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          firstName = value!;
                        },
                      ),

                      // Text field where for the user to enter their last name
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          lastName = value!;
                        },
                      ),

                      // Text form fields for email and password
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                      ),
                      TextFormField(
                        obscureText: true, // don't show the password they're typing
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),

                      // add some space between the text fields and buttons
                      const SizedBox(height: 10),

                      // signup button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            try {
                              await auth.createUserWithEmailAndPassword(
                                      email: email, password: password
                              );
                              // initializes the users documents upon creation of a new user
                              await db.collection('Users').doc(auth.currentUser!.uid).set({
                                'firstName': firstName,
                                'lastName': lastName,
                                'email': email,
                                'words': [],
                                'LLM': [],
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AnalyticsScreen()));
                            } on FirebaseAuthException catch (e) {
                                setState(() {
                                // Error codes from FirebaseAuthException
                                switch (e.code) {
                                  case 'email-already-in-use':
                                    error = 'This email is already in use1. ' 
                                             'Please log in or use a different email.';
                                    break;
                                  case 'invalid-email':
                                    error = 'Invalid email format. ' 
                                             'Please enter a valid email address.';
                                    break;
                                  case 'weak-password':
                                    error = 'Password is too weak. Use at least 8 characters with'
                                             ' a mix of letters, numbers, and symbols.';
                                    break;
                                  case 'network-request-failed':
                                    error = 'Network error. ' 
                                             'Please check your internet connection and try again.';
                                    break;
                                  default:
                                    error = '${e.code}: ${e.message}';
                                }
                              });
                            }
                          }
                        },
                        child: Text('Create Account', 
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 20),
                        ),
                      ),

                      // add some space between the buttons
                      const SizedBox(height: 20),

                      // button to navigate to the login page
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login()));
                        },
                        child: Text('Already have an account? Log in!', 
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                        ),
                      ),

                      // return to the welcome screen
                      ElevatedButton( 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          // push on the welcome screen
                          Navigator.pushReplacementNamed(context, "welcome");
                        },
                        child: Text('Return to Welcome Screen', 
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12),
                            ),
                      ),

                      Text(error),
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}