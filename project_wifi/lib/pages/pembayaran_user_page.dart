import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/pembayaran.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class PembayaranUserPage extends StatefulWidget {
  const PembayaranUserPage({Key? key}) : super(key: key);
  @override State<PembayaranUserPage> createState() => _PembayaranUserPageState();
}

class _PembayaranUserPageState extends State<PembayaranUserPage> {
  final _storage = const FlutterSecureStorage();
  late Future<List<Pembayaran>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _storage.read(key: 'pelanggan_id').then((s) {
      final pid = int.tryParse(s ?? '');
      if (pid == null) return <Pembayaran>[];
      return PembayaranService.fetchPembayaransByPelanggan(pid);
    });
  }

  void _showDetail(Pembayaran p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Periode: ${p.bulanTahun}', style: Theme.of(context).textTheme.titleLarge),
          Text('Harga: Rp ${p.harga}'),
          Text('Status: ${p.statusVerifikasi}'),
          Text('Dikirim: ${p.tanggalKirim.toLocal().toIso8601String().split("T")[0]}'),
          if (p.tanggalVerifikasi != null)
            Text('Verifikasi: ${p.tanggalVerifikasi!.toLocal().toIso8601String().split("T")[0]}'),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Pembayaran Saya'), backgroundColor: Utils.mainThemeColor),
    body: FutureBuilder<List<Pembayaran>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child:CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final list = snap.data!;
        if (list.isEmpty) return const Center(child: Text('Belum ada pembayaran'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom:12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(p.bulanTahun),
                subtitle: Text('Rp ${p.harga} • ${p.statusVerifikasi}'),
                onTap: ()=>_showDetail(p),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Utils.mainThemeColor,
      onPressed: ()=>Navigator.pushNamed(context,'/add_pembayaran_user').then((_)=>setState(_load)),
      child: const Icon(Icons.add),
    ),
  );
}
