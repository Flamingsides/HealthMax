import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:http/http.dart' as http; // Developer will uncomment this!

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  
  // These will store the session data once the user logs in
  String? authToken;
  String? currentRole; // 'user' or 'hp'
  String? currentUsername;

  // ========================================================
  // 🚀 FAST-API: LOGIN ENDPOINT
  // ========================================================
  Future<bool> login(String username, String password, String role) async {
    isLoading = true;
    notifyListeners();

    try {
      // TODO: DEVELOPER - Replace with actual FastAPI POST request
      /*
      final response = await http.post(
        Uri.parse('https://your-fastapi-url.com/api/auth/login'),
        body: jsonEncode({'username': username, 'password': password, 'role': role}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['access_token'];
        currentRole = role;
        currentUsername = username;
        return true;
      }
      return false; // Invalid credentials
      */

      // --- MOCK DATABASE DELAY ---
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock Success
      authToken = "mock_jwt_token_12345";
      currentRole = role;
      currentUsername = username;
      return true;

    } catch (e) {
      print("Login Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================================================
  // 🚀 FAST-API: REGISTER ENDPOINT (Base Account Creation)
  // ========================================================
  Future<bool> registerBaseAccount(String username, String email, String password, String role) async {
    isLoading = true;
    notifyListeners();

    try {
      // TODO: DEVELOPER - Replace with actual FastAPI POST request
      /*
      final response = await http.post(
        Uri.parse('https://your-fastapi-url.com/api/auth/register'),
        body: jsonEncode({'username': username, 'email': email, 'password': password, 'role': role}),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 201 || response.statusCode == 200;
      */

      // --- MOCK DATABASE DELAY ---
      await Future.delayed(const Duration(seconds: 2));
      return true;

    } catch (e) {
      print("Registration Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}