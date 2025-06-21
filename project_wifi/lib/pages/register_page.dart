import 'dart:convert';
import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../models/paket.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  List<Paket> _pakets = [];
  Paket? _selectedPaket;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadPakets();
  }

  void _loadPakets() async {
    try {
      final list = await fetchPakets();
      setState(() => _pakets = list);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat paket'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedPaket == null) {
      if (_selectedPaket == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih paket terlebih dahulu'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    final body = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'password_confirmation': _confirmCtrl.text,
      'paket_id': _selectedPaket!.id,
      'alamat': _alamatCtrl.text.trim(),
      'telepon': _teleponCtrl.text.trim(),
    };
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/register');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final msg = jsonDecode(resp.body)['error'] ?? 'Registrasi gagal';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
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
    } on async.TimeoutException {
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
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
                          child: _FormContent(
                            formKey: _formKey,
                            nameCtrl: _nameCtrl,
                            emailCtrl: _emailCtrl,
                            passwordCtrl: _passwordCtrl,
                            confirmCtrl: _confirmCtrl,
                            alamatCtrl: _alamatCtrl,
                            teleponCtrl: _teleponCtrl,
                            pakets: _pakets,
                            selectedPaket: _selectedPaket,
                            onPaketChanged: (v) => setState(() => _selectedPaket = v),
                            isPasswordVisible: _isPasswordVisible,
                            isConfirmPasswordVisible: _isConfirmPasswordVisible,
                            onPasswordVisibilityToggle: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                            onConfirmPasswordVisibilityToggle: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                            },
                            onRegister: _register,
                            isLoading: _isLoading,
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

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final TextEditingController alamatCtrl;
  final TextEditingController teleponCtrl;
  final List<Paket> pakets;
  final Paket? selectedPaket;
  final ValueChanged<Paket?> onPaketChanged;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;
  final VoidCallback onRegister;
  final bool isLoading;

  const _FormContent({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.alamatCtrl,
    required this.teleponCtrl,
    required this.pakets,
    required this.selectedPaket,
    required this.onPaketChanged,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
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
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          TextFormField(
            controller: nameCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nama wajib diisi';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Nama',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Masukkan nama Anda',
              prefixIcon: const Icon(Icons.person, color: AppColors.secondaryBlue),
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
          DropdownButtonFormField<Paket>(
            value: selectedPaket,
            decoration: InputDecoration(
              labelText: 'Pilih Paket',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(Icons.wifi, color: AppColors.secondaryBlue),
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
            items: pakets.map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket))).toList(),
            onChanged: onPaketChanged,
            validator: (v) => v == null ? 'Pilih paket' : null,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          TextFormField(
            controller: alamatCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Alamat wajib diisi';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Alamat',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Masukkan alamat Anda',
              prefixIcon: const Icon(Icons.home, color: AppColors.secondaryBlue),
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
            controller: teleponCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Telepon wajib diisi';
              if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) return 'Masukkan nomor telepon yang valid';
              return null;
            },
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telepon',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Masukkan nomor telepon Anda',
              prefixIcon: const Icon(Icons.phone, color: AppColors.secondaryBlue),
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
            controller: emailCtrl,
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
            controller: passwordCtrl,
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
          TextFormField(
            controller: confirmCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
              if (value != passwordCtrl.text) return 'Password tidak cocok';
              return null;
            },
            obscureText: !isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryBlue,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Konfirmasi password Anda',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.secondaryBlue),
              suffixIcon: IconButton(
                icon: Icon(
                  isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryBlue,
                ),
                onPressed: onConfirmPasswordVisibilityToggle,
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
          const SizedBox(height: AppSizes.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRegister,
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
                  : const Text('Daftar'),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false, arguments: 'role'),
            child: Text(
              'Masuk',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accentRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}