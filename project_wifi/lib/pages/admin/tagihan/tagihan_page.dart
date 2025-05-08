// lib/pages/tagihan_page.dart
import 'package:flutter/material.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({Key? key}) : super(key: key);

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  late Future<List<Tagihan>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = fetchTagihans();

  void _showDetail(Tagihan t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelanggan: ${t.pelangganName}', style: Theme.of(context).textTheme.titleLarge),
            Text('Periode: ${t.bulanTahun}'),
            Text('Status: ${t.statusPembayaran}'),
            Text('Jatuh Tempo: ${t.jatuhTempo.toLocal().toString().split(' ')[0]}'),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/edit_tagihan', arguments: t)
                        .then((_) => setState(_load));
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(t.id);
                  },
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tagihan'),
        content: const Text('Yakin ingin menghapus tagihan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteTagihan(id);
              setState(_load);
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
      body: FutureBuilder<List<Tagihan>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('${t.bulanTahun} - ${t.pelangganName}'),
                  subtitle: Text('Status: ${t.statusPembayaran}'),
                  onTap: () => _showDetail(t),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        onPressed: () => Navigator.pushNamed(context, '/add_tagihan').then((_) => setState(_load)),
        child: const Icon(Icons.add),
      ),
    );
  }
}