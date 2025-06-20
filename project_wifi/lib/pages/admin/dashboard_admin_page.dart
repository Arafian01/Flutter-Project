import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  late Future<Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _future = fetchDashboard();
    });
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 300),
      child: FadeInAnimation(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: AppSizes.iconSizeMedium,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.accentRed,
                      size: AppSizes.iconSizeSmall,
                    ),
                ],
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
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: AppSizes.iconSizeMedium),
            onPressed: _loadDashboard,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentRed,
        backgroundColor: AppColors.white,
        onRefresh: () async {
          _loadDashboard();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: FutureBuilder<Dashboard>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                  ),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gagal memuat data: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              final data = snap.data!;
              return AnimationLimiter(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 300),
                    childAnimationBuilder: (widget) => FadeInAnimation(child: widget),
                    children: [
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildCard(
                        title: 'Total Pelanggan',
                        value: data.totalPelanggan.toString(),
                        icon: Icons.people,
                        onTap: () => Navigator.pushNamed(context, '/pelanggan'),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildCard(
                        title: 'Total Paket',
                        value: data.totalPaket.toString(),
                        icon: Icons.wifi,
                        onTap: () => Navigator.pushNamed(context, '/paket'),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildCard(
                        title: 'Total Tagihan Lunas',
                        value: data.tagihanLunas.toString(),
                        icon: Icons.receipt_long,
                        onTap: () => Navigator.pushNamed(context, '/tagihan'),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildCard(
                        title: 'Total Pendapatan',
                        value: _formatRupiah(data.totalHargaLunas),
                        icon: Icons.monetization_on,
                        onTap: () => Navigator.pushNamed(context, '/report'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}