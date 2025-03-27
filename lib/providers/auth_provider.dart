import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool isAuth = false;
  String? _username;

  String? get username => _username;

  void login(String username) {
    isAuth = true;
    _username = username;
    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
     await Future.delayed(Duration(seconds: 2));
    // Clear any stored tokens or user data
    this.isAuth = false;
    _username = null;
    // Any other cleanup
    notifyListeners(); // Notify listeners that the state has changed
  }
}
