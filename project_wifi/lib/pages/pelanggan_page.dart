import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pelanggan.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  late Future<List<Pelanggan>> _futurePelanggan;

  @override
  void initState() {
    super.initState();
    _futurePelanggan = fetchPelanggan();
  }

  Future<List<Pelanggan>> fetchPelanggan() async {
    final data = await fetchData('pelanggan');
    return data.map((item) => Pelanggan.fromRow(item)).toList();
  }

  void _showDetailModal(BuildContext context, Pelanggan pelanggan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(pelanggan.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${pelanggan.email}"),
            Text("Paket: ${pelanggan.paket}"),
            Text("Status: ${pelanggan.status}"),
            Text("Alamat: ${pelanggan.alamat}"),
            Text("Telepon: ${pelanggan.telepon}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Pelanggan>>(
        future: _futurePelanggan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pelangganList = snapshot.data ?? [];
          return ListView.builder(
            itemCount: pelangganList.length,
            itemBuilder: (context, index) {
              final pelanggan = pelangganList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(pelanggan.name),
                  subtitle: Text("Paket: ${pelanggan.paket}"),
                  onTap: () => _showDetailModal(context, pelanggan),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
