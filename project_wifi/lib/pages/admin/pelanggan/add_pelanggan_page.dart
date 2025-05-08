// lib/pages/add_pelanggan_page.dart
import 'package:flutter/material.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../widgets/strong_main_button.dart';
import '../../../utils/utils.dart';

class AddPelangganPage extends StatefulWidget {
  const AddPelangganPage({Key? key}) : super(key: key);

  @override
  State<AddPelangganPage> createState() => _AddPelangganPageState();
}

class _AddPelangganPageState extends State<AddPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _alamat = TextEditingController();
  final _telepon = TextEditingController();
  DateTime? _tanggalAktif;
  DateTime? _tanggalLangganan;
  String _status = 'aktif';
  List<Paket> _pakets = [];
  Paket? _selectedPaket;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPakets();
  }

  void _loadPakets() async {
    final list = await fetchPakets();
    setState(() => _pakets = list);
  }

  Future<void> _pickDate(bool isAktif) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() =>
    isAktif ? _tanggalAktif = picked : _tanggalLangganan = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPaket == null ||
        _tanggalAktif == null || _tanggalLangganan == null) return;
    setState(() => _saving = true);
    final data = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'paket_id': _selectedPaket!.id,
      'status': _status,
      'alamat': _alamat.text.trim(),
      'telepon': _telepon.text.trim(),
      'tanggal_aktif': _tanggalAktif!.toIso8601String(),
      'tanggal_langganan': _tanggalLangganan!.toIso8601String(),
    };
    try {
      await createPelanggan(data);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tambah pelanggan: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(title: const Text('Tambah Pelanggan'),
            backgroundColor: Utils.mainThemeColor),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Utils.generateInputField(hintText: 'Name',
                    iconData: Icons.person,
                    controller: _name,
                    isPassword: false,
                    onChanged: (_) {}),
                const SizedBox(height: 12),
                Utils.generateInputField(hintText: 'Email',
                    iconData: Icons.email,
                    controller: _email,
                    isPassword: false,
                    onChanged: (_) {}),
                const SizedBox(height: 12),
                Utils.generateInputField(hintText: 'Password',
                    iconData: Icons.lock,
                    controller: _password,
                    isPassword: true,
                    onChanged: (_) {}),
                const SizedBox(height: 12),
                DropdownButtonFormField<Paket>(
                  decoration: const InputDecoration(labelText: 'Pilih Paket'),
                  items: _pakets.map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.namaPaket)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPaket = v),
                  validator: (v) => v == null ? 'Pilih paket' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(hintText: 'Alamat',
                    iconData: Icons.home,
                    controller: _alamat,
                    isPassword: false,
                    onChanged: (_) {}),
                const SizedBox(height: 12),
                Utils.generateInputField(hintText: 'Telepon',
                    iconData: Icons.phone,
                    controller: _telepon,
                    isPassword: false,
                    onChanged: (_) {}),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['aktif', 'nonaktif', 'isolir'].map((s) =>
                      DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(_tanggalAktif == null
                      ? 'Pilih Tanggal Aktif'
                      : _tanggalAktif!.toLocal().toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(true),
                ),
                ListTile(
                  title: Text(_tanggalLangganan == null
                      ? 'Pilih Tanggal Langganan'
                      : _tanggalLangganan!.toLocal().toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(false),
                ),
                const SizedBox(height: 20),
                _saving
                    ? const Center(child: CircularProgressIndicator())
                    : StrongMainButton(label: 'Simpan', onTap: _save),
              ],
            ),
          ),
        ),
      );
}