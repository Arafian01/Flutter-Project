import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dashboard_user.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> with SingleTickerProviderStateMixin {
  late Future<DashboardUser> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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

  void _loadDashboard() {
    setState(() {
      _future = _load();
    });
  }

  Future<DashboardUser> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final pelangganData = prefs.getString('pelanggan_data');
    if (pelangganData == null) throw Exception('No pelanggan data stored');
    final data = jsonDecode(pelangganData) as Map<String, dynamic>;
    final pid = data['pelanggan_id'] as int?;
    if (pid == null) throw Exception('No pelanggan_id stored');
    return DashboardUserService.fetchDashboardUser(pid);
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
            const Icon(Icons.logout, color: AppColors.accentRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    required Animation<double> fadeAnimation,
    required Animation<double> scaleAnimation,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondaryBlue.withOpacity(0.2),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
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
                      color: AppColors.textSecondaryBlue,
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
        leading: const Icon(
          Icons.wifi,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
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
                    Icon(Icons.logout, color: AppColors.accentRed),
                    SizedBox(width: AppSizes.paddingSmall),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            color: AppColors.white,
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
            onPressed: _loadDashboard,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: FutureBuilder<DashboardUser>(
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
                child: Text(
                  'Gagal memuat dashboard: ${snap.error}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryBlue,
                  ),
                ),
              );
            }
            final data = snap.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 1 : 2,
                      crossAxisSpacing: AppSizes.paddingMedium,
                      mainAxisSpacing: AppSizes.paddingMedium,
                      childAspectRatio: isSmallScreen ? 3 / 1 : 4 / 3,
                    ),
                    children: [
                      _buildCard(
                        title: 'Total Tagihan',
                        value: data.totalTagihan.toString(),
                        icon: Icons.receipt_long,
                        onTap: () => Navigator.pushNamed(context, '/tagihan'),
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      _buildCard(
                        title: 'Lunas',
                        value: data.tagihanLunas.toString(),
                        icon: Icons.check_circle,
                        onTap: () => Navigator.pushNamed(context, '/tagihan', arguments: 'lunas'),
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      _buildCard(
                        title: 'Belum Bayar',
                        value: data.tagihanPending.toString(),
                        icon: Icons.pending,
                        onTap: () => Navigator.pushNamed(context, '/tagihan', arguments: 'pending'),
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      _buildCard(
                        title: 'Paket Aktif',
                        value: data.paketAktif ?? '-',
                        icon: Icons.wifi,
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      _buildCard(
                        title: 'Status Akun',
                        value: data.statusAkun,
                        icon: Icons.person,
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  if (data.tanggalAktif != null && data.tanggalLangganan != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                      color: AppColors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryBlue,
                              size: AppSizes.iconSizeMedium,
                            ),
                            title: Text(
                              'Tanggal Aktif',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data.tanggalAktif!.toLocal().toString().split(' ')[0],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryBlue,
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.textSecondaryBlue),
                          ListTile(
                            leading: const Icon(
                              Icons.event,
                              color: AppColors.primaryBlue,
                              size: AppSizes.iconSizeMedium,
                            ),
                            title: Text(
                              'Langganan Sejak',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data.tanggalLangganan!.toLocal().toString().split(' ')[0],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}