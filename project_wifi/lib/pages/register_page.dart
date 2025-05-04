// lib/pages/register_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../utils/utils.dart';
import '../widgets/strong_main_button.dart';
import '../models/paket.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RegisterPage extends StatefulWidget {
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
      final url = Uri.parse('$baseUrl/register');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final msg = jsonDecode(resp.body)['error'] ?? 'Registrasi gagal';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.mainThemeColor,
        title: const Text('Daftar Akun'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Utils.generateInputField(
                hintText: 'Name',
                iconData: Icons.person,
                controller: _nameCtrl,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Paket>(
                decoration: const InputDecoration(labelText: 'Pilih Paket'),
                items: _pakets
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPaket = v),
                validator: (v) => v == null ? 'Pilih paket' : null,
              ),
              const SizedBox(height: 16),
              Utils.generateInputField(
                hintText: 'Alamat',
                iconData: Icons.home,
                controller: _alamatCtrl,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              Utils.generateInputField(
                hintText: 'Telepon',
                iconData: Icons.phone,
                controller: _teleponCtrl,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              Utils.generateInputField(
                hintText: 'Email',
                iconData: Icons.email,
                controller: _emailCtrl,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              Utils.generateInputField(
                hintText: 'Password',
                iconData: Icons.lock,
                controller: _passwordCtrl,
                isPassword: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              Utils.generateInputField(
                hintText: 'Konfirmasi Password',
                iconData: Icons.lock_outline,
                controller: _confirmCtrl,
                isPassword: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StrongMainButton(label: 'Daftar', onTap: _register),
            ],
          ),
        ),
      ),
    );
  }
}