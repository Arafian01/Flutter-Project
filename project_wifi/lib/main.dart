import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/pelanggan_page.dart';
import 'pages/tagihan_page.dart';
import 'pages/pembayaran_page.dart';
import 'widgets/bottom_navbar.dart';
import 'pages/splash_page.dart';
import 'pages/landing_page.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strong WiFi Manager',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/landing': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainLayout(),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PelangganPage(),
    TagihanPage(),
    PembayaranPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
