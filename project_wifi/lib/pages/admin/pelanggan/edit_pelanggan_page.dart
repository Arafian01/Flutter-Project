
// lib/pages/edit_pelanggan_page.dart
import 'package:flutter/material.dart';
import '../../../models/pelanggan.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../widgets/strong_main_button.dart';
import '../../../utils/utils.dart';

class EditPelangganPage extends StatefulWidget {
  final Pelanggan pelanggan;
  const EditPelangganPage({Key? key, required this.pelanggan}) : super(key: key);

  @override
  State<EditPelangganPage> createState() => _EditPelangganPageState();
}

class _EditPelangganPageState extends State<EditPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _teleponCtrl;
  DateTime? _tanggalAktif;
  DateTime? _tanggalLangganan;
  String _status = 'aktif';
  List<Paket> _pakets = [];
  Paket? _selectedPaket;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pelanggan;
    _nameCtrl = TextEditingController(text: p.name);
    _emailCtrl = TextEditingController(text: p.email);
    _passwordCtrl = TextEditingController();
    _alamatCtrl = TextEditingController(text: p.alamat);
    _teleponCtrl = TextEditingController(text: p.telepon);
    _tanggalAktif = p.tanggalAktif;
    _tanggalLangganan = p.tanggalLangganan;
    _status = p.status;
    _loadPakets();
  }

  void _loadPakets() async {
    final list = await fetchPakets();
    setState(() {
      _pakets = list;
      _selectedPaket = _pakets.firstWhere((x) => x.id == widget.pelanggan.paketId, orElse: () => _pakets.first);
    });
  }

  Future<void> _pickDate(bool isAktif) async {
    final initial = isAktif ? _tanggalAktif! : _tanggalLangganan!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => isAktif ? _tanggalAktif = picked : _tanggalLangganan = picked);
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _selectedPaket == null || _tanggalAktif == null || _tanggalLangganan == null) return;
    setState(() => _isSaving = true);
    final data = {
      'user_id': widget.pelanggan.userId,
      'name' : _nameCtrl.text.trim(),
      'email' : _emailCtrl.text.trim(),
      'paket_id': _selectedPaket!.id,
      'status': _status,
      'alamat': _alamatCtrl.text.trim(),
      'telepon': _teleponCtrl.text.trim(),
      'tanggal_aktif': _tanggalAktif!.toIso8601String(),
      'tanggal_langganan': _tanggalLangganan!.toIso8601String(),
    };
    if (_passwordCtrl.text.isNotEmpty) data['password'] = _passwordCtrl.text;
    try {
      await updatePelanggan(widget.pelanggan.id, data);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update pelanggan: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pelanggan'), backgroundColor: Utils.mainThemeColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Utils.generateInputField(hintText: 'Name', iconData: Icons.person, controller: _nameCtrl, isPassword: false, onChanged: (_) {}),
              const SizedBox(height: 12),
              Utils.generateInputField(hintText: 'Email', iconData: Icons.email, controller: _emailCtrl, isPassword: false, onChanged: (_) {}),
              const SizedBox(height: 12),
              Utils.generateInputField(hintText: 'Password (kosong = tidak diubah)', iconData: Icons.lock, controller: _passwordCtrl, isPassword: true, onChanged: (_) {}),
              const SizedBox(height: 12),
              DropdownButtonFormField<Paket>(
                value: _selectedPaket,
                decoration: const InputDecoration(labelText: 'Pilih Paket'),
                items: _pakets.map((p) => DropdownMenuItem(value: p, child: Text(p.namaPaket))).toList(),
                onChanged: (v) => setState(() => _selectedPaket = v),
                validator: (v) => v == null ? 'Pilih paket' : null,
              ),
              const SizedBox(height: 12),
              Utils.generateInputField(hintText: 'Alamat', iconData: Icons.home, controller: _alamatCtrl, isPassword: false, onChanged: (_) {}),
              const SizedBox(height: 12),
              Utils.generateInputField(hintText: 'Telepon', iconData: Icons.phone, controller: _teleponCtrl, isPassword: false, onChanged: (_) {}),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['aktif','nonaktif','isolir'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
                onChanged:(v)=>setState(()=>_status=v!),
              ),
              const SizedBox(height:12),
              ListTile(title:Text(_tanggalAktif==null?'Pilih Tanggal Aktif':_tanggalAktif!.toLocal().toString().split(' ')[0]),trailing:Icon(Icons.calendar_today),onTap:()=>_pickDate(true)),
              ListTile(title:Text(_tanggalLangganan==null?'Pilih Tanggal Langganan':_tanggalLangganan!.toLocal().toString().split(' ')[0]),trailing:Icon(Icons.calendar_today),onTap:()=>_pickDate(false)),
              const SizedBox(height:20),
              _isSaving?Center(child:CircularProgressIndicator()):StrongMainButton(label:'Update',onTap:_update),
            ],
          ),
        ),
      ),
    );
  }
}
