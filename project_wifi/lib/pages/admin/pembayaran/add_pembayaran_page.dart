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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.white,
        elevation: 8,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            Text('Error', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue)),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview() {
    if (_image != null) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Image.file(
              _image!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Tambah Pembayaran',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: AppSizes.iconSizeMedium),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        elevation: 4,
      ),
      body: _isLoadingTagihans
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
          strokeWidth: 5,
        ),
      )
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 8,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.white, AppColors.backgroundLight.withOpacity(0.9)],
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Pembayaran Baru',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          DropdownButtonFormField<Tagihan>(
                            value: _selected,
                            decoration: InputDecoration(
                              labelText: 'Pilih Tagihan',
                              prefixIcon: Icon(Icons.receipt, color: AppColors.secondaryBlue),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide(color: AppColors.secondaryBlue.withOpacity(0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                              ),
                            ),
                            items: _tagihans.map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Text(
                                  '${t.bulan}-${t.tahun} • ${_formatter.format(t.harga)} • ${t.pelangganName}',
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                              prefixIcon: Icon(Icons.verified, color: AppColors.secondaryBlue),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide(color: AppColors.secondaryBlue.withOpacity(0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                              ),
                            ),
                            items: ['menunggu_verifikasi', 'diterima', 'ditolak'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.replaceAll('_', ' ').toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                            validator: (v) => v == null ? 'Pilih status' : null,
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Bukti Pembayaran',
                              prefixIcon: Icon(Icons.image, color: AppColors.secondaryBlue),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: BorderSide(color: AppColors.secondaryBlue.withOpacity(0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (_image != null)
                                  GestureDetector(
                                    onTap: _showImagePreview,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                        child: Image.file(
                                          _image!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: Icon(Icons.upload_file, size: AppSizes.iconSizeSmall),
                                  label: Text(_image == null ? 'Pilih Bukti' : 'Ganti Bukti'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryBlue,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
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
        ),
      ),
      floatingActionButton: _isLoadingTagihans || _saving
          ? null
          : FloatingActionButton(
        onPressed: _save,
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        tooltip: 'Simpan Pembayaran',
        child: const Icon(Icons.save, size: AppSizes.iconSizeMedium),
      ),
    );
  }
}