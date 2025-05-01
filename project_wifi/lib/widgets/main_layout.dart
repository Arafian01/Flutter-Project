import 'package:flutter/material.dart';
import '../pages/dashboard_admin_page.dart';
import '../pages/dashboard_user_page.dart';
import '../pages/paket_page.dart';
import '../pages/pelanggan_page.dart';
import '../pages/tagihan_page.dart';
import '../pages/pembayaran_page.dart';
import '../pages/profil_page.dart';
import 'top_navbar.dart';

class MainLayout extends StatefulWidget {
  final String role;
  const MainLayout({Key? key, required this.role}) : super(key: key);

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
      ];
      _items = [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Paket'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Tagihan'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
      ];
    } else {
      _pages = [
        DashboardUserPage(),
        TagihanPage(),
        PembayaranPage(),
        ProfilPage(),
      ];
      _items = [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Tagihan'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavbar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
