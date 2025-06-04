import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/pembayaran.dart';
import '../../../utils/utils.dart';
import '../../../utils/constants.dart';

String formatBulanTahunFromInt(int bulan, int tahun) {
  initializeDateFormatting('id_ID');
  try {
    final date = DateTime(tahun, bulan);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  } catch (e) {
    return '$bulan-$tahun';
  }
}

class DetailPembayaranPage extends StatelessWidget {
  final Pembayaran pembayaran;

  const DetailPembayaranPage({super.key, required this.pembayaran});

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID');
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Detail Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: AppSizes.iconSizeMedium),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode: ${formatBulanTahunFromInt(pembayaran.bulan, pembayaran.tahun)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Harga: ${_formatRupiah(pembayaran.harga)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Status: ${pembayaran.statusVerifikasi.replaceAll('_', ' ').toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: pembayaran.statusVerifikasi == 'diterima'
                              ? Colors.green
                              : pembayaran.statusVerifikasi == 'ditolak'
                              ? AppColors.accentRed
                              : AppColors.secondaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Tanggal Pengiriman: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalKirim)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                      if (pembayaran.tanggalVerifikasi != null)
                        Text(
                          'Tanggal Verifikasi: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalVerifikasi!)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Pelanggan ID: ${pembayaran.pelangganName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Text(
                        'Bukti Pembayaran:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      if (pembayaran.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          child: Image.network(
                            '${AppConstants.baseUrl}${pembayaran.image}',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                                ),
                              );
                            },
                            errorBuilder: (ctx, error, stackTrace) => const Text(
                              'Gagal memuat gambar',
                              style: TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Gambar tidak tersedia',
                          style: TextStyle(color: AppColors.textSecondaryBlue),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}