// lib/pages/paket_page.dart
import 'package:flutter/material.dart';
import '../models/paket.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import 'add_paket_page.dart';
import 'edit_paket_page.dart';

class PaketPage extends StatefulWidget {
  @override
  _PaketPageState createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  late Future<List<Paket>> _futurePaket;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futurePaket = fetchData('paket').then(
          (list) => list.map((e) => Paket.fromJson(e)).toList(),
    );
  }

  void _showDetail(Paket p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p.namaPaket),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deskripsi: ${p.deskripsi}'),
            Text('Harga: ${p.harga}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditPaketPage(paket: p)),
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
                  content: const Text('Hapus paket ini?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal')
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await deletePaket(p.id!);
                        setState(_load);
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
      body: FutureBuilder<List<Paket>>(
        future: _futurePaket,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(child: Text('Error: ${s.error}'));
          }
          final list = s.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width ~/ 200).clamp(2, 4),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final p = list[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => _showDetail(p),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi, size: 36, color: Utils.mainThemeColor),
                        const SizedBox(height: 12),
                        Text(p.namaPaket, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rp${p.harga}'),
                      ],
                    ),
                  ),
                ),
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
            MaterialPageRoute(builder: (_) => AddPaketPage()),
          ).then((_) => setState(_load));
        },
      )
    );
  }
}
