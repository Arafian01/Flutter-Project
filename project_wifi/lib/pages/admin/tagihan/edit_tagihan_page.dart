// lib/pages/edit_tagihan_page.dart
import 'package:flutter/material.dart';
import '../../../models/pelanggan.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

class EditTagihanPage extends StatefulWidget {
  final Tagihan tagihan;
  const EditTagihanPage({Key? key, required this.tagihan}) : super(key: key);
  @override
  State<EditTagihanPage> createState() => _EditTagihanPageState();
}

class _EditTagihanPageState extends State<EditTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  List<Pelanggan> _pelanggans = [];
  Pelanggan? _selected;
  late TextEditingController _bulanCtrl;
  String _status = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bulanCtrl = TextEditingController(text: widget.tagihan.bulanTahun);
    _status = widget.tagihan.statusPembayaran;
    _loadPelanggans();
  }

  Future<void> _loadPelanggans() async {
    _pelanggans = await fetchPelanggans();
    _selected = _pelanggans.firstWhere((p) => p.id == widget.tagihan.pelangganId);
    setState(() {});
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    setState(() => _saving = true);
    try {
      await TagihanService.updateTagihan(
        widget.tagihan.id,
        pelangganId: _selected!.id,
        bulanTahun: _bulanCtrl.text.trim(),
        statusPembayaran: _status,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update tagihan: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Tagihan'), backgroundColor: Utils.mainThemeColor),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<Pelanggan>(
              value: _selected,
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
            _saving ? const Center(child: CircularProgressIndicator()) : StrongMainButton(label: 'Update', onTap: _update),
          ],
        ),
      ),
    ),
  );

}






