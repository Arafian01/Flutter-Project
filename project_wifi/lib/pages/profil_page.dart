// lib/pages/profil_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/utils.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _storage = const FlutterSecureStorage();

  String? _name, _email, _telepon, _alamat;
  String? _namaPaket, _status, _tanggalAktif, _tanggalLangganan;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _storage.read(key: 'name') ?? '-';
    final email = await _storage.read(key: 'email') ?? '-';
    final telepon = await _storage.read(key: 'telepon') ?? '-';
    final alamat = await _storage.read(key: 'alamat') ?? '-';
    final namaPaket = await _storage.read(key: 'namaPaket') ?? '-';
    final status = await _storage.read(key: 'status') ?? '-';
    final tanggalAktif = await _storage.read(key: 'tanggalAktif') ?? '-';
    final tanggalLangganan = await _storage.read(key: 'tanggalLangganan') ?? '-';

    setState(() {
      _name = name;
      _email = email;
      _telepon = telepon;
      _alamat = alamat;
      _namaPaket = namaPaket;
      _status = status;
      _tanggalAktif = tanggalAktif;
      _tanggalLangganan = tanggalLangganan;
    });
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Utils.mainThemeColor),
      title: Text(label),
      subtitle: Text(value ?? '-'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Utils.mainThemeColor,
        centerTitle: true,
      ),
      body: _name == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: Utils.mainThemeColor.withOpacity(0.2),
              child: Icon(Icons.person, size: 48, color: Utils.mainThemeColor),
            ),
            const SizedBox(height: 16),
            Text(
              _name!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _email!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 32),
            _buildInfoTile(Icons.phone, 'Telepon', _telepon),
            _buildInfoTile(Icons.home, 'Alamat', _alamat),
            _buildInfoTile(Icons.card_giftcard, 'Paket', _namaPaket),
            _buildInfoTile(Icons.toggle_on, 'Status', _status),
            _buildInfoTile(Icons.check_circle, 'Tanggal Aktif', _tanggalAktif),
            _buildInfoTile(Icons.calendar_today, 'Tanggal Langganan', _tanggalLangganan),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
