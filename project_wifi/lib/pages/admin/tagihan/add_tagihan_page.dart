// lib/pages/add_tagihan_page.dart
import 'package:flutter/material.dart';
import '../../../models/pelanggan.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

class AddTagihanPage extends StatefulWidget {
  const AddTagihanPage({Key? key}) : super(key: key);
  @override
  State<AddTagihanPage> createState() => _AddTagihanPageState();
}

class _AddTagihanPageState extends State<AddTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  List<Pelanggan> _pelanggans = [];
  Pelanggan? _selected;
  final TextEditingController _bulanCtrl = TextEditingController();
  String _status = 'belum_dibayar';
  DateTime? _jatuhTempo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPel();
  }

  void _loadPel() async {
    final list = await fetchPelanggans();
    setState(() => _pelanggans = list);
  }

  Future _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _jatuhTempo = d);
  }

  Future _save() async {
    if (!_formKey.currentState!.validate() || _selected == null || _jatuhTempo == null) return;
    setState(() => _saving = true);
    final data = {
      'pelanggan_id': _selected!.id,
      'bulan_tahun': _bulanCtrl.text.trim(),
      'status_pembayaran': _status,
      'jatuh_tempo': _jatuhTempo!.toIso8601String(),
    };
    try {
      await createTagihan(data);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal tambah tagihan: \$e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Tambah Tagihan'), backgroundColor: Utils.mainThemeColor),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<Pelanggan>(
              decoration: const InputDecoration(labelText: 'Pelanggan'),
              items: _pelanggans.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _selected = v),
              validator: (v) => v == null ? 'Pilih pelanggan' : null,
            ),
            const SizedBox(height: 12),
            Utils.generateInputField(hintText: 'Bulan-Tahun', iconData: Icons.date_range, controller: _bulanCtrl, isPassword: false, onChanged: (_) {}),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['belum_dibayar', 'menunggu_verifikasi', 'lunas'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(_jatuhTempo == null ? 'Pilih Jatuh Tempo' : _jatuhTempo!.toLocal().toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            _saving ? const Center(child: CircularProgressIndicator()) : StrongMainButton(label: 'Simpan', onTap: _save),
          ],
        ),
      ),
    ),
  );
}