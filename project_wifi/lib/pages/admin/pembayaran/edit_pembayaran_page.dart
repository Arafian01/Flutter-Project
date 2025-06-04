import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/pembayaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../utils/constants.dart';

class EditPembayaranPage extends StatefulWidget {
  final Pembayaran pembayaran;

  const EditPembayaranPage({super.key, required this.pembayaran});

  @override
  State<EditPembayaranPage> createState() => _EditPembayaranPageState();
}

class _EditPembayaranPageState extends State<EditPembayaranPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = '';
  File? _image;
  String? _existingImageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.pembayaran.statusVerifikasi;
    _existingImageUrl = widget.pembayaran.image.isNotEmpty
        ? '${AppConstants.baseUrl}${widget.pembayaran.image}'
        : null;
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) {
      setState(() {
        _image = File(f.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await PembayaranService.updatePembayaran(
        id: widget.pembayaran.id,
        statusVerifikasi: _status,
        imageFile: _image,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pembayaran berhasil diperbarui');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui pembayaran: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Edit Pembayaran'),
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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Pembayaran',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
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
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                    validator: (v) => v == null ? 'Pilih status' : null,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  const Text(
                    'Bukti Pembayaran:',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : _existingImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.network(
                      _existingImageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: AppColors.textSecondaryBlue),
                        );
                      },
                    ),
                  )
                      : const Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(color: AppColors.textSecondaryBlue),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file, size: AppSizes.iconSizeSmall),
                    label: const Text('Pilih Gambar Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
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
    );
  }
}