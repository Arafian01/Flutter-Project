// lib/pages/add_paket_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class AddPaketPage extends StatefulWidget {
  @override
  _AddPaketPageState createState() => _AddPaketPageState();
}

class _AddPaketPageState extends State<AddPaketPage> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _desc = TextEditingController();
  final _harga = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Paket'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama Paket'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _harga,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Utils.mainThemeColor),
                onPressed: () async {
                  if (_form.currentState!.validate()) {
                    await createPaket({
                      'nama_paket': _nama.text,
                      'deskripsi': _desc.text,
                      'harga': int.parse(_harga.text),
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
