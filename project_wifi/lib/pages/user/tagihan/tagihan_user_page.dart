import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/tagihan.dart';
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

class TagihanUserPage extends StatefulWidget {
  const TagihanUserPage({Key? key}) : super(key: key);

  @override
  State<TagihanUserPage> createState() => _TagihanUserPageState();
}

class _TagihanUserPageState extends State<TagihanUserPage> with SingleTickerProviderStateMixin {
  late Future<List<Tagihan>> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadTagihan();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Widget _buildTagihanCard(Tagihan t, int index) {
    IconData statusIcon;
    Color statusColor;
    String statusText;
    bool canPay;

    switch (t.statusPembayaran) {
      case 'belum_dibayar':
        statusIcon = Icons.warning;
        statusColor = Colors.orange;
        statusText = 'Belum Dibayar';
        canPay = true;
        break;
      case 'menunggu_verifikasi':
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.blue;
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
        statusColor = Colors.grey;
        statusText = 'Tidak Diketahui';
        canPay = false;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.white.withOpacity(0.2),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: AppSizes.iconSizeMedium,
              ),
            ),
            title: Text(
              formatBulanTahunFromInt(t.bulan, t.tahun), // Updated
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${t.harga}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: canPay
                  ? () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/add_pembayaran_user',
                  arguments: t,
                );
                if (result == true) {
                  _loadTagihan();
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              child: const Text('Bayar'),
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
        backgroundColor: AppColors.primaryRed,
        title: const Text('Manajemen Tagihan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: const Icon(
          Icons.receipt_long,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.white,
              size: AppSizes.iconSizeMedium,
            ),
            onPressed: _loadTagihan,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingMedium,
                horizontal: AppSizes.paddingLarge,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.secondaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: AppSizes.iconSizeMedium,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    'Ringkasan Tagihan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: FutureBuilder<List<Tagihan>>(
                future: _future,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat tagihan: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada tagihan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _buildTagihanCard(list[i], i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}