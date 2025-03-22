/// This screen is the login page. It uses Firebase Authentication to log in a user.
/// The user is then redirected to the analytics page.
/// 
/// Authors: Zach Eanes
/// Version: 1.0
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:SLAMM/analytics_screen.dart';
import 'package:SLAMM/signup.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // create the FirebaseAuth instance and key
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // variables for necessary user information
  String _email = '';
  String _password = '';
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: 
              Padding(padding: const EdgeInsets.all(20),
              child: Column(                
                children: <Widget>[
                    // Title of the page
                    Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
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
                      obscureText: true, // don't show the password they're typing
                      decoration: InputDecoration(labelText: 'Password'),
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

                    // spacing 
                    const SizedBox(height: 10),

                    // login button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await _auth.signInWithEmailAndPassword(
                                email: _email, password: _password);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnalyticsScreen(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _error = e.message!;
                            });
                          }
                        }
                      },
                      child: Text('Login', 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 20),
                          ),
                    ),
                    Text(_error),

                    // spacing
                    const SizedBox(height: 20),

                    // button to navigate to the signup page
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Signup(),
                          ),
                        );
                      },
                      child: Text("Don't have an account? Sign up!", 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12),
                          ),
                    ),

                    // return to the welcome screen
                    TextButton( 
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "welcome");
                      },
                      child: Text('Return to Welcome Screen', 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12),
                          ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}