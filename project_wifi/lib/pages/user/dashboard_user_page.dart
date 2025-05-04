import 'package:flutter/material.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Selamat datang, User!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Summary cards in grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SummaryCard(
                  title: 'Tagihan Aktif',
                  value: 'Rp 150.000',
                  icon: Icons.receipt_long,
                ),
                _SummaryCard(
                  title: 'Pembayaran Terakhir',
                  value: 'Rp 100.000',
                  icon: Icons.payment,
                ),
                _SummaryCard(
                  title: 'Paket Aktif',
                  value: 'Premium 50 Mbps',
                  icon: Icons.wifi,
                ),
                _SummaryCard(
                  title: 'Status Akun',
                  value: 'Aktif',
                  icon: Icons.person,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent invoices list
            Text(
              'Tagihan Terbaru',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(3, (index) {
                // Dummy data for list
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.receipt),
                    title: Text('Tagihan Bulan ${['Januari','Februari','Maret'][index]}'),
                    subtitle: Text('Rp ${(index + 1) * 50}.000'),
                    trailing: Text(
                      ['Lunas', 'Belum Bayar', 'Lunas'][index],
                      style: TextStyle(
                        color: [Colors.green, Colors.red, Colors.green][index],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Navigate to detail
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Action button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Go to payments page
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Lihat Semua Tagihan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable summary card widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}