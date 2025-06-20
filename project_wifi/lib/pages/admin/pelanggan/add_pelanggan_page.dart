import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import 'package:intl/intl.dart';

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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadPakets();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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

  Future<void> _loadPakets() async {
    try {
      final list = await fetchPakets();
      if (mounted) {
        setState(() => _pakets = list);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal memuat paket: $e');
      }
    }
  }

  Future<void> _pickDate(bool isAktif) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: AppColors.white,
            onSurface: AppColors.textSecondaryBlue,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
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
      'password': _password.text.trim(),
      'paket_id': _selectedPaket!.id,
      'status': _status,
      'alamat': _alamat.text.trim(),
      'telepon': _telepon.text.trim(),
      'tanggal_aktif': DateFormat('yyyy-MM-dd').format(_tanggalAktif!),
      'tanggal_langganan': DateFormat('yyyy-MM-dd').format(_tanggalLangganan!),
    };
    try {
      await createPelanggan(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pelanggan berhasil ditambahkan');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal menambah pelanggan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.accentRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'Gagal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryBlue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Tambah Pelanggan',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nama',
                              hintText: 'Masukkan nama',
                              prefixIcon: const Icon(Icons.person, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Masukkan email yang valid';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Masukkan email',
                              prefixIcon: const Icon(Icons.email, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Password wajib diisi';
                              if (value.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Masukkan password',
                              prefixIcon: const Icon(Icons.lock, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Paket>(
                            value: _selectedPaket,
                            decoration: InputDecoration(
                              labelText: 'Pilih Paket',
                              prefixIcon: const Icon(Icons.wifi, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            items: _pakets.map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket))).toList(),
                            onChanged: (v) => setState(() => _selectedPaket = v),
                            validator: (v) => v == null ? 'Pilih paket' : null,
                            style: const TextStyle(fontSize: 16, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamat,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Alamat',
                              hintText: 'Masukkan alamat',
                              prefixIcon: const Icon(Icons.home, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            maxLines: 2,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telepon,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Telepon wajib diisi';
                              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                                return 'Masukkan nomor telepon yang valid';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Telepon',
                              hintText: 'Masukkan telepon',
                              prefixIcon: const Icon(Icons.phone, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              prefixIcon: const Icon(Icons.toggle_on, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            items: ['aktif', 'nonaktif', 'isolir'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                            validator: (v) => v == null ? 'Pilih status' : null,
                            style: const TextStyle(fontSize: 16, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _pickDate(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.secondaryBlue, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.secondaryBlue),
                                  const SizedBox(width: 12),
                                  Text(
                                    _tanggalAktif == null
                                        ? 'Pilih Tanggal Aktif'
                                        : DateFormat('yyyy-MM-dd').format(_tanggalAktif!),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: _tanggalAktif == null ? AppColors.textSecondaryBlue : AppColors.primaryBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _pickDate(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.secondaryBlue, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.secondaryBlue),
                                  const SizedBox(width: 12),
                                  Text(
                                    _tanggalLangganan == null
                                        ? 'Pilih Tanggal Langganan'
                                        : DateFormat('yyyy-MM-dd').format(_tanggalLangganan!),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: _tanggalLangganan == null ? AppColors.textSecondaryBlue : AppColors.primaryBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _saving
                          ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 4,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
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