import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  late final StreamSubscription<User?> _sub;

  AuthService() {
    _sub = _firebaseAuth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  // Initialize by checking if user is already logged in
  Future<void> init() async {
    _user = _firebaseAuth.currentUser;
    notifyListeners();
  }

// Login with Firebase Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error: ${e.code} - ${e.message}');
      return {'success': false, 'error': _getLoginErrorMessage(e.code)};
    }
  }

  String _getLoginErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for that email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a bit';
      default:
        return 'Login failed. Please try again';
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase SignUp Error: ${e.code} - ${e.message}');
      return {'success': false, 'error': _getErrorMessage(e.code)};
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Failed to create account. Please try again';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
