import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/main_layout.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final url = Uri.parse('${AppConstants.baseUrl}/login');
        final response = await http
            .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': emailController.text.trim(),
            'password': passwordController.text,
          }),
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
              await _storage.write(
                  key: 'tanggalAktif', value: pelanggan.tanggalAktif.toString());
              await _storage.write(
                  key: 'tanggalLangganan', value: pelanggan.tanggalLangganan.toString());
            } catch (_) {
              // ignore if no pelanggan record found
            }
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainLayout(role: role)),
          );
        } else if (response.statusCode == 401) {
          _showErrorDialog('Email atau password salah');
        } else {
          final error = (jsonDecode(response.body) as Map<String, dynamic>)['error'] ?? 'Login gagal';
          _showErrorDialog(error);
        }
      } on http.ClientException {
        _showErrorDialog('Tidak dapat terhubung ke server');
      } on TimeoutException {
        _showErrorDialog('Waktu koneksi habis, coba lagi');
      } catch (e) {
        _showErrorDialog('Kesalahan: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: isSmallScreen
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Logo(),
            _FormContent(
              formKey: _formKey,
              emailController: emailController,
              passwordController: passwordController,
              isPasswordVisible: _isPasswordVisible,
              rememberMe: _rememberMe,
              onPasswordVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onRememberMeChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              onLogin: _login,
              isLoading: _isLoading,
            ),
          ],
        )
            : Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              const Expanded(child: _Logo()),
              Expanded(
                child: Center(
                  child: _FormContent(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    rememberMe: _rememberMe,
                    onPasswordVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onRememberMeChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    onLogin: _login,
                    isLoading: _isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? AppSizes.paddingSmall : AppSizes.paddingMedium),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primaryRed, AppColors.secondaryRed],
            ),
          ),
          child: Icon(
            Icons.wifi,
            size: isSmallScreen ? AppSizes.iconSizeMedium : AppSizes.iconSizeLarge,
            color: AppColors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Text(
            "StrongNet",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool rememberMe;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLogin;
  final bool isLoading;

  const _FormContent({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.onPasswordVisibilityToggle,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Masukkan email Anda',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan password Anda',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onPasswordVisibilityToggle,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CheckboxListTile(
              value: rememberMe,
              onChanged: onRememberMeChanged,
              title: Text(
                'Remember me',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
              activeColor: AppColors.primaryRed,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                  onPressed: onLogin,
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.paddingMedium),
            Center(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.of(context).pushNamed('/register'),
                child: Text(
                  'Belum punya akun? Register di sini',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}