import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/utils.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
        body: Stack(
          children: const [
            Center(
                child: Icon(Icons.wifi, color: Colors.white, size: 60)
            ),
            Center(
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    )
                )
            )
          ],
        )
    );
  }
}
