/// This file contains the code for the signup page. It uses Firebase Authentication 
/// to create a new user account. The user is then redirected to the analytics page.
/// 
/// Authors: Zach Eanes
/// Version: 1.0
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/analytics_screen.dart';
import 'package:frontend/login.dart';

/// Class to create the signup screen
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

/// State class for the signup screen
class _SignupState extends State<Signup> {
  // create the FirebaseAuth instance and key
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // variables for necessary user information
  String _email = '';
  String _password = '';
  String _error = '';

  // TODO: store these in a user object associated with the UID
  String _firstName = '';
  String _lastName = '';

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
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        cursorWidth: BorderSide.strokeAlignCenter,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _firstName = value!;
                        },
                      ),

                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _lastName = value!;
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
                          _email = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
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
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              await _auth.createUserWithEmailAndPassword(
                                  email: _email, password: _password);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AnalyticsScreen()));
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _error = e.message!;
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
                      TextButton( 
                        style: TextButton.styleFrom(
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

                      Text(_error),
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