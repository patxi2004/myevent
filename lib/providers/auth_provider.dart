import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      
      // Guardar token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userId', _currentUser!.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(email, username, password);
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      
      // Guardar token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userId', _currentUser!.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (_token != null && userId != null) {
      try {
        _currentUser = await ApiService.getUserProfile(_token!, userId);
        notifyListeners();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    if (_currentUser == null || _token == null) return;

    try {
      _currentUser = await ApiService.updateUserProfile(_token!, _currentUser!.id, userData);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // DEBUG CODE - REMOVE BEFORE PRODUCTION
  // This method allows bypassing authentication for testing
  void setUser(User user, String token) {
    _currentUser = user;
    _token = token;
    notifyListeners();
  }
}
