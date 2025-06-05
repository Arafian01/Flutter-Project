import 'package:flutter/material.dart';
import '../pages/admin/dashboard_admin_page.dart';
import '../pages/user/dashboard_user_page.dart';
import '../pages/admin/paket/paket_page.dart';
import '../pages/admin/pelanggan/pelanggan_page.dart';
import '../pages/admin/tagihan/tagihan_page.dart';
import '../pages/admin/pembayaran/pembayaran_page.dart';
import '../pages/user/tagihan/tagihan_user_page.dart';
import '../pages/user/profil_page.dart';
import '../pages/user/pembayaran/pembayaran_user_page.dart';
import '../pages/report_page.dart';
import '../utils/utils.dart';

class MainLayout extends StatefulWidget {
  final String role;
  const MainLayout({super.key, required this.role});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _items;

  @override
  void initState() {
    super.initState();
    if (widget.role == 'admin') {
      _pages = [
        const DashboardAdminPage(),
        const PaketPage(),
        const PelangganPage(),
        const TagihanPage(),
        const PembayaranPage(),
        const ReportPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
          tooltip: 'Dashboard Admin',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.wifi, size: AppSizes.iconSizeMedium),
          label: 'Paket',
          tooltip: 'Kelola Paket',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people, size: AppSizes.iconSizeMedium),
          label: 'Pelanggan',
          tooltip: 'Kelola Pelanggan',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt, size: AppSizes.iconSizeMedium),
          label: 'Tagihan',
          tooltip: 'Kelola Tagihan',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.payment, size: AppSizes.iconSizeMedium),
          label: 'Pembayaran',
          tooltip: 'Verifikasi Pembayaran',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.report, size: AppSizes.iconSizeMedium),
          label: 'Laporan',
          tooltip: 'Lihat Laporan',
        ),
      ];
    } else if (widget.role == 'pelanggan') {
      _pages = [
        const DashboardUserPage(),
        const TagihanUserPage(),
        const PembayaranUserPage(),
        const ProfilPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
          tooltip: 'Ringkasan',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt, size: AppSizes.iconSizeMedium),
          label: 'Tagihan',
          tooltip: 'Lihat Tagihan',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.payment, size: AppSizes.iconSizeMedium),
          label: 'Pembayaran',
          tooltip: 'Riwayat Pembayaran',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person, size: AppSizes.iconSizeMedium),
          label: 'Profil',
          tooltip: 'Profil Pengguna',
        ),
      ];
    } else if (widget.role == 'owner') {
      _pages = [
        const DashboardAdminPage(),
        const ReportPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
          tooltip: 'Ringkasan',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.report, size: AppSizes.iconSizeMedium),
          label: 'Laporan',
          tooltip: 'Lihat Laporan',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.accentRed,
        unselectedItemColor: AppColors.textSecondaryBlue,
        backgroundColor: AppColors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.accentRed,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryBlue,
        ),
        showUnselectedLabels: true,
      ),
    );
  }
}