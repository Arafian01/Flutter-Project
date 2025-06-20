import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../models/pelanggan.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class EditPelangganPage extends StatefulWidget {
  final Pelanggan pelanggan;
  const EditPelangganPage({super.key, required this.pelanggan});

  @override
  State<EditPelangganPage> createState() => _EditPelangganPageState();
}

class _EditPelangganPageState extends State<EditPelangganPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _teleponCtrl;
  DateTime? _tanggalAktif;
  DateTime? _tanggalLangganan;
  String _status = 'aktif';
  List<Paket> _pakets = [];
  Paket? _selectedPaket;
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final p = widget.pelanggan;
    _nameCtrl = TextEditingController(text: p.name);
    _emailCtrl = TextEditingController(text: p.email);
    _passwordCtrl = TextEditingController();
    _alamatCtrl = TextEditingController(text: p.alamat);
    _teleponCtrl = TextEditingController(text: p.telepon);
    _tanggalAktif = p.tanggalAktif;
    _tanggalLangganan = p.tanggalLangganan;
    _status = p.status;
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPakets() async {
    try {
      final list = await fetchPakets();
      if (mounted) {
        setState(() {
          _pakets = list;
          _selectedPaket = _pakets.isNotEmpty
              ? _pakets.firstWhere(
                (x) => x.id == widget.pelanggan.paketId,
            orElse: () => _pakets.first,
          )
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal memuat paket: $e');
        setState(() => _selectedPaket = null);
      }
    }
  }

  Future<void> _pickDate(bool isAktif) async {
    final initial = isAktif ? _tanggalAktif ?? DateTime.now() : _tanggalLangganan ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _update() async {
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
    setState(() => _isSaving = true);
    final data = {
      'user_id': widget.pelanggan.userId,
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'paket_id': _selectedPaket!.id,
      'status': _status,
      'alamat': _alamatCtrl.text.trim(),
      'telepon': _teleponCtrl.text.trim(),
      'tanggal_aktif': DateFormat('yyyy-MM-dd').format(_tanggalAktif!),
      'tanggal_langganan': DateFormat('yyyy-MM-dd').format(_tanggalLangganan!),
    };
    if (_passwordCtrl.text.isNotEmpty) {
      if (_passwordCtrl.text.length < 6) {
        _showErrorDialog('Password minimal 6 karakter');
        setState(() => _isSaving = false);
        return;
      }
      data['password'] = _passwordCtrl.text.trim();
    }
    try {
      await updatePelanggan(widget.pelanggan.id, data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pelanggan berhasil diperbarui');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal memperbarui pelanggan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          'Edit Pelanggan',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
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
                    Text(
                      'Edit Pelanggan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
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
                            controller: _nameCtrl,
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
                            controller: _emailCtrl,
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
                            controller: _passwordCtrl,
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Kosongkan jika tidak diubah',
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
                            controller: _alamatCtrl,
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
                            controller: _teleponCtrl,
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
                      child: _isSaving
                          ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _update,
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
                        child: const Text('Update'),
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