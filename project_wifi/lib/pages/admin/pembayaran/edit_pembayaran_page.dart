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
    _existingImageUrl = widget.pembayaran.image.isNotEmpty ? '${AppConstants.baseUrl}${widget.pembayaran.image}' : null;
  }

  Future<void> _pickImage() async {
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (f != null) {
        final file = File(f.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5000000) { // 5MB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gambar terlalu besar. Maksimum 5MB.'),
              backgroundColor: AppColors.accentRed,
            ),
          );
          return;
        }
        setState(() => _image = file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await PembayaranService.updatePembayaran(id: widget.pembayaran.id, statusVerifikasi: _status, imageFile: _image);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pembayaran berhasil diperbarui');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pembayaran: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Edit Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status Verifikasi',
                          prefixIcon: Icon(Icons.verified),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['menunggu_verifikasi', 'diterima', 'ditolak']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                        validator: (v) => v == null ? 'Pilih status' : null,
                      ),
                      SizedBox(height: 12),
                      Text('Bukti Pembayaran:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_image!, height: 100, width: double.infinity, fit: BoxFit.cover),
                      )
                          : _existingImageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrl!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null ? child : CircularProgressIndicator(),
                          errorBuilder: (context, error, stackTrace) => Text('Gagal memuat gambar'),
                        ),
                      )
                          : Text('Gambar tidak tersedia'),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload_file, size: 20),
                        label: Text('Pilih Gambar Baru'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(height: 16),
                      _saving
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Simpan'),
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