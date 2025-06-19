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
  try {
    initializeDateFormatting('id_ID');
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

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _submitPembayaran() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bukti pembayaran terlebih dahulu'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final pelangganData = prefs.getString('pelanggan_data');
      if (pelangganData == null) {
        throw Exception('Data pelanggan tidak ditemukan');
      }

      final data = jsonDecode(pelangganData) as Map<String, dynamic>;
      final pelangganId = data['pelanggan_id'] as int?;
      if (pelangganId == null) {
        throw Exception('ID pelanggan tidak ditemukan');
      }

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
          const SnackBar(
            content: Text('Pembayaran berhasil dikirim'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pembayaran: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Unggah Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: AppSizes.iconSizeMedium),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge, vertical: AppSizes.paddingMedium),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Tagihan',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: AppColors.secondaryBlue, size: AppSizes.iconSizeSmall),
                            const SizedBox(width: AppSizes.paddingSmall),
                            Text(
                              formatBulanTahunFromInt(widget.tagihan.bulan, widget.tagihan.tahun),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: AppColors.secondaryBlue, size: AppSizes.iconSizeSmall),
                            const SizedBox(width: AppSizes.paddingSmall),
                            Text(
                              _formatRupiah(widget.tagihan.harga),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.secondaryBlue, size: AppSizes.iconSizeSmall),
                            const SizedBox(width: AppSizes.paddingSmall),
                            Text(
                              widget.tagihan.statusPembayaran.replaceAll('_', ' ').toUpperCase(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.accentRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  // Image Upload Section
                  Text(
                    'Unggah Bukti Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _imageFile == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: AppSizes.iconSizeLarge,
                            color: AppColors.secondaryBlue.withOpacity(0.6),
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          Text(
                            'Pilih Gambar Bukti',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryBlue,
                            ),
                          ),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  // Submit Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _submitPembayaran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingLarge),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 4,
                      ),
                      child: const Text('Kirim Bukti Pembayaran'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}