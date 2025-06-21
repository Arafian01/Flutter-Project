import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final userId = prefs.getInt('user_id');
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi, color: AppColors.white, size: 60),
              SizedBox(height: 16),
              Text(
                'StrongNet',
                style: TextStyle(fontSize: 24, color: AppColors.white, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }
}