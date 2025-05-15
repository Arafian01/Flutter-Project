// lib/pages/add_pembayaran_user_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../../../models/tagihan.dart';
import '../widgets/strong_main_button.dart';
import '../utils/utils.dart';

class AddPembayaranUserPage extends StatefulWidget {
  const AddPembayaranUserPage({Key? key}) : super(key: key);
  @override
  State<AddPembayaranUserPage> createState() => _AddPembayaranUserPageState();
}

class _AddPembayaranUserPageState extends State<AddPembayaranUserPage> {
  final _storage = const FlutterSecureStorage();
  List<Tagihan> _tagihans = [];
  Tagihan? _selected;
  File? _image;
  bool _saving = false;
  String _status = 'menunggu verifikasi';
  late final int _tagihanId;
  late final String _bulanTahun;

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

  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _tagihanId = args['tagihanId'] as int;
    _bulanTahun = args['bulanTahun'] as String;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar bukti')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await PembayaranService.createPembayaran(
        tagihanId: _tagihanId,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayar Tagihan'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Periode: $_bulanTahun', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // DropdownButtonFormField<String>(
            //   value: _status,
            //   decoration: const InputDecoration(labelText: 'Status Pembayaran'),
            //   items: ['menunggu_verifikasi', 'diterima', 'ditolak']
            //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            //       .toList(),
            //   onChanged: (v) => setState(() => _status = v!),
            // ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 48))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : StrongMainButton(label: 'Kirim Pembayaran', onTap: _save),
          ],
        ),
      ),
    );
  }
}
