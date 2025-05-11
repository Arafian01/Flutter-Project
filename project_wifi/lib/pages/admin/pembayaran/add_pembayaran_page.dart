// lib/pages/add_pembayaran_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

class AddPembayaranPage extends StatefulWidget {
  const AddPembayaranPage({Key? key}) : super(key: key);
  @override
  State<AddPembayaranPage> createState() => _AddPembayaranPageState();
}

class _AddPembayaranPageState extends State<AddPembayaranPage> {
  List<Tagihan> _tagihans = [];
  Tagihan? _selected;
  String _status = 'menunggu verifikasi';
  File? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTagihans();
  }

  Future<void> _loadTagihans() async {
    try {
      final list = await TagihanService.fetchTagihans();
      setState(() => _tagihans = list);
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future<void> _save() async {
    if (_selected == null || _image == null) return;
    setState(() => _saving = true);
    try {
      await PembayaranService.createPembayaran(
        tagihanId: _selected!.id,
        statusVerifikasi: _status,
        imageFile: _image!,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (e.toString().contains('409')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tagihan ini sudah pernah dibayar')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Tambah Pembayaran'),
      backgroundColor: Utils.mainThemeColor,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        DropdownButtonFormField<Tagihan>(
          decoration: const InputDecoration(labelText: 'Pilih Tagihan'),
          items: _tagihans
              .map((t) => DropdownMenuItem(value: t, child: Text('${t.bulanTahun} • Rp ${t.harga}')))
              .toList(),
          onChanged: (v) => setState(() => _selected = v),
          validator: (v) => v == null ? 'Harus memilih tagihan' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(labelText: 'Status Verifikasi'),
          items: ['menunggu verifikasi', 'diterima', 'ditolak']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text(_image == null ? 'Pilih Bukti' : _image!.path.split('/').last),
          trailing: const Icon(Icons.image),
          onTap: _pickImage,
        ),
        const SizedBox(height: 20),
        _saving
            ? const Center(child: CircularProgressIndicator())
            : StrongMainButton(label: 'Simpan', onTap: _save),
      ]),
    ),
  );
}
