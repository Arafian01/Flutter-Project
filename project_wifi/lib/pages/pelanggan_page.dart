import 'package:flutter/material.dart';
import '../models/pelanggan.dart';
import '../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Pelanggan')),
      body: FutureBuilder<List<Pelanggan>>(
        future: _futurePelanggan,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final pelanggan = snapshot.data!;
            return ListView.builder(
              itemCount: pelanggan.length,
              itemBuilder: (context, index) {
                final p = pelanggan[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.email} | ${p.paket}'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
