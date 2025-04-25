import 'package:flutter/material.dart';
import '../models/pelanggan.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class EditPelangganPage extends StatefulWidget {
  final Pelanggan pelanggan;
  EditPelangganPage({required this.pelanggan});

  @override
  _EditPelangganPageState createState() => _EditPelangganPageState();
}

class _EditPelangganPageState extends State<EditPelangganPage> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name, _email, _paketId, _status,
      _tanggalLang, _alamat, _telepon, _password;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.pelanggan.name);
    _email = TextEditingController(text: widget.pelanggan.email);
    _password = TextEditingController();
    _paketId = TextEditingController(text: widget.pelanggan.paketId.toString());
    _status = TextEditingController(text: widget.pelanggan.status);
    _tanggalLang =
        TextEditingController(text: widget.pelanggan.tanggalLangganan);
    _alamat = TextEditingController(text: widget.pelanggan.alamat);
    _telepon = TextEditingController(text: widget.pelanggan.telepon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pelanggan'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password (kosongkan jika tidak ganti)'), obscureText: true),
              TextFormField(controller: _paketId, decoration: const InputDecoration(labelText: 'Paket ID'), keyboardType: TextInputType.number),
              TextFormField(controller: _status, decoration: const InputDecoration(labelText: 'Status')),
              TextFormField(controller: _tanggalLang, decoration: const InputDecoration(labelText: 'Tanggal Langganan')),
              TextFormField(controller: _alamat, decoration: const InputDecoration(labelText: 'Alamat')),
              TextFormField(controller: _telepon, decoration: const InputDecoration(labelText: 'Telepon')),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Utils.mainThemeColor),
                onPressed: () async {
                  if (_form.currentState!.validate()) {
                    await updatePelanggan(widget.pelanggan.id!, {
                      'name': _name.text,
                      'email': _email.text,
                      'password': _password.text,
                      'paket_id': int.parse(_paketId.text),
                      'status': _status.text,
                      'tanggal_langganan': _tanggalLang.text,
                      'alamat': _alamat.text,
                      'telepon': _telepon.text,
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
