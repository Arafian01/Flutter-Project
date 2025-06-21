import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? _name, _email, _telepon, _alamat, _namaPaket, _status, _tanggalAktif, _tanggalLangganan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pelangganData = prefs.getString('pelanggan_data');
      if (pelangganData == null) throw Exception('Data pelanggan tidak ditemukan');
      final data = jsonDecode(pelangganData) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _name = data['name'] as String? ?? '-';
          _email = data['email'] as String? ?? '-';
          _telepon = data['telepon'] as String? ?? '-';
          _alamat = data['alamat'] as String? ?? '-';
          _namaPaket = data['namaPaket'] as String? ?? '-';
          _status = data['status'] as String? ?? '-';
          _tanggalAktif = data['tanggalAktif'] as String? ?? '-';
          _tanggalLangganan = data['tanggalLangganan'] as String? ?? '-';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Gagal memuat profil: $e');
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pelanggan_data');
      if (mounted) {
        await Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Gagal logout: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(Icons.error_outline, color: AppColors.accentRed, size: 24),
          SizedBox(width: 8),
          Text('Error'),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(Icons.logout, color: AppColors.accentRed, size: 24),
          SizedBox(width: 8),
          Text('Konfirmasi Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: Text('Apakah Anda yakin ingin logout?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(fontSize: 14, color: AppColors.secondaryBlue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Logout', style: TextStyle(fontSize: 14, color: AppColors.accentRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryBlue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondaryBlue)),
                SizedBox(height: 4),
                Text(value ?? '-', style: TextStyle(fontSize: 14, color: AppColors.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Profil Akun', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
                          child: Icon(Icons.person, size: 40, color: AppColors.primaryBlue),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _name?.toUpperCase() ?? '-',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                        ),
                        SizedBox(height: 8),
                        Text(_email ?? '-', style: TextStyle(fontSize: 14, color: AppColors.textSecondaryBlue)),
                        SizedBox(height: 16),
                        Divider(color: AppColors.secondaryBlue.withOpacity(0.3)),
                        SizedBox(height: 12),
                        _buildInfoItem(Icons.phone, 'Telepon', _telepon),
                        _buildInfoItem(Icons.home, 'Alamat', _alamat),
                        _buildInfoItem(Icons.card_giftcard, 'Nama Paket', _namaPaket),
                        _buildInfoItem(Icons.toggle_on, 'Status', _status),
                        _buildInfoItem(Icons.check_circle, 'Tanggal Aktif', _tanggalAktif),
                        _buildInfoItem(Icons.calendar_month, 'Tanggal Langganan', _tanggalLangganan),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}