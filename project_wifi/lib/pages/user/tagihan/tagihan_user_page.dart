import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../pembayaran/add_pembayaran_user_page.dart';

String formatBulanTahunFromInt(int bulan, int tahun) {
  initializeDateFormatting('id_ID');
  try {
    final date = DateTime(tahun, bulan);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  } catch (e) {
    return '$bulan-$tahun';
  }
}

class TagihanUserPage extends StatefulWidget {
  const TagihanUserPage({super.key});

  @override
  State<TagihanUserPage> createState() => _TagihanUserPageState();
}

class _TagihanUserPageState extends State<TagihanUserPage> {
  late Future<List<Tagihan>> _future;

  @override
  void initState() {
    super.initState();
    _loadTagihan();
  }

  void _loadTagihan() {
    setState(() {
      _future = _fetchTagihan();
    });
  }

  Future<List<Tagihan>> _fetchTagihan() async {
    final prefs = await SharedPreferences.getInstance();
    final pelangganData = prefs.getString('pelanggan_data');
    if (pelangganData == null) return [];
    final data = jsonDecode(pelangganData) as Map<String, dynamic>;
    final pid = data['pelanggan_id'] as int?;
    if (pid == null) return [];
    return await TagihanService.fetchTagihansByPelanggan(pid);
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

  Widget _buildTagihanCard(Tagihan t, int index) {
    IconData statusIcon;
    Color statusColor;
    String statusText;
    bool canPay;

    switch (t.statusPembayaran) {
      case 'belum_dibayar':
        statusIcon = Icons.warning;
        statusColor = AppColors.accentRed;
        statusText = 'Belum Dibayar';
        canPay = true;
        break;
      case 'menunggu_verifikasi':
        statusIcon = Icons.hourglass_empty;
        statusColor = AppColors.secondaryBlue;
        statusText = 'Menunggu Verifikasi';
        canPay = false;
        break;
      case 'lunas':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Lunas';
        canPay = false;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = AppColors.textSecondaryBlue;
        statusText = 'Tidak Diketahui';
        canPay = false;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          formatBulanTahunFromInt(t.bulan, t.tahun),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rp ${t.harga}', style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue)),
            Text(statusText, style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: canPay
              ? () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPembayaranUserPage(tagihan: t)),
            );
            if (result == true && mounted) _loadTagihan();
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text('Bayar', style: TextStyle(fontSize: 14)),
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
        title: Text('Daftar Tagihan', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        leading: Icon(Icons.receipt_long, color: AppColors.white, size: 24),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.white, size: 24),
            onPressed: _loadTagihan,
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
                  return Center(child: Text('Belum ada tagihan.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _buildTagihanCard(list[i], i),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}