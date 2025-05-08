// lib/pages/pelanggan_page.dart
import 'package:flutter/material.dart';
import '../../../models/pelanggan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  late Future<List<Pelanggan>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = fetchPelanggans();

  void _showDetail(Pelanggan p) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: Theme.of(context).textTheme.titleLarge),
            Text(p.email),
            Text('Paket: ${p.namaPaket}'),
            Text('Status: ${p.status}'),
            Text('Alamat: ${p.alamat}'),
            Text('Telepon: ${p.telepon}'),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/edit_pelanggan', arguments: p).then((r) => setState(_load));
                  },
                  child: Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(p.id);
                  },
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Pelanggan'),
        content: Text('Yakin ingin hapus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deletePelanggan(id);
              setState(_load);
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Pelanggan>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return
            Center(child: CircularProgressIndicator()
            );
          if (snap.hasError)
            return Center(

                child: Text('Error: ${snap.error}')
            );
          final list = snap.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final p = list[i];
              return Card(
                margin: EdgeInsets.only(bottom:12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.email} • ${p.namaPaket}'),
                  onTap: () => _showDetail(p),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        onPressed: () => Navigator.pushNamed(context, '/add_pelanggan').then((r) => setState(_load)),
        child: Icon(Icons.add),
      ),
    );
  }
}
