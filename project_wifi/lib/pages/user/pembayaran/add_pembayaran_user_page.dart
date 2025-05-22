import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class AddPembayaranUserPage extends StatefulWidget {
  const AddPembayaranUserPage({Key? key}) : super(key: key);

  @override
  State<AddPembayaranUserPage> createState() => _AddPembayaranUserPageState();
}

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> with SingleTickerProviderStateMixin {
  File? _image;
  bool _isLoading = false;
  final _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit(Tagihan tagihan) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar bukti pembayaran')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final pelangganData = prefs.getString('pelanggan_data');
      if (pelangganData == null) throw Exception('Data pelanggan tidak ditemukan');

      final data = jsonDecode(pelangganData) as Map<String, dynamic>;
      final pelangganId = data['pelanggan_id'] as int?;
      if (pelangganId == null) throw Exception('ID pelanggan tidak valid');

      await PembayaranService.createPembayaranUser(
        pelangganId: pelangganId,
        tagihanId: tagihan.id,
        bulanTahun: tagihan.bulanTahun,
        statusVerifikasi: 'menunggu_verifikasi',
        imageFile: _image!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil dikirim')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      final errorMessage = e.toString().contains('409')
          ? 'Tagihan ini sudah dibayar'
          : 'Gagal mengirim pembayaran: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatBulanTahun(String bulanTahun) {
    try {
      final parts = bulanTahun.split('-');
      if (parts.length != 2) return bulanTahun;
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return bulanTahun;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagihan = ModalRoute.of(context)!.settings.arguments as Tagihan?;

    if (tagihan == null) {
      return const Scaffold(
        body: Center(child: Text('Data tagihan tidak valid')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Tambah Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryRed, AppColors.secondaryRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode: ${formatBulanTahun(tagihan.bulanTahun)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Harga: Rp ${tagihan.harga}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Status: ${tagihan.statusPembayaran}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                'Bukti Pembayaran',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.primaryRed),
                  ),
                  child: _image == null
                      ? const Center(
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: AppColors.primaryRed,
                    ),
                  )
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submit(tagihan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Kirim Pembayaran', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}