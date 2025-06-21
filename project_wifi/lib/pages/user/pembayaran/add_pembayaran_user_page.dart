import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

String formatBulanTahunFromInt(int bulan, int tahun) {
  initializeDateFormatting('id_ID');
  try {
    final date = DateTime(tahun, bulan);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  } catch (e) {
    return '$bulan-$tahun';
  }
}

class AddPembayaranUserPage extends StatefulWidget {
  final Tagihan tagihan;

  const AddPembayaranUserPage({super.key, required this.tagihan});

  @override
  State<AddPembayaranUserPage> createState() => _AddPembayaranUserPageState();
}

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> {
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) setState(() => _imageFile = File(picked.path));
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
    }
  }

  Future<void> _submitPembayaran() async {
    if (_imageFile == null) {
      _showErrorDialog('Pilih bukti pembayaran terlebih dahulu');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final pelangganData = prefs.getString('pelanggan_data');
      if (pelangganData == null) throw Exception('Data pelanggan tidak ditemukan');
      final data = jsonDecode(pelangganData) as Map<String, dynamic>;
      final pelangganId = data['pelanggan_id'] as int?;
      if (pelangganId == null) throw Exception('ID pelanggan tidak ditemukan');
      await PembayaranService.createPembayaranUser(
        pelangganId: pelangganId,
        tagihanId: widget.tagihan.id,
        bulan: widget.tagihan.bulan,
        tahun: widget.tagihan.tahun,
        statusVerifikasi: 'menunggu_verifikasi',
        imageFile: _imageFile!,
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pembayaran berhasil dikirim'), backgroundColor: AppColors.primaryBlue),
        );
      }
    } catch (e) {
      _showErrorDialog('Gagal mengirim pembayaran: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Unggah Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detail Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: AppColors.secondaryBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              formatBulanTahunFromInt(widget.tagihan.bulan, widget.tagihan.tahun),
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: AppColors.secondaryBlue, size: 20),
                            SizedBox(width: 8),
                            Text(_formatRupiah(widget.tagihan.harga), style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.secondaryBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              widget.tagihan.statusPembayaran.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(fontSize: 14, color: AppColors.accentRed, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('Unggah Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3)),
                    ),
                    child: _imageFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 40, color: AppColors.secondaryBlue.withOpacity(0.6)),
                        SizedBox(height: 8),
                        Text('Pilih Gambar Bukti', style: TextStyle(fontSize: 14)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.cover, height: 150, width: double.infinity),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitPembayaran,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Kirim Bukti Pembayaran', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}