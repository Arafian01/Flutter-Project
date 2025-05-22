import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../models/pembayaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

String formatBulanTahun(String bulanTahun) {
  initializeDateFormatting('id_ID');
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

class PembayaranUserPage extends StatefulWidget {
  const PembayaranUserPage({Key? key}) : super(key: key);

  @override
  State<PembayaranUserPage> createState() => _PembayaranUserPageState();
}

class _PembayaranUserPageState extends State<PembayaranUserPage> with SingleTickerProviderStateMixin {
  late Future<List<Pembayaran>> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPembayaran();
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Logout', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildPembayaranCard(Pembayaran p, int index) {
    IconData statusIcon;
    switch (p.statusVerifikasi) {
      case 'menunggu_verifikasi':
        statusIcon = Icons.hourglass_empty;
        break;
      case 'diterima':
        statusIcon = Icons.check_circle;
        break;
      case 'ditolak':
        statusIcon = Icons.cancel;
        break;
      default:
        statusIcon = Icons.help;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/detail_pembayaran',
            arguments: p,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                  color: AppColors.white,
                  size: AppSizes.iconSizeMedium,
                ),
              ),
              title: Text(
                formatBulanTahun(p.bulanTahun),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              subtitle: Text(
                'Rp ${p.harga} • ${p.statusVerifikasi}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.white.withOpacity(0.7),
                size: AppSizes.iconSizeSmall,
              ),
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
        title: const Text('Manajemen Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: const Icon(
          Icons.payment,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.person,
              color: AppColors.white,
              size: AppSizes.iconSizeMedium,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.primaryRed),
                    SizedBox(width: AppSizes.paddingSmall),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            color: AppColors.backgroundLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.white,
              size: AppSizes.iconSizeMedium,
            ),
            onPressed: _loadPembayaran,
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
                    Icons.payment,
                    size: AppSizes.iconSizeMedium,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    'Ringkasan Pembayaran',
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
              child: FutureBuilder<List<Pembayaran>>(
                future: _future,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat pembayaran: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pembayaran',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _buildPembayaranCard(list[i], i),
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