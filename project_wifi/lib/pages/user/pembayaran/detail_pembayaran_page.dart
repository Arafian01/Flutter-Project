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

  void _showErrorDialog(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID');
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Detail Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode: ${formatBulanTahunFromInt(pembayaran.bulan, pembayaran.tahun)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Harga: ${_formatRupiah(pembayaran.harga)}',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${pembayaran.statusVerifikasi.replaceAll('_', ' ').toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: pembayaran.statusVerifikasi == 'diterima'
                            ? Colors.green
                            : pembayaran.statusVerifikasi == 'ditolak'
                            ? AppColors.accentRed
                            : AppColors.secondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tanggal Pengiriman: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalKirim)}',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                    ),
                    if (pembayaran.tanggalVerifikasi != null)
                      Text(
                        'Tanggal Verifikasi: ${DateFormat('dd MMMM yyyy', 'id_ID').format(pembayaran.tanggalVerifikasi!)}',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                      ),
                    SizedBox(height: 8),
                    Text(
                      'Pelanggan: ${pembayaran.pelangganName}',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bukti Pembayaran:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                    SizedBox(height: 8),
                    if (pembayaran.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${AppConstants.baseUrl}${pembayaran.image}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (ctx, error, stackTrace) => Text(
                            'Gagal memuat gambar',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Gambar tidak tersedia',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}