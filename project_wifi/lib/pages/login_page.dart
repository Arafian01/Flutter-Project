import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../widgets/strong_main_button.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';
import '../widgets/main_layout.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final user = body['user'] as Map<String, dynamic>;
        final role = user['role'] as String;
        final token = body['token'] as String?;
        final userId = user['id'] as int;

        if (token != null) {
          await _storage.write(key: 'token', value: token);
        }
        await _storage.write(key: 'role', value: role);
        await _storage.write(key: 'user_id', value: userId.toString());

        if (role == 'pelanggan') {
          try {
            final pelanggan = await fetchPelangganByUserId(userId);
            await _storage.write(
              key: 'pelanggan_id',
              value: pelanggan.id.toString(),
            );
            await _storage.write(key: 'name', value: pelanggan.name);
            await _storage.write(key: 'email', value: pelanggan.email);
            await _storage.write(key: 'telepon', value: pelanggan.telepon);
            await _storage.write(key: 'alamat', value: pelanggan.alamat);
            await _storage.write(key: 'namaPaket', value: pelanggan.namaPaket);
            await _storage.write(key: 'status', value: pelanggan.status);
            await _storage.write(key: 'tanggalAktif', value: pelanggan.tanggalAktif.toString());
            await _storage.write(key: 'tanggalLangganan', value: pelanggan.tanggalLangganan.toString());
          } catch (_) {
            // ignore if no pelanggan record found
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout(role: role)),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password salah')),
        );
      } else {
        final error = (jsonDecode(response.body) as Map<String, dynamic>)['error'] ?? 'Login gagal';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } on http.ClientException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server')),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu koneksi habis, coba lagi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Password',
              iconData: Icons.lock,
              controller: passwordController,
              isPassword: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StrongMainButton(
              label: 'Login',
              onTap: _login,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed('/register'),
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
