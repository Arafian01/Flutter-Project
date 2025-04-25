import 'package:flutter/material.dart';
import '../utils/utils.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Contoh data statistik
    final stats = [
      {'label': 'Pelanggan', 'value': '120', 'icon': Icons.people},
      {'label': 'Paket Aktif', 'value': '8', 'icon': Icons.wifi},
      {'label': 'Tagihan Lunas', 'value': '95', 'icon': Icons.receipt_long},
      {'label': 'Pending Bayar', 'value': '5', 'icon': Icons.payment},
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Grid summary cards
            Expanded(
              child: GridView.builder(
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,            // 2 kolom :contentReference[oaicite:4]{index=4}
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final item = stats[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // aksi saat kartu diketuk :contentReference[oaicite:5]{index=5}
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item['icon'] as IconData,
                                size: 32, color: Utils.mainThemeColor),
                            const Spacer(),
                            Text(
                              item['value'] as String,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['label'] as String,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
