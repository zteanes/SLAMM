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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
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
                  ElevatedButton(
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
                    child: const Text('Sign Up'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Login()));
                    },
                    child: const  Text('Already have an account? Log in'),
                  ),
                  Text(_error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}