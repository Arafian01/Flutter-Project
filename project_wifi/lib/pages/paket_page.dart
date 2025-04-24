import 'package:flutter/material.dart';
import '../services/api_service.dart';  // Mengimpor api_service.dart
import '../models/paket.dart';  // Mengimpor model Paket

class PaketPage extends StatefulWidget {
  @override
  _PaketPageState createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  late Future<List<Paket>> _futurePaket;

  @override
  void initState() {
    super.initState();
    _futurePaket = fetchPaket();  // Memanggil fetchPaket yang akan menggunakan fetchData
  }

  // Fungsi untuk mengambil data Paket dari API
  Future<List<Paket>> fetchPaket() async {
    final data = await fetchData('paket');  // Memanggil api_service dengan endpoint 'paket'
    return data.map((item) => Paket.fromRow(item)).toList();
  }

  void _showDetailModal(BuildContext context, Paket paket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(paket.namaPaket),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deskripsi: ${paket.deskripsi}"),
            Text("Harga: ${paket.harga}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Tambahkan navigasi ke halaman edit jika perlu
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Tambahkan aksi hapus jika perlu
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paket'),
        backgroundColor: Colors.red,  // Ganti dengan warna tema yang sesuai
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Tambahkan aksi ke halaman profil atau logout
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Paket>>(
        future: _futurePaket,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final paketList = snapshot.data ?? [];
          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (context, index) {
              final paket = paketList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(paket.namaPaket),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Deskripsi: ${paket.deskripsi}"),
                      Text("Harga: ${paket.harga}"),
                    ],
                  ),
                  onTap: () => _showDetailModal(context, paket),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
