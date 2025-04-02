import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timetrack/models/employe.model.dart';

class AuthProvider with ChangeNotifier {
  Employe? _employe;
  bool _isLoading = false;
  bool _isAuth = false;

  Employe? get employe => _employe;
  bool get isLoading => _isLoading;
  bool get isAuth => _isAuth;

  Future<void> loadEmploye() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeString = prefs.getString('employe');

      if (employeString != null) {
        _employe = Employe.fromJson(jsonDecode(employeString));
      }
    } catch (e) {
      print('Error loading employe: $e');
      _employe = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(Employe employe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employe', jsonEncode(employe.toJson()));
      await prefs.setBool('isLoggedIn', true);

      _employe = employe;
    } catch (e) {
      print('Error saving employe: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('employe');
      await prefs.setBool('isLoggedIn', false);

      _employe = null;
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuth = prefs.getBool('isLoggedIn') ?? false;

      if (_isAuth) {
        final employeString = prefs.getString('employe');
        if (employeString != null) {
          _employe = Employe.fromJson(jsonDecode(employeString));
        } else {
          // If isLoggedIn is true but no employe data, consider not authenticated
          _isAuth = false;
          await prefs.setBool('isLoggedIn', false);
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
      _isAuth = false;
      _employe = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
