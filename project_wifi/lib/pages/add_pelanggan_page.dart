import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class AddPelangganPage extends StatefulWidget {
  @override
  _AddPelangganPageState createState() => _AddPelangganPageState();
}

class _AddPelangganPageState extends State<AddPelangganPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _paketId = TextEditingController();
  final _status = TextEditingController();
  final _tanggalLang = TextEditingController();
  final _alamat = TextEditingController();
  final _telepon = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pelanggan'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Wajib' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Wajib' : null,
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _paketId,
                decoration: const InputDecoration(labelText: 'Paket ID'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _status,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                controller: _tanggalLang,
                decoration:
                const InputDecoration(labelText: 'Tanggal Langganan (YYYY-MM-DD)'),
              ),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                controller: _telepon,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Utils.mainThemeColor),
                onPressed: () async {
                  if (_form.currentState!.validate()) {
                    await createPelanggan({
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
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
