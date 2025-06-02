import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'pages/admin/pembayaran/pembayaran_page.dart';
import 'pages/admin/pembayaran/edit_pembayaran_page.dart';
import 'pages/user/pembayaran/add_pembayaran_user_page.dart';
import 'pages/user/pembayaran/detail_pembayaran_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
    print('Date formatting initialized for id_ID');
  } catch (e) {
    print('Failed to initialize date formatting: $e');
  }
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
        '/pembayaran': (context) => const PembayaranPage(),
        '/add_pembayaran': (context) => AddPembayaranPage(),
        '/edit_pembayaran': (context) {
          final pembayaran = ModalRoute.of(context)!.settings.arguments as Pembayaran;
          return EditPembayaranPage(pembayaran: pembayaran);
        },
        '/add_pembayaran_user': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final tagihan = args['tagihan'] as Tagihan;
          final pelangganId = args['pelangganId'] as int;
          return AddPembayaranUserPage(tagihan: tagihan, pelangganId: pelangganId);
        },
        '/detail_pembayaran': (context) {
          final pembayaran = ModalRoute.of(context)!.settings.arguments as Pembayaran;
          return DetailPembayaranPage(pembayaran: pembayaran);
        },
        // '/detail_pembayaran': (context) => DetailPembayaranPage(pembayaran: pembayaran)
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