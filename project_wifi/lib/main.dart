// lib/main.dart
import 'package:flutter/material.dart';
import 'widgets/main_layout.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

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
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final role = settings.arguments as String? ?? 'user';
          return MaterialPageRoute(
            builder: (_) => MainLayout(role: role),
          );
        }
        return null;
      },
    );
  }
}
