import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/utils.dart';
import '../widgets/strong_main_button.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.mainThemeColor,
        title: const Text('Daftar Akun'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Utils.generateInputField(
              hintText: 'Email',
              iconData: Icons.email,
              controller: emailController,
              isPassword: false,
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Password',
              iconData: Icons.lock,
              controller: passwordController,
              isPassword: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Konfirmasi Password',
              iconData: Icons.lock_outline,
              controller: confirmController,
              isPassword: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 40),
            StrongMainButton(
              label: "Daftar",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
            )
          ],
        ),
      ),
    );
  }
}
