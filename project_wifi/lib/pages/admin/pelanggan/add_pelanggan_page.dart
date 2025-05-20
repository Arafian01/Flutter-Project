// lib/pages/add_pelanggan_page.dart
import 'package:flutter/material.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../widgets/strong_main_button.dart';
import '../../../utils/utils.dart';

class AddPelangganPage extends StatefulWidget {
  const AddPelangganPage({super.key});

  @override
  State<AddPelangganPage> createState() => _AddPelangganPageState();
}

class _AddPelangganPageState extends State<AddPelangganPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _alamat = TextEditingController();
  final _telepon = TextEditingController();
  DateTime? _tanggalAktif;
  DateTime? _tanggalLangganan;
  String _status = 'aktif';
  List<Paket> _pakets = [];
  Paket? _selectedPaket;
  bool _saving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPakets();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _alamat.dispose();
    _telepon.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _loadPakets() async {
    try {
      final list = await fetchPakets();
      setState(() => _pakets = list);
    } catch (e) {
      _showErrorDialog('Gagal memuat paket: $e');
    }
  }

  Future<void> _pickDate(bool isAktif) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isAktif ? _tanggalAktif = picked : _tanggalLangganan = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPaket == null || _tanggalAktif == null || _tanggalLangganan == null) {
      if (_selectedPaket == null) {
        _showErrorDialog('Pilih paket terlebih dahulu');
      } else if (_tanggalAktif == null) {
        _showErrorDialog('Pilih tanggal aktif terlebih dahulu');
      } else if (_tanggalLangganan == null) {
        _showErrorDialog('Pilih tanggal langganan terlebih dahulu');
      }
      return;
    }
    setState(() => _saving = true);
    final data = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'paket_id': _selectedPaket!.id,
      'status': _status,
      'alamat': _alamat.text.trim(),
      'telepon': _telepon.text.trim(),
      'tanggal_aktif': _tanggalAktif!.toIso8601String(),
      'tanggal_langganan': _tanggalLangganan!.toIso8601String(),
    };
    try {
      await createPelanggan(data);
      _showSuccessDialog('Pelanggan berhasil disimpan');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog('Gagal menambah pelanggan: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Berhasil'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Gagal'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Tambah Pelanggan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: const Icon(
          Icons.wifi,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Pelanggan Baru',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      TextFormField(
                        controller: _name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          hintText: 'Masukkan nama',
                          prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _email,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Masukkan email',
                          prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _password,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: Icon(Icons.lock, color: AppColors.textSecondary),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<Paket>(
                        value: _selectedPaket,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Paket',
                          prefixIcon: Icon(Icons.wifi, color: AppColors.textSecondary),
                        ),
                        items: _pakets.map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket))).toList(),
                        onChanged: (v) => setState(() => _selectedPaket = v),
                        validator: (v) => v == null ? 'Pilih paket' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _alamat,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          hintText: 'Masukkan alamat',
                          prefixIcon: Icon(Icons.home, color: AppColors.textSecondary),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _telepon,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Telepon wajib diisi';
                          }
                          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                            return 'Masukkan nomor telepon yang valid';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Telepon',
                          hintText: 'Masukkan telepon',
                          prefixIcon: Icon(Icons.phone, color: AppColors.textSecondary),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.toggle_on, color: AppColors.textSecondary),
                        ),
                        items: ['aktif', 'nonaktif', 'isolir'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _status = v!),
                        validator: (v) => v == null ? 'Pilih status' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ListTile(
                        title: Text(
                          _tanggalAktif == null ? 'Pilih Tanggal Aktif' : _tanggalAktif!.toLocal().toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                        trailing: Icon(Icons.calendar_today, color: AppColors.primaryRed),
                        onTap: () => _pickDate(true),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ListTile(
                        title: Text(
                          _tanggalLangganan == null ? 'Pilih Tanggal Langganan' : _tanggalLangganan!.toLocal().toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                        trailing: Icon(Icons.calendar_today, color: AppColors.primaryRed),
                        onTap: () => _pickDate(false),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _saving
                            ? const Center(child: CircularProgressIndicator())
                            : StrongMainButton(
                          label: 'Simpan',
                          onTap: _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}