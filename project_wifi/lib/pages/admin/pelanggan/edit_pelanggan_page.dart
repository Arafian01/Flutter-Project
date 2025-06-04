import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Animation<double> _scaleAnimation;

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _loadPakets() async {
    try {
      final list = await fetchPakets();
      setState(() {
        _pakets = list;
        _selectedPaket = _pakets.firstWhere(
              (x) => x.id == widget.pelanggan.paketId,
          orElse: () {
            if (_pakets.isNotEmpty) {
              return _pakets.first;
            }
            throw Exception('No packages available');
          },
        );
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat paket: $e');
      if (_pakets.isEmpty) {
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
    );
    if (picked != null) {
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
      'tanggal_aktif': _tanggalAktif!.toIso8601String(),
      'tanggal_langganan': _tanggalLangganan!.toIso8601String(),
    };
    if (_passwordCtrl.text.isNotEmpty) {
      if (_passwordCtrl.text.length < 6) {
        _showErrorDialog('Password minimal 6 karakter');
        setState(() => _isSaving = false);
        return;
      }
      data['password'] = _passwordCtrl.text;
    }
    try {
      await updatePelanggan(widget.pelanggan.id, data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pelanggan berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog('Gagal memperbarui pelanggan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
            title: Row(
              children: [
                Icon(Icons.error, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text('Gagal'),
              ],
            ),
            content: Text(message),
            actions: [
            TextButton(
            onPressed: () => Navigator.pop(context),
    child: const Text('OK', style: TextStyle(color: AppColors.accentRed)),
            )
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
        title: const Text('Edit Pelanggan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppSizes.iconSizeMedium),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
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
                        'Edit Pelanggan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          hintText: 'Masukkan nama',
                          prefixIcon: Icon(Icons.person, color: AppColors.textSecondaryBlue),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _emailCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Masukkan email',
                          prefixIcon: Icon(Icons.email, color: AppColors.textSecondaryBlue),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _passwordCtrl,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Kosongkan jika tidak diubah',
                          prefixIcon: Icon(Icons.lock, color: AppColors.textSecondaryBlue),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<Paket>(
                        value: _selectedPaket,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Paket',
                          prefixIcon: Icon(Icons.wifi, color: AppColors.textSecondaryBlue),
                        ),
                        items: _pakets.map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket))).toList(),
                        onChanged: (v) => setState(() => _selectedPaket = v),
                        validator: (v) => v == null ? 'Pilih paket' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _alamatCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          hintText: 'Masukkan alamat',
                          prefixIcon: Icon(Icons.home, color: AppColors.textSecondaryBlue),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _teleponCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Telepon wajib diisi';
                          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                            return 'Masukkan nomor telepon yang valid';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Telepon',
                          hintText: 'Masukkan telepon',
                          prefixIcon: Icon(Icons.phone, color: AppColors.textSecondaryBlue),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.toggle_on, color: AppColors.textSecondaryBlue),
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
                        trailing: Icon(Icons.calendar_today, color: AppColors.accentRed),
                        onTap: () => _pickDate(true),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ListTile(
                        title: Text(
                          _tanggalLangganan == null ? 'Pilih Tanggal Langganan' : _tanggalLangganan!.toLocal().toString().split(' ')[0],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                        trailing: Icon(Icons.calendar_today, color: AppColors.accentRed),
                        onTap: () => _pickDate(false),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSaving
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed)))
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _update,
                            child: const Text('Update'),
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
      ),
    );
  }
}