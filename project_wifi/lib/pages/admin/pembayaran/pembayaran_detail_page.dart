import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/pembayaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';

class PembayaranDetailPage extends StatefulWidget {
  final Pembayaran pembayaran;

  const PembayaranDetailPage({super.key, required this.pembayaran});

  @override
  State<PembayaranDetailPage> createState() => _PembayaranDetailPageState();
}

class _PembayaranDetailPageState extends State<PembayaranDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  String _formatBulanTahun(int month, int year) {
    try {
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '$month-$year';
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  void _showDeleteDialog(Pembayaran pembayaran) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Hapus pembayaran untuk ${pembayaran.pelangganName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PembayaranService.deletePembayaran(pembayaran.id);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('success_message', 'Pembayaran berhasil dihapus');
                if (mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus: $e'),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
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
        ),
      ),
    );
  }

  Widget _buildPembayaranCard(Pembayaran pembayaran) {
    final imageUrl = pembayaran.image.isNotEmpty ? '${AppConstants.baseUrl}${pembayaran.image}' : null;

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 300),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payment,
                        size: AppSizes.iconSizeMedium,
                        color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pembayaran.pelangganName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatBulanTahun(pembayaran.bulan, pembayaran.tahun),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatter.format(pembayaran.harga),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatStatus(pembayaran.statusVerifikasi),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  'Detail Pembayaran',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Row(
                  children: [
                    Text(
                      'Tagihan ID: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        pembayaran.tagihanId.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Tanggal Kirim: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _dateFormatter.format(pembayaran.tanggalKirim.toLocal()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                if (pembayaran.tanggalVerifikasi != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Tanggal Verifikasi: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _dateFormatter.format(pembayaran.tanggalVerifikasi!.toLocal()),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  'Bukti Pembayaran',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                imageUrl != null
                    ? GestureDetector(
                  onTap: () => _showImagePreview(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    child: Image.network(
                      imageUrl,
                      height: MediaQuery.of(context).size.width < 600 ? 120 : 150,
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
                  ),
                )
                    : const Text(
                  'Gambar tidak tersedia',
                  style: TextStyle(color: AppColors.textSecondaryBlue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Detail Pembayaran',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            _buildPembayaranCard(widget.pembayaran),
            const SizedBox(height: AppSizes.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/edit_pembayaran', arguments: widget.pembayaran);
                    if (result == true && mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('success_message', 'Pembayaran berhasil diubah');
                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit, size: AppSizes.iconSizeSmall),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(widget.pembayaran),
                  icon: const Icon(Icons.delete, size: AppSizes.iconSizeSmall),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}