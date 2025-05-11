import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../widgets/strong_main_button.dart';
import '../utils/utils.dart';

class AddPembayaranUserPage extends StatefulWidget {
  const AddPembayaranUserPage({Key? key}) : super(key: key);
  @override State<AddPembayaranUserPage> createState() => _AddPembayaranUserPageState();
}

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> {
  final _storage = const FlutterSecureStorage();
  final _bulanCtrl = TextEditingController();
  String _status = 'menunggu_verifikasi';
  File? _image;
  bool _saving = false;

  @override void dispose() {
    _bulanCtrl.dispose();
    super.dispose();
  }

  Future _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future _save() async {
    if (_bulanCtrl.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua field')));
      return;
    }
    setState(() => _saving = true);
    try {
      final pidStr = await _storage.read(key: 'pelanggan_id');
      final pid = int.tryParse(pidStr ?? '');
      if (pid == null) throw Exception('Tidak ada pelanggan_id');
      await PembayaranService.createPembayaranUser(
        pelangganId: pid,
        bulanTahun: _bulanCtrl.text.trim(),
        statusVerifikasi: _status,
        imageFile: _image!,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Tambah Pembayaran'), backgroundColor: Utils.mainThemeColor),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        TextFormField(
          controller: _bulanCtrl,
          decoration: const InputDecoration(labelText: 'Bulan-Tahun (MM-YYYY)'),
        ),
        const SizedBox(height:16),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: ['menunggu_verifikasi','diterima','ditolak']
              .map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
          onChanged: (v)=>setState(()=>_status=v!),
        ),
        const SizedBox(height:16),
        Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height:8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height:200,
            decoration: BoxDecoration(border: Border.all(color:Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: _image==null
                ? const Center(child: Icon(Icons.add_a_photo, size:48))
                : Image.file(_image!, fit:BoxFit.cover, width: double.infinity),
          ),
        ),
        const SizedBox(height:24),
        _saving
            ? const Center(child:CircularProgressIndicator())
            : StrongMainButton(label:'Simpan', onTap:_save),
      ]),
    ),
  );
}
