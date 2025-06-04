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

class _DashboardAdminPageState extends State<DashboardAdminPage>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryBlue,
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
        title: const Text('Dashboard'),
    foregroundColor: AppColors.white,
    centerTitle: true,
    ),
    body: Padding(
    padding: const EdgeInsets.all(AppSizes.paddingLarge),
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
    return Center(child: Text('Error: ${snap.error}'));
    }
    final data = snap.data!;
    return SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    ),
    child: Padding(
    padding: const EdgeInsets.all(AppSizes.paddingMedium),
    child: Row(
    children: [
    const Icon(
    Icons.wifi,
    size: AppSizes.iconSizeMedium,
    color: AppColors.primaryBlue,
    ),
    const SizedBox(width: AppSizes.paddingSmall),
    Text(
    'Ringkasan Admin',
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    color: AppColors.primaryBlue,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: AppSizes.paddingMedium),
    GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: isSmallScreen ? 1 : 2,
    crossAxisSpacing: AppSizes.paddingMedium,
    mainAxisSpacing: AppSizes.paddingMedium,
    childAspectRatio: isSmallScreen ? 3.5 : 2,
    ),
    children: [
    _buildCard(
    title: 'Total Pelanggan',
    value: data.totalPelanggan.toString(),
    icon: Icons.people,
    onTap: () => Navigator.pushNamed(context, '/pelanggan'),
    ),
    _buildCard(
    title: 'Total Paket',
    value: data.totalPaket.toString(),
    icon: Icons.wifi,
    onTap: () => Navigator.pushNamed(context, '/paket'),
    ),
    _buildCard(
    title: 'Total Tagihan Lunas',
    value: data.tagihanLunas.toString(),
    icon: Icons.receipt_long,
    onTap: () => Navigator.pushNamed(context, '/tagihan'),
    ),
    _buildCard(
    title: 'Total Pendapatan',
    value: _formatRupiah(data.totalHargaLunas),
    icon: Icons.monetization_on,
    onTap: () => Navigator.pushNamed(context, '/report'),
    ),
    ],
    ),
    ],
    ),
    );
    },
    ),
    ));
  }
}