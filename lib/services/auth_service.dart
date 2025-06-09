// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/jwt_decoder.dart'; // <--- Ce chemin DOIT être correct !

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  String? _token;
  String? _refreshToken;
  Map<String, dynamic>? _currentUser;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthService() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);

    if (_token != null) {
      try {
        _currentUser = await _extractUserDataFromToken(_token!);
      } catch (e) {
        debugPrint('Error loading user data from token: $e');
        await logout();
      }
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  // Cette méthode est cruciale
  Future<Map<String, dynamic>> _extractUserDataFromToken(
      String accessToken) async {
    try {
      final payload =
          decodeJwt(accessToken); // <--- L'appel à decodeJwt est ici.
      final userId = payload['user_id'] as int?;
      final username = payload['username'] as String?;
      final role = payload['role'] as String?;

      final userData = {
        'id': userId,
        'username': username,
        'role': role,
      };
      return userData;
    } catch (e) {
      debugPrint('Error decoding JWT or extracting user data: $e');
      rethrow;
    }
  }

  Future<void> _saveAuthData(
    String token,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);

    _currentUser = await _extractUserDataFromToken(token);
    await prefs.setString(_userKey, json.encode(_currentUser));

    _token = token;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      await _saveAuthData(
        response['access'],
        response['refresh'],
      );
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(Map<String, dynamic> userData, String role) async {
    try {
      final data = {...userData, 'role': role};
      final response = await _apiService.signup(data);

      if (response['access'] != null) {
        await _saveAuthData(
          response['access'],
          response['refresh'],
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _apiService.refreshToken(_refreshToken!);
      await _saveAuthData(
        response['access'],
        _refreshToken!,
      );
      return true;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);

    _token = null;
    _refreshToken = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    return _token != null &&
        _currentUser != null &&
        _currentUser!['id'] != null;
  }

  ApiService getApiService() {
    return ApiService(token: _token);
  }
}
