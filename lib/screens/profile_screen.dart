// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();
    final user = await apiService.getUsers();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${_user?['username'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: ${_user?['email'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Address: ${_user?['adresse'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Phone: ${_user?['telephone'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Role: ${_user?['role'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}