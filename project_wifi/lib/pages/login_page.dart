import 'package:flutter/material.dart';
import '../utils/utils.dart';
import '../widgets/strong_main_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            CircleAvatar(
              radius: 40,
              backgroundColor: Utils.mainThemeColor.withOpacity(0.1),
              child: Icon(
                Icons.wifi,
                size: 40,
                color: Utils.mainThemeColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome back',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Text(
              'Strong WiFi Manager',
              style: TextStyle(
                color: Utils.mainThemeColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Utils.generateInputField(
              hintText: 'Email',
              iconData: Icons.email,
              controller: emailController,
              isPassword: false,
              onChanged: (text) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Password',
              iconData: Icons.lock,
              controller: passwordController,
              isPassword: true,
              onChanged: (text) => setState(() {}),
            ),
            const SizedBox(height: 40),
            StrongMainButton(
              label: 'Login',
              onTap: () {
                // Simulasikan login dan navigasi ke halaman utama
                Navigator.of(context).pushReplacementNamed('/main');
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: Text(
                  'Belum punya akun? Register di sini',
                  style: TextStyle(color: Utils.mainThemeColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
