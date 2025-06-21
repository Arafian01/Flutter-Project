import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/pembayaran.dart';
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

class PembayaranUserPage extends StatefulWidget {
  const PembayaranUserPage({super.key});

  @override
  State<PembayaranUserPage> createState() => _PembayaranUserPageState();
}

class _PembayaranUserPageState extends State<PembayaranUserPage> {
  late Future<List<Pembayaran>> _future;

  @override
  void initState() {
    super.initState();
    _loadPembayaran();
  }

  void _loadPembayaran() {
    setState(() {
      _future = _fetchPembayaran();
    });
  }

  Future<List<Pembayaran>> _fetchPembayaran() async {
    final prefs = await SharedPreferences.getInstance();
    final pelangganData = prefs.getString('pelanggan_data');
    if (pelangganData == null) return [];
    final data = jsonDecode(pelangganData) as Map<String, dynamic>;
    final pid = data['pelanggan_id'] as int?;
    if (pid == null) return [];
    return await PembayaranService.fetchPembayaransByPelanggan(pid);
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

  Widget _buildPembayaranCard(Pembayaran p, int index) {
    IconData statusIcon;
    Color statusColor;
    switch (p.statusVerifikasi) {
      case 'menunggu_verifikasi':
        statusIcon = Icons.hourglass_empty;
        statusColor = AppColors.secondaryBlue;
        break;
      case 'diterima':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'ditolak':
        statusIcon = Icons.error;
        statusColor = AppColors.accentRed;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = AppColors.textSecondaryBlue;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/detail_pembayaran', arguments: p),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          title: Text(
            formatBulanTahunFromInt(p.bulan, p.tahun),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
          ),
          subtitle: Text(
            'Rp ${p.harga} • ${p.statusVerifikasi.replaceAll('_', ' ').toUpperCase()}',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondaryBlue, size: 16),
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
        title: Text('Daftar Pembayaran', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        leading: Icon(Icons.payment, color: AppColors.white, size: 24),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.white, size: 24),
            onPressed: _loadPembayaran,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: FutureBuilder<List>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Gagal memuat: ${snap.error}', style: TextStyle(fontSize: 14)));
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return Center(child: Text('Belum ada pembayaran.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _buildPembayaranCard(list[i], i),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}