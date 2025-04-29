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
  final _passwordController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();

  List<Paket> _pakets = [];
  int? _selectedPaketId;
  String _selectedStatus = 'aktif'; // default status
  DateTime _tanggalAktif = DateTime.now();
  DateTime _tanggalLangganan = DateTime.now();

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
        'password': _passwordController.text,
        'paket_id': _selectedPaketId,
        'alamat': _alamatController.text,
        'telepon': _teleponController.text,
        'status': _selectedStatus,
        'tanggal_aktif': _tanggalAktif.toIso8601String(),
        'tanggal_langganan': _tanggalLangganan.toIso8601String(),
        'role': 'pelanggan', // otomatis set role pelanggan
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

  Future<void> _selectDate(BuildContext context, bool isAktif) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAktif ? _tanggalAktif : _tanggalLangganan,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isAktif) {
          _tanggalAktif = picked;
        } else {
          _tanggalLangganan = picked;
        }
      });
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Password wajib diisi' : null,
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
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['aktif', 'nonaktif', 'isolir'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Status wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Tanggal Aktif: ${_tanggalAktif.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text('Tanggal Langganan: ${_tanggalLangganan.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
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
