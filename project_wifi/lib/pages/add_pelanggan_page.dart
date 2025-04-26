import 'package:flutter/material.dart';
import '../models/paket.dart';
import '../services/api_service.dart';

class AddPelangganPage extends StatefulWidget {
  @override
  _AddPelangganPageState createState() => _AddPelangganPageState();
}

class _AddPelangganPageState extends State<AddPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _statusController = TextEditingController();

  List<Paket> _pakets = [];
  int? _selectedPaketId;

  @override
  void initState() {
    super.initState();
    _loadPakets();
  }

  Future<void> _loadPakets() async {
    try {
      final pakets = await fetchPakets();
      setState(() {
        _pakets = pakets;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil data paket: $e")),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final pelangganData = {
        'name': _namaController.text,
        'email': _emailController.text,
        'alamat': _alamatController.text,
        'telepon': _teleponController.text,
        'paket_id': _selectedPaketId,
        'status': 'aktif', // bisa ubah sesuai kebutuhan
        'tanggal_aktif': DateTime.now().toIso8601String(),
        'tanggal_langganan': DateTime.now().toIso8601String(),
      };

      try {
        await createPelanggan(pelangganData);
        Navigator.pop(context); // kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan berhasil ditambahkan!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan pelanggan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pelanggan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'Telepon'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Telepon wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedPaketId,
                decoration: const InputDecoration(labelText: 'Pilih Paket'),
                items: _pakets.map((paket) {
                  return DropdownMenuItem<int>(
                    value: paket.id,
                    child: Text(paket.namaPaket),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaketId = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Paket wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedPaketId != null)
                ..._pakets
                    .where((p) => p.id == _selectedPaketId)
                    .map((p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Harga: Rp ${p.harga}"),
                    Text("Deskripsi: ${p.deskripsi}"),
                  ],
                )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
