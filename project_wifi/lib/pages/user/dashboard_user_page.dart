// lib/pages/dashboard_user_page.dart

import 'package:flutter/material.dart';
import '../../models/dashboard_user.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({Key? key}) : super(key: key);

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  late Future<DashboardUser> _future;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DashboardUser> _load() async {
    final pidStr = await _storage.read(key: 'pelanggan_id');
    final pid = int.tryParse(pidStr ?? '');
    if (pid == null) throw Exception('No pelanggan_id stored');
    return DashboardUserService.fetchDashboardUser(pid);
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Saya'),
        backgroundColor: Utils.mainThemeColor,
        centerTitle: true,
      ),
      body: FutureBuilder<DashboardUser>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final data = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Selamat datang!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCard(
                      'Total Tagihan',
                      data.totalTagihan.toString(),
                      Icons.receipt_long,
                      Utils.mainThemeColor,
                    ),
                    _buildCard(
                      'Lunas',
                      data.tagihanLunas.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildCard(
                      'Belum Bayar',
                      data.tagihanPending.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                    _buildCard(
                      'Paket Aktif',
                      data.paketAktif ?? '-',
                      Icons.wifi,
                      Utils.mainThemeColor,
                    ),
                    _buildCard(
                      'Status Akun',
                      data.statusAkun,
                      Icons.person,
                      Utils.mainThemeColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (data.tanggalAktif != null && data.tanggalLangganan != null)
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Tanggal Aktif'),
                        subtitle: Text(
                          data.tanggalAktif!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Langganan Sejak'),
                        subtitle: Text(
                          data.tanggalLangganan!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
