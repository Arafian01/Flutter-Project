import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({Key? key}) : super(key: key);

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  late Future<Dashboard> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _futureDashboard = fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Dashboard>(
        future: _futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan pada server'));
          }

          final data = snapshot.data!;
          return GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            children: [
              _buildCard('Total Pelanggan', data.totalPelanggan.toString(), Icons.people, Colors.blue),
              _buildCard('Total Paket', data.totalPaket.toString(), Icons.wifi, Colors.green),
              _buildCard('Tagihan Lunas', data.tagihanLunas.toString(), Icons.check_circle, Colors.teal),
              _buildCard('Belum Lunas', data.tagihanPending.toString(), Icons.pending, Colors.orange),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
