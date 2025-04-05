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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => FlutterBankLogin())
      );
    });

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

class FlutterBankLogin extends StatefulWidget {
  @override
  FlutterBankLoginState createState() => FlutterBankLoginState();
}

class FlutterBankLoginState extends State<FlutterBankLogin>{

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 7,
                  color: Utils.mainThemeColor
                ),
                borderRadius: BorderRadius.circular(100)
              ),
              child: const Icon(Icons.savings, color: Utils.mainThemeColor, size: 45,),
            ),
            const SizedBox(height: 30),
            const Text('Welcome to', style: TextStyle(color: Colors.grey,fontSize: 15)),
            const Text('Flutter\nSavings Bank',
                style: TextStyle(color: Utils.mainThemeColor, fontSize: 30)),
            Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Sign Into Your Bank Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: TextField(
                          onChanged: (text) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email, color: Utils.mainThemeColor),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 20, bottom: 11, top: 11, right: 15
                            ),
                            hintText: "Email"
                          ),
                          style: const TextStyle(fontSize: 16),
                          controller: usernameController,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: TextField(
                          onChanged: (text) {
                            setState(() {});
                          },
                          obscureText: true,
                          obscuringCharacter: "*",
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Utils.mainThemeColor,),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15
                            ),
                            hintText: "Password"
                          ),
                          controller: passwordController,
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class FlutterBankMainButton extends StatelessWidget {
  final Function? onTap;
  final String? label;
  final bool? enabled;

  const FlutterBankMainButton({
    Key? key, this.label, this.onTap, this.enabled = true})
  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            color: enabled! ? Utils.mainThemeColor : Utils.mainThemeColor.withOpacity(0.5),
            child: InkWell(
              onTap: enabled! ? () {
                onTap!();
              } : null,
              highlightColor: Colors.white.withOpacity(0.2),
              splashColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Text(label!, textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
