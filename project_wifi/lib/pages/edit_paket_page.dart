// lib/pages/edit_paket_page.dart
import 'package:flutter/material.dart';
import '../models/paket.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class EditPaketPage extends StatefulWidget {
  final Paket paket;
  EditPaketPage({required this.paket});

  @override
  _EditPaketPageState createState() => _EditPaketPageState();
}

class _EditPaketPageState extends State<EditPaketPage> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _nama, _desc, _harga;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.paket.namaPaket);
    _desc = TextEditingController(text: widget.paket.deskripsi);
    _harga = TextEditingController(text: widget.paket.harga.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Paket'),
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
                    await updatePaket(widget.paket.id!, {
                      'nama_paket': _nama.text,
                      'deskripsi': _desc.text,
                      'harga': int.parse(_harga.text),
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
