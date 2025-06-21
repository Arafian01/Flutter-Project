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

class _AddPembayaranPageState extends State<AddPembayaranPage> {
  final _formKey = GlobalKey<FormState>();
  List<Tagihan> _tagihans = [];
  Tagihan? _selected;
  String _status = 'menunggu_verifikasi';
  File? _image;
  bool _saving = false;
  bool _isLoadingTagihans = true;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadTagihans();
  }

  Future<void> _loadTagihans() async {
    try {
      final tagihans = await TagihanService.fetchTagihans();
      setState(() {
        _tagihans = tagihans.where((t) => t.statusPembayaran != 'lunas').toList();
        _isLoadingTagihans = false;
      });
      if (_tagihans.isEmpty) _showErrorDialog('Tidak ada tagihan yang belum lunas tersedia');
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
      if (_selected == null) _showErrorDialog('Pilih tagihan terlebih dahulu');
      else if (_image == null) _showErrorDialog('Bukti pembayaran wajib diunggah');
      return;
    }
    setState(() => _saving = true);
    try {
      await PembayaranService.createPembayaran(tagihanId: _selected!.id, statusVerifikasi: _status, imageFile: _image!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Pembayaran berhasil disimpan');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog(e.toString().contains('409') ? 'Tagihan ini sudah pernah dibayar' : 'Gagal menambah pembayaran: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(Icons.error_outline, color: AppColors.accentRed, size: 24),
          SizedBox(width: 8),
          Text('Error'),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.accentRed)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_image!, fit: BoxFit.contain),
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
        title: Text('Tambah Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoadingTagihans
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                      Text('Buat Pembayaran Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 16),
                      DropdownButtonFormField<Tagihan>(
                        value: _selected,
                        decoration: InputDecoration(
                          labelText: 'Pilih Tagihan',
                          prefixIcon: Icon(Icons.receipt),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Bukti Pembayaran',
                          prefixIcon: Icon(Icons.image),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Column(
                          children: [
                            if (_image != null)
                              GestureDetector(
                                onTap: _showImagePreview,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_image!, height: 100, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.upload_file, size: 20),
                              label: Text(_image == null ? 'Pilih Bukti' : 'Ganti Bukti'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryBlue,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
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
                            backgroundColor: AppColors.accentRed,
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