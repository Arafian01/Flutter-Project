import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> with SingleTickerProviderStateMixin {
  late Future<Dashboard> _futureDashboard;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _futureDashboard = fetchDashboard();
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: FutureBuilder<Dashboard>(
                future: _futureDashboard,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan pada server',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 1 : 2,
                      crossAxisSpacing: AppSizes.paddingMedium,
                      mainAxisSpacing: AppSizes.paddingMedium,
                      childAspectRatio: isSmallScreen ? 3 / 1 : 4 / 3,
                    ),
                    children: [
                      _buildCard(
                        'Total Pelanggan',
                        data.totalPelanggan.toString(),
                        Icons.people,
                      ),
                      _buildCard(
                        'Total Paket',
                        data.totalPaket.toString(),
                        Icons.wifi,
                      ),
                      _buildCard(
                        'Tagihan Lunas',
                        data.tagihanLunas.toString(),
                        Icons.check_circle,
                      ),
                      _buildCard(
                        'Belum Lunas',
                        data.tagihanPending.toString(),
                        Icons.pending,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            Icons.wifi,
            size: AppSizes.iconSizeMedium,
            color: AppColors.white,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            'Admin Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () {}, // Bisa ditambahkan aksi di masa depan
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    child: Icon(
                      icon,
                      size: AppSizes.iconSizeMedium,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}