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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPelanggans();
  }

  Future<void> _loadPelanggans() async {
    _pelanggans = await fetchPelanggans();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    setState(() => _saving = true);
    try {
      await TagihanService.createTagihan(
        pelangganId: _selected!.id,
        bulanTahun: _bulanCtrl.text.trim(),
        statusPembayaran: _status,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal tambah tagihan: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              items: ['belum_dibayar', 'menunggu_verifikasi', 'lunas']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 20),
            _saving ? const Center(child: CircularProgressIndicator()) : StrongMainButton(label: 'Simpan', onTap: _save),
          ],
        ),
      ),
    ),
  );

}