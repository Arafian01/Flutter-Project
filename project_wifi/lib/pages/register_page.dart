import 'dart:convert';
import 'package:flutter/material.dart';
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
    } catch (_) {}
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedPaket == null) return;
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
        _showErrorDialog(msg);
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi Gagal'),
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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text(
          'Daftar Akun',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        leading: const Icon(
          Icons.wifi,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
      ),
      body: Center(
        child: isSmallScreen
            ? SingleChildScrollView(
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
        )
            : Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'StrongNet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            TextFormField(
              controller: nameCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Nama wajib diisi';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama Anda',
                prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            DropdownButtonFormField<Paket>(
              decoration: const InputDecoration(
                labelText: 'Pilih Paket',
                prefixIcon: Icon(Icons.wifi, color: AppColors.textSecondary),
              ),
              items: pakets
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket)))
                  .toList(),
              onChanged: onPaketChanged,
              validator: (v) => v == null ? 'Pilih paket' : null,
              value: selectedPaket,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: alamatCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Alamat wajib diisi';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Alamat',
                hintText: 'Masukkan alamat Anda',
                prefixIcon: Icon(Icons.home, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: teleponCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Telepon wajib diisi';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Telepon',
                hintText: 'Masukkan nomor telepon Anda',
                prefixIcon: Icon(Icons.phone, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              controller: emailCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email wajib diisi';
                bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) return 'Masukkan email yang valid';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Masukkan email Anda',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
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
                hintText: 'Masukkan password Anda',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
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
                hintText: 'Konfirmasi password Anda',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onConfirmPasswordVisibilityToggle,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
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
                  onPressed: onRegister,
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}