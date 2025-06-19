import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  String? _name, _email, _telepon, _alamat, _namaPaket, _status, _tanggalAktif, _tanggalLangganan;
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final pelangganData = prefs.getString('pelanggan_data');
      if (pelangganData == null) {
        throw Exception('Data pelanggan tidak ditemukan');
      }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              'Konfirmasi Logout',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryBlue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.secondaryBlue,
            size: AppSizes.iconSizeMedium,
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? '-',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
        ),
      )
          : SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.primaryBlue,
              floating: true,
              pinned: false,
              title: const Text(
                'Profil Akun',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge, vertical: AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.secondaryBlue.withOpacity(0.3),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              Text(
                                _name?.toUpperCase() ?? '-',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingSmall),
                              Text(
                                _email ?? '-',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondaryBlue,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Akun',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildInfoItem(Icons.phone, 'Telepon', _telepon),
                              _buildInfoItem(Icons.home, 'Alamat', _alamat),
                              _buildInfoItem(Icons.card_giftcard, 'Nama Paket', _namaPaket),
                              _buildInfoItem(Icons.toggle_on, 'Status', _status),
                              _buildInfoItem(Icons.check_circle, 'Tanggal Aktif', _tanggalAktif),
                              _buildInfoItem(Icons.calendar_month, 'Tanggal Langganan', _tanggalLangganan),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        ElevatedButton(
                          onPressed: _showLogoutDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentRed,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 4,
                          ),
                          child: const Text('Logout'),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}