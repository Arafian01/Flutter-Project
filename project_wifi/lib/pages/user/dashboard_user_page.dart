import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dashboard_user.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({Key? key}) : super(key: key);

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  late Future<DashboardUser> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
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

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Dashboard Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryRed, AppColors.secondaryRed],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.wifi,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<DashboardUser>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Error: ${snap.error}'),
                    ),
                  );
                }
                final data = snap.data!;
                return AnimationLimiter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Selamat datang!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          AnimationConfiguration.staggeredGrid(
                            position: 0,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 500),
                            child: _buildCard(
                              title: 'Total Tagihan',
                              value: data.totalTagihan.toString(),
                              icon: Icons.receipt_long,
                              color: AppColors.primaryRed,
                              animation: CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          AnimationConfiguration.staggeredGrid(
                            position: 1,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 500),
                            child: _buildCard(
                              title: 'Lunas',
                              value: data.tagihanLunas.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                              animation: CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          AnimationConfiguration.staggeredGrid(
                            position: 2,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 500),
                            child: _buildCard(
                              title: 'Belum Bayar',
                              value: data.tagihanPending.toString(),
                              icon: Icons.pending,
                              color: Colors.orange,
                              animation: CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          AnimationConfiguration.staggeredGrid(
                            position: 3,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 500),
                            child: _buildCard(
                              title: 'Paket Aktif',
                              value: data.paketAktif ?? '-',
                              icon: Icons.wifi,
                              color: AppColors.primaryRed,
                              animation: CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          AnimationConfiguration.staggeredGrid(
                            position: 4,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 500),
                            child: _buildCard(
                              title: 'Status Akun',
                              value: data.statusAkun,
                              icon: Icons.person,
                              color: AppColors.primaryRed,
                              animation: CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (data.tanggalAktif != null && data.tanggalLangganan != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
                                title: const Text('Tanggal Aktif'),
                                subtitle: Text(
                                  data.tanggalAktif!.toLocal().toString().split(' ')[0],
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.event, color: AppColors.primaryRed),
                                title: const Text('Langganan Sejak'),
                                subtitle: Text(
                                  data.tanggalLangganan!.toLocal().toString().split(' ')[0],
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}