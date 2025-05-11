// lib/pages/pembayaran_page.dart
import 'package:flutter/material.dart';
import '../../../models/pembayaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({Key? key}) : super(key: key);
  @override State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  late Future<List<Pembayaran>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = PembayaranService.fetchPembayarans();

  void _showDetail(Pembayaran p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Periode: ${p.bulanTahun}', style: Theme.of(context).textTheme.titleLarge),
            Text('Pelanggan: ${p.pelangganName}'),
            Text('Harga: Rp ${p.harga}'),
            Text('Status: ${p.statusVerifikasi}'),
            Text('Dikirim: ${p.tanggalKirim.toLocal().toIso8601String().split("T")[0]}'),
            if (p.tanggalVerifikasi != null)
              Text('Verifikasi: ${p.tanggalVerifikasi!.toLocal().toIso8601String().split("T")[0]}'),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/edit_pembayaran', arguments: p)
                        .then((_) => setState(_load));
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    PembayaranService.deletePembayaran(p.id)
                        .then((_) => setState(_load));
                  },
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Manajemen Pembayaran'), backgroundColor: Utils.mainThemeColor),
    body: FutureBuilder<List<Pembayaran>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final list = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(p.bulanTahun),
                subtitle: Text('Rp ${p.harga} • ${p.statusVerifikasi}'),
                onTap: () => _showDetail(p),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Utils.mainThemeColor,
      child: const Icon(Icons.add),
      onPressed: () => Navigator.pushNamed(context, '/add_pembayaran').then((_) => setState(_load)),
    ),
  );
}
