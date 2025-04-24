import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/utils.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/landing');
    });

    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi, color: Colors.white, size: 80),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
          ],
        ),
      ),
    );
  }
}
