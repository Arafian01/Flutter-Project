import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/main_layout.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _submit() async {
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
          final userId = user['id'] as int;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', role);
          await prefs.setInt('user_id', userId);

          if (role == 'pelanggan') {
            try {
              final pelanggan = await fetchPelangganByUserId(userId);
              final pelangganData = jsonEncode({
                'pelanggan_id': pelanggan.id,
                'name': pelanggan.name,
                'email': pelanggan.email,
                'telepon': pelanggan.telepon,
                'alamat': pelanggan.alamat,
                'namaPaket': pelanggan.namaPaket,
                'status': pelanggan.status,
                'tanggalAktif': pelanggan.tanggalAktif.toString(),
                'tanggalLangganan': pelanggan.tanggalLangganan.toString(),
              });
              await prefs.setString('pelanggan_data', pelangganData);
            } catch (_) {}
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainLayout(role: role)),
          );
        } else {
          final error = response.statusCode == 401
              ? 'Email atau password salah'
              : (jsonDecode(response.body) as Map<String, dynamic>)['error'] ?? 'Login gagal';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      } on http.ClientException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat terhubung ke server'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      } on TimeoutException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu koneksi habis, coba lagi'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kesalahan: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 300),
                  childAnimationBuilder: (widget) => FadeInAnimation(child: widget),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingLarge),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _Logo(),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _FormContent(
                                formKey: _formKey,
                                emailController: emailController,
                                passwordController: passwordController,
                                isPasswordVisible: _isPasswordVisible,
                                rememberMe: _rememberMe,
                                onPasswordVisibilityToggle: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                                onRememberMeChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                onLogin: _submit,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue,
          ),
          child: const Icon(
            Icons.wifi,
            size: AppSizes.iconSizeLarge,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          'StrongNet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
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
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email wajib diisi';
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                return 'Masukkan email yang valid';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Masukkan email Anda',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: BorderSide(color: AppColors.textSecondaryBlue.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: BorderSide(color: AppColors.textSecondaryBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          TextFormField(
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password wajib diisi';
              if (value.length < 6) return 'Password minimal 6 karakter';
              return null;
            },
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Masukkan password Anda',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.secondaryBlue),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryBlue,
                ),
                onPressed: onPasswordVisibilityToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: BorderSide(color: AppColors.textSecondaryBlue.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: BorderSide(color: AppColors.textSecondaryBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: onRememberMeChanged,
                    activeColor: AppColors.accentRed,
                    checkColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    'Ingat saya',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryBlue,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Daftar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 2,
              )
                  : const Text('Masuk'),
            ),
          ),
        ],
      ),
    );
  }
}