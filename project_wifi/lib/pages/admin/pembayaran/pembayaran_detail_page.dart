import 'package:flutter/material.dart';
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

class _PembayaranDetailPageState extends State<PembayaranDetailPage> {
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  String _formatBulanTahun(int month, int year) {
    try {
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '$month-$year';
    }
  }

  String _formatStatus(String status) => status.replaceAll('_', ' ').toUpperCase();

  void _showDeleteDialog(Pembayaran pembayaran) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.accentRed, size: 24),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Hapus pembayaran untuk ${pembayaran.pelangganName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PembayaranService.deletePembayaran(pembayaran.id);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('success_message', 'Pembayaran berhasil dihapus');
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.accentRed),
                );
              }
            },
            child: Text('Hapus', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null ? child : CircularProgressIndicator(),
            errorBuilder: (context, error, stackTrace) => Text('Gagal memuat gambar'),
          ),
        ),
      ),
    );
  }

  Widget _buildPembayaranCard(Pembayaran pembayaran) {
    final imageUrl = pembayaran.image.isNotEmpty ? '${AppConstants.baseUrl}${pembayaran.image}' : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
                  child: Icon(
                    Icons.payment,
                    size: 24,
                    color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pembayaran.pelangganName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                      ),
                      SizedBox(height: 4),
                      Text(_formatBulanTahun(pembayaran.bulan, pembayaran.tahun), style: TextStyle(fontSize: 14)),
                      SizedBox(height: 4),
                      Text(_formatter.format(pembayaran.harga), style: TextStyle(fontSize: 14)),
                      SizedBox(height: 4),
                      Text(
                        _formatStatus(pembayaran.statusVerifikasi),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Detail Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Row(children: [
              Text('Tagihan ID: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(pembayaran.tagihanId.toString()),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Text('Tanggal Kirim: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(_dateFormatter.format(pembayaran.tanggalKirim.toLocal())),
            ]),
            if (pembayaran.tanggalVerifikasi != null) ...[
              SizedBox(height: 8),
              Row(children: [
                Text('Tanggal Verifikasi: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(_dateFormatter.format(pembayaran.tanggalVerifikasi!.toLocal())),
              ]),
            ],
            SizedBox(height: 16),
            Text('Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            imageUrl != null
                ? GestureDetector(
              onTap: () => _showImagePreview(imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null ? child : CircularProgressIndicator(),
                  errorBuilder: (context, error, stackTrace) => Text('Gagal memuat gambar'),
                ),
              ),
            )
                : Text('Gambar tidak tersedia'),
          ],
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
        title: Text('Detail Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPembayaranCard(widget.pembayaran),
              SizedBox(height: 16),
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
                    icon: Icon(Icons.edit, size: 20),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(widget.pembayaran),
                    icon: Icon(Icons.delete, size: 20),
                    label: Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}