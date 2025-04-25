import 'package:flutter/material.dart';
import '../models/pelanggan.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import 'add_pelanggan_page.dart';
import 'edit_pelanggan_page.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  late Future<List<Pelanggan>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = fetchData('pelanggan')
        .then((list) => list.map((j) => Pelanggan.fromJson(j)).toList());
  }

  void _showDetail(Pelanggan p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${p.email}'),
            Text('Paket ID: ${p.paketId}'),
            Text('Status: ${p.status}'),
            Text('Alamat: ${p.alamat}'),
            Text('Telepon: ${p.telepon}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPelangganPage(pelanggan: p),
                ),
              ).then((_) => setState(_load));
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Hapus pelanggan ini?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await deletePelanggan(p.id!);
                        setState(_load);
                      },
                      child:
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final p = list[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('Paket ID: ${p.paketId}'),
                onTap: () => _showDetail(p),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPelangganPage()),
          ).then((_) => setState(_load));
        },
      ),
    );
  }
}
