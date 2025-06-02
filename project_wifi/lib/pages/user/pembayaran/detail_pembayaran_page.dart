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

  const DetailPembayaranPage({Key? key, required this.pembayaran}) : super(key: key);

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
        title: const Text('Detail Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
                    'Periode: ${formatBulanTahunFromInt(pembayaran.bulan, pembayaran.tahun)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Harga: ${_formatRupiah(pembayaran.harga)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Status Verifikasi: ${pembayaran.statusVerifikasi}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: pembayaran.statusVerifikasi == 'diterima'
                          ? Colors.green
                          : pembayaran.statusVerifikasi == 'ditolak'
                          ? Colors.red
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Tanggal Kirim: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalKirim)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  if (pembayaran.tanggalVerifikasi != null)
                    Text(
                      'Tanggal Verifikasi: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalVerifikasi!)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Pelanggan ID: ${pembayaran.id}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  if (pembayaran.image.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.paddingMedium),
                    Image.network(
                      '${AppConstants.baseUrl}${pembayaran.image}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return const Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: AppColors.white),
                        );
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: AppSizes.paddingMedium),
                    const Text(
                      'Gambar tidak tersedia',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}