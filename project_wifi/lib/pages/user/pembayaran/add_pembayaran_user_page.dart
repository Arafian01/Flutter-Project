import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../services/api_service.dart';
import '../../../models/tagihan.dart';
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
  final int pelangganId;

  const AddPembayaranUserPage({
    Key? key,
    required this.tagihan,
    required this.pelangganId,
  }) : super(key: key);

  @override
  State<AddPembayaranUserPage> createState() => _AddPembayaranUserPageState();
}

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> {
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submitPembayaran() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bukti pembayaran terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await PembayaranService.createPembayaranUser(
        pelangganId: widget.pelangganId,
        tagihanId: widget.tagihan.id,
        bulan: widget.tagihan.bulan,
        tahun: widget.tagihan.tahun,
        statusVerifikasi: 'menunggu_verifikasi',
        imageFile: _imageFile!,
      );
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil dikirim')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
        backgroundColor: AppColors.primaryRed,
        title: const Text('Tambah Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Tagihan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text('Bulan: ${formatBulanTahunFromInt(widget.tagihan.bulan, widget.tagihan.tahun)}'), // Updated
                      Text('Harga: ${_formatRupiah(widget.tagihan.harga)}'),
                      Text('Status: ${widget.tagihan.statusPembayaran}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              const Text(
                'Bukti Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text('Ketuk untuk pilih gambar'))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                  onPressed: _submitPembayaran,
                  child: const Text('Kirim Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}