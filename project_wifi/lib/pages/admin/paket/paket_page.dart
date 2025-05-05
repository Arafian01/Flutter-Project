// lib/pages/paket_page.dart
import 'package:flutter/material.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

class PaketPage extends StatefulWidget {
  const PaketPage({Key? key}) : super(key: key);

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  late Future<List<Paket>> _futurePakets;

  @override
  void initState() {
    super.initState();
    _loadPakets();
  }

  void _loadPakets() {
    _futurePakets = fetchPakets();
  }

  void _showDetailModal(Paket paket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(paket.namaPaket, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Rp ${paket.harga.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(paket.deskripsi),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/edit_paket', arguments: paket)
                          .then((refresh) {
                        if (refresh == true) setState(_loadPakets);
                      });
                    },
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(paket.id);
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus paket ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await deletePaket(id);
                setState(_loadPakets);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Paket>>(
        future: _futurePakets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pakets = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pakets.length,
            itemBuilder: (context, index) {
              final paket = pakets[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => _showDetailModal(paket),
                  title: Text(paket.namaPaket, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(paket.deskripsi, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text('Rp ${paket.harga.toStringAsFixed(0)}', style: TextStyle(color: Utils.mainThemeColor)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_paket');
          if (result == true) setState(_loadPakets);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
