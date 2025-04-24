import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/utils.dart';


class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.mainThemeColor,
        title: const Text("Welcome"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat Datang di Strong WiFi Manager!',
              style: TextStyle(
                color: Utils.mainThemeColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Utils.mainThemeColor,
              ),
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                "Daftar Akun Baru",
                style: TextStyle(color: Utils.mainThemeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
