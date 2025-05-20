import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_wifi/models/paket.dart';
import 'package:project_wifi/models/pelanggan.dart';
import 'package:project_wifi/models/pembayaran.dart';
import 'package:project_wifi/models/tagihan.dart';
import 'widgets/main_layout.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin/paket/add_paket_page.dart';
import 'pages/admin/paket/edit_paket_page.dart';
import 'pages/admin/pelanggan/add_pelanggan_page.dart';
import 'pages/admin/pelanggan/edit_pelanggan_page.dart';
import 'pages/admin/tagihan/add_tagihan_page.dart';
import 'pages/admin/tagihan/edit_tagihan_page.dart';
import 'pages/admin/pembayaran/add_pembayaran_page.dart';
import 'pages/admin/pembayaran/edit_pembayaran_page.dart';
import 'pages/user/pembayaran/add_pembayaran_user_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/add_paket': (context) => const AddPaketPage(),
        '/edit_paket': (context) {
          final paket = ModalRoute.of(context)!.settings.arguments as Paket;
          return EditPaketPage(paket: paket);
        },
        '/add_pelanggan': (context) => const AddPelangganPage(),
        '/edit_pelanggan': (context) {
          final pelanggan = ModalRoute.of(context)!.settings.arguments as Pelanggan;
          return EditPelangganPage(pelanggan: pelanggan);
        },
        '/add_tagihan': (context) => const AddTagihanPage(),
        '/edit_tagihan': (context) {
          final tagihan = ModalRoute.of(context)!.settings.arguments as Tagihan;
          return EditTagihanPage(tagihan: tagihan);
        },
        '/add_pembayaran': (_) => AddPembayaranPage(),
        '/edit_pembayaran': (ctx) {
          final pembayaran = ModalRoute.of(ctx)!.settings.arguments as Pembayaran;
          return EditPembayaranPage(pembayaran: pembayaran);
        },
        '/add_pembayaran_user': (_) => AddPembayaranUserPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final role = settings.arguments as String? ?? 'pelanggan';
          return MaterialPageRoute(
            builder: (_) => MainLayout(role: role),
          );
        }
        return null;
      },
    );
  }
}