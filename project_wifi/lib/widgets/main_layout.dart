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
import '../utils/utils.dart'; // Impor utils.dart

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
        DashboardAdminPage(),
        PaketPage(),
        PelangganPage(),
        TagihanPage(),
        PembayaranPage(),
        ReportPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wifi, size: AppSizes.iconSizeMedium),
          label: 'Paket',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, size: AppSizes.iconSizeMedium),
          label: 'Pelanggan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt, size: AppSizes.iconSizeMedium),
          label: 'Tagihan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment, size: AppSizes.iconSizeMedium),
          label: 'Pembayaran',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report, size: AppSizes.iconSizeMedium),
          label: 'Report',
        ),
      ];
    } else if (widget.role == 'pelanggan') {
      _pages = [
        DashboardUserPage(),
        TagihanUserPage(),
        PembayaranUserPage(),
        ProfilPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt, size: AppSizes.iconSizeMedium),
          label: 'Tagihan User',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment, size: AppSizes.iconSizeMedium),
          label: 'Pembayaran',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: AppSizes.iconSizeMedium),
          label: 'Profil',
        ),
      ];
    } else if (widget.role == 'owner') {
      _pages = [
        DashboardAdminPage(),
        ReportPage(),
      ];
      _items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: AppSizes.iconSizeMedium),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report, size: AppSizes.iconSizeMedium),
          label: 'Report',
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
      backgroundColor: AppColors.backgroundLight, // Latar belakang abu-abu muda
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryRed, // Merah untuk item terpilih
        unselectedItemColor: AppColors.textSecondary, // Abu-abu untuk item tidak terpilih
        backgroundColor: AppColors.white, // Latar belakang putih
        elevation: 8.0, // Bayangan untuk kesan mengambang
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.0, // Ukuran font label terpilih
        unselectedFontSize: 10.0, // Ukuran font label tidak terpilih
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
    );
  }
}