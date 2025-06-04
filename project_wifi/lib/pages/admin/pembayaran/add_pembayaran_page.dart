import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class AddPembayaranPage extends StatefulWidget {
  const AddPembayaranPage({super.key});

  @override
  State<AddPembayaranPage> createState() => _AddPembayaranPageState();
}

class _AddPembayaranPageState extends State<AddPembayaranPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<Tagihan> _tagihans = [];
  Tagihan? _selected;
  String _status = 'menunggu_verifikasi';
  File? _image;
  bool _saving = false;
  bool _isLoadingTagihans = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadTagihans();
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTagihans() async {
    try {
      final tagihans = await TagihanService.fetchTagihans();
      setState(() {
        _tagihans = tagihans.where((t) => t.statusPembayaran != 'lunas').toList();
        _isLoadingTagihans = false;
      });
      if (_tagihans.isEmpty) {
        _showErrorDialog('Tidak ada tagihan yang belum lunas tersedia');
      }
    } catch (e) {
      setState(() => _isLoadingTagihans = false);
      _showErrorDialog('Gagal memuat tagihan: $e');
    }
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selected == null || _image == null) {
      if (_selected == null) {
        _showErrorDialog('Pilih tagihan terlebih dahulu');
      } else if (_image == null) {
        _showErrorDialog('Bukti pembayaran wajib diunggah');
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await PembayaranService.createPembayaran(
        tagihanId: _selected!.id,
        statusVerifikasi: _status,
        imageFile: _image!,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pembayaran berhasil disimpan');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (e.toString().contains('409')) {
        _showErrorDialog('Tagihan ini sudah pernah dibayar');
      } else {
        _showErrorDialog('Gagal menambah pembayaran: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.accentRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Gagal'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.accentRed)),
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
        title: const Text('Tambah Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
            size: AppSizes.iconSizeMedium,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
      ),
      body: _isLoadingTagihans
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
        ),
      )
          : Center(
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
                        'Buat Pembayaran Baru',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      DropdownButtonFormField<Tagihan>(
                        value: _selected,
                        decoration: InputDecoration(
                          labelText: 'Pilih Tagihan',
                          prefixIcon: const Icon(Icons.receipt, color: AppColors.textSecondaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.textSecondaryBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                          ),
                        ),
                        items: _tagihans.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text('${t.bulan}-${t.tahun} • ${_formatter.format(t.harga)} • ${t.pelangganName}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selected = v),
                        validator: (v) => v == null ? 'Pilih tagihan' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status Verifikasi',
                          prefixIcon: const Icon(Icons.verified, color: AppColors.textSecondaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.textSecondaryBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                          ),
                        ),
                        items: ['menunggu_verifikasi', 'diterima', 'ditolak']
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.replaceAll('_', ' ').toUpperCase()),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                        validator: (v) => v == null ? 'Pilih status' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Bukti Pembayaran',
                          prefixIcon: const Icon(Icons.image, color: AppColors.textSecondaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.textSecondaryBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_image != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                  child: Image.file(
                                    _image!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file, size: AppSizes.iconSizeSmall),
                              label: Text(_image == null ? 'Pilih Bukti' : 'Ganti Bukti'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryBlue,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _saving
                            ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                          ),
                        )
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                            ),
                            child: const Text('Simpan'),
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