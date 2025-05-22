import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
    // print('Existing image URL: $_existingImageUrl'); // Log untuk debugging
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) {
      setState(() {
        _image = File(f.path);
        print('New image selected: ${_image!.path}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui pembayaran: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Pembayaran'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Pembayaran',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status Verifikasi',
                      prefixIcon: const Icon(Icons.verified, color: AppColors.primaryRed),
                      filled: true,
                      fillColor: AppColors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                      ),
                    ),
                    items: ['menunggu_verifikasi', 'diterima', 'ditolak']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                    validator: (v) => v == null ? 'Pilih status' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _image != null
                      ? Image.file(
                    _image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : _existingImageUrl != null
                      ? Image.network(
                    _existingImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Text('Gagal memuat gambar');
                    },
                  )
                      : const Text('Gambar tidak tersedia'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file, size: AppSizes.iconSizeSmall),
                    label: const Text('Pilih Gambar Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _saving
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: AppColors.white,
                          elevation: 2,
                        ),
                        onPressed: _save,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}