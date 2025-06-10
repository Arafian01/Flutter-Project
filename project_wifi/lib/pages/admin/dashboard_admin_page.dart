import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> with SingleTickerProviderStateMixin {
  late Future<Dashboard> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadDashboard() {
    _future = fetchDashboard();
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 10,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.white,
                    AppColors.backgroundLight.withOpacity(0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.5)),
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
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Dashboard Admin',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: AppSizes.iconSizeMedium),
            onPressed: () {
              setState(() {
                _loadDashboard();
                _controller.reset();
                _controller.forward();
              });
            },
            tooltip: 'Refresh Data',
          ),
        ],
        elevation: 4,
      ),
      body: RefreshIndicator(
        color: AppColors.accentRed,
        backgroundColor: AppColors.white,
        onRefresh: () async {
          setState(() {
            _loadDashboard();
            _controller.reset();
            _controller.forward();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: FutureBuilder<Dashboard>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                    strokeWidth: 5,
                  ),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadDashboard();
                            _controller.reset();
                            _controller.forward();
                          });
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              final data = snap.data!;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    isSmallScreen
                        ? Column(
                      children: [
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
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Column(
                            children: [
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
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}