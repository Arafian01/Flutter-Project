import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(FlutterBankApp());
}

class Utils {
  static const Color mainThemeColor = Color(0xFF8700C3);
}

class FlutterBankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme
        )
      ),
      debugShowCheckedModeBanner: false,
      home: FlutterBankSplash(),
    );
  }
}

class FlutterBankSplash extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
      body: Stack(
        children: [
          Center(
            child: Icon(Icons.savings, color: Colors.white, size: 60,),
          ),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}