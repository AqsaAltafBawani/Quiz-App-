// firebase_auth.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Check if user is an admin (you can modify this logic based on your requirements)
  bool get isAdmin => _auth.currentUser?.email == 'admin@example.com';

  // Sign up method
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign in method
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
