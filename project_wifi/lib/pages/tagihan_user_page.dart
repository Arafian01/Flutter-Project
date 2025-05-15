// lib/pages/tagihan_user_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tagihan.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class TagihanUserPage extends StatefulWidget {
  const TagihanUserPage({Key? key}) : super(key: key);

  @override
  State<TagihanUserPage> createState() => _TagihanUserPageState();
}

class _TagihanUserPageState extends State<TagihanUserPage> {
  final _storage = const FlutterSecureStorage();
  late final Future<List<Tagihan>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTagihan();
  }

  Future<List<Tagihan>> _loadTagihan() async {
    final pidStr = await _storage.read(key: 'pelanggan_id');
    final pid = int.tryParse(pidStr ?? '');
    if (pid == null) return [];
    return TagihanService.fetchTagihansByPelanggan(pid);
  }

  void _showDetail(Tagihan t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Periode: ${t.bulanTahun}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Status: ${t.statusPembayaran}'),
          const SizedBox(height: 8),
          Text('Jatuh Tempo: ${t.jatuhTempo.toLocal().toIso8601String().split('T').first}'),
          const SizedBox(height: 8),
          Text('Harga: Rp ${t.harga}'),
          const SizedBox(height: 16),
          if (t.statusPembayaran == 'belum_dibayar')
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/add_pembayaran_user',
                    arguments: {
                      'tagihanId': t.id,
                      'bulanTahun': t.bulanTahun,
                    },
                  ).then((_) => setState(() => _future = _loadTagihan()));
                },
                child: const Text('Bayar Tagihan'),
                style: ElevatedButton.styleFrom(backgroundColor: Utils.mainThemeColor),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: FutureBuilder<List<Tagihan>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada tagihan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(t.bulanTahun),
                  subtitle: Text('Rp ${t.harga} • ${t.statusPembayaran}'),
                  onTap: () => _showDetail(t),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
