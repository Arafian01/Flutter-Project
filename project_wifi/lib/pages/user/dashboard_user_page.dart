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

class _DashboardUserPageState extends State<DashboardUserPage> {
  late Future<DashboardUser> _future;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
                child: Icon(icon, size: 24, color: AppColors.primaryBlue),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                    SizedBox(height: 4),
                    Text(title, style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, color: AppColors.textSecondaryBlue, size: 16),
            ],
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
        title: Text('Dashboard', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: FutureBuilder<DashboardUser>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Gagal memuat: ${snap.error}', style: TextStyle(fontSize: 14)));
                }
                final data = snap.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Total Tagihan',
                      value: data.totalTagihan.toString(),
                      icon: Icons.receipt_long,
                      onTap: () => Navigator.pushNamed(context, '/tagihan'),
                    ),
                    _buildCard(
                      title: 'Lunas',
                      value: data.tagihanLunas.toString(),
                      icon: Icons.check_circle,
                      onTap: () => Navigator.pushNamed(context, '/tagihan', arguments: 'lunas'),
                    ),
                    _buildCard(
                      title: 'Belum Bayar',
                      value: data.tagihanPending.toString(),
                      icon: Icons.pending,
                      onTap: () => Navigator.pushNamed(context, '/tagihan', arguments: 'pending'),
                    ),
                    _buildCard(
                      title: 'Paket Aktif',
                      value: data.paketAktif ?? '-',
                      icon: Icons.wifi,
                    ),
                    _buildCard(
                      title: 'Status Akun',
                      value: data.statusAkun,
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    if (data.tanggalAktif != null && data.tanggalLangganan != null)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 24),
                              title: Text('Tanggal Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              subtitle: Text(data.tanggalAktif!.toLocal().toString().split(' ')[0], style: TextStyle(fontSize: 14)),
                            ),
                            Divider(height: 1, color: AppColors.textSecondaryBlue),
                            ListTile(
                              leading: Icon(Icons.event, color: AppColors.primaryBlue, size: 24),
                              title: Text('Langganan Sejak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              subtitle: Text(data.tanggalLangganan!.toLocal().toString().split(' ')[0], style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}