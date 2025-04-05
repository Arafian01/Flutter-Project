import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAx6fTH7tTCp52VACrDsy4HOPj44hPNFoA",
        authDomain: "flutter-bank-app-a6bcb.firebaseapp.com",
        projectId: "flutter-bank-app-a6bcb",
        storageBucket: "flutter-bank-app-a6bcb.firebasestorage.app",
        messagingSenderId: "171914461505",
        appId: "1:171914461505:web:f4ed22ef1c9d9caf2061c0"
    )
  );

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginService(),
          )
        ],
        child: FlutterBankApp(),
    )
  );
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

    LoginService loginService = Provider.of<LoginService>(context, listen: false);

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
                )),
            FlutterBankMainButton(
              label: 'Sign In',
              enabled: true,
              onTap: () async {
                var username = usernameController.value.text;
                var pwd = passwordController.value.text;

                bool isLoggedIn = await loginService.signInWithEmailAndPassword(username, pwd);

                if (isLoggedIn) {
                  usernameController.clear();
                  passwordController.clear();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FlutterBankMain())
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            FlutterBankMainButton(
              label: 'Register',
              icon: Icons.account_circle,
              onTap: () {},
              backgroundColor: Utils.mainThemeColor.withOpacity(0.05),
              iconColor: Utils.mainThemeColor,
              labelColor: Utils.mainThemeColor,
            )
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
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;

  const FlutterBankMainButton({
    Key? key, this.label, this.onTap,
    this.icon,
    this.backgroundColor = Utils.mainThemeColor,
    this.iconColor = Colors.white,
    this.labelColor = Colors.white,
    this.enabled = true})
  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            color: enabled! ? backgroundColor : backgroundColor!.withOpacity(0.5),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: icon != null,
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Icon(icon, color: iconColor, size: 20,),
                        ),
                      ),
                      Text(label!, textAlign: TextAlign.center,
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  )
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class LoginService extends ChangeNotifier {

  String _userId = '';

  String getUserId() {
    return _userId;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _userId = credentials.user!.uid;

      return true;
    } on FirebaseAuthException catch (ex) {
      return false;
    }
  }
}

class FlutterBankMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('main page'),
      ),
    );
  }
}