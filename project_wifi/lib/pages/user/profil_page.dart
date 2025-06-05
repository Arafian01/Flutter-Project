import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/utils.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  String? _name, _email, _telepon, _alamat;
  String? _namaPaket, _status, _tanggalAktif, _tanggalLangganan;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final pelangganData = prefs.getString('pelanggan_data');

    if (pelangganData != null) {
      final data = jsonDecode(pelangganData);
      setState(() {
        _name = data['name'] ?? '-';
        _email = data['email'] ?? '-';
        _telepon = data['telepon'] ?? '-';
        _alamat = data['alamat'] ?? '-';
        _namaPaket = data['namaPaket'] ?? '-';
        _status = data['status'] ?? '-';
        _tanggalAktif = data['tanggalAktif'] ?? '-';
        _tanggalLangganan = data['tanggalLangganan'] ?? '-';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.accentRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String? value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    value ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Profil Saya'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: const Icon(
          Icons.person,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.person,
              color: AppColors.white,
              size: AppSizes.iconSizeMedium,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.accentRed),
                    SizedBox(width: AppSizes.paddingSmall),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
        ],
      ),
      body: _name == null
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: AppSizes.iconSizeMedium,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        Text(
                          'Profil Saya',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                  color: AppColors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.secondaryBlue.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Text(
                        _name!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        _email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildInfoCard(Icons.phone, 'Telepon', _telepon),
                _buildInfoCard(Icons.home, 'Alamat', _alamat),
                _buildInfoCard(Icons.card_giftcard, 'Paket', _namaPaket),
                _buildInfoCard(Icons.toggle_on, 'Status', _status),
                _buildInfoCard(Icons.check_circle, 'Tanggal Aktif', _tanggalAktif),
                _buildInfoCard(Icons.calendar_today, 'Tanggal Langganan', _tanggalLangganan),
                const SizedBox(height: AppSizes.paddingLarge),
                Center(
                  child: ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingMedium,
                        horizontal: AppSizes.paddingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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