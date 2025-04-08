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
          ChangeNotifierProvider(
            create: (_) => LoginService(),
          )
        ],
        child: FlutterBankApp(),
    )
  );
}

class Utils {
  static const Color mainThemeColor = Color(0xFF8700C3);

  static bool validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);

    return (value != null || value!.isNotEmpty || regex.hasMatch(value));
  }

  static Widget generateInputField(
    String hintText,
    IconData iconData,
    TextEditingController controller,
    bool isPasswordField,
    Function onChanged) {

      return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50)
        ),
        child: TextField(
          onChanged: (text) {
            onChanged(text);
          },
          obscureText: isPasswordField,
          obscuringCharacter: "*",
          decoration: InputDecoration(
              prefixIcon: Icon(iconData, color: Utils.mainThemeColor,),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  left: 15, bottom: 11, top: 11, right: 15
              ),
              hintText: hintText
          ),
          controller: controller,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

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
                      ),

                      Consumer<LoginService>(
                        builder: (context, lService, child) {

                          String errorMsg = lService.getErrorMessage();

                          if (errorMsg.isEmpty) {
                            return const SizedBox(height: 40,);
                          }

                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red,),
                                const SizedBox(width: 10,),
                                Expanded(
                                    child: Text(
                                      errorMsg,
                                      style: const TextStyle(color: Colors.red),
                                    ))
                              ],
                            ),
                          );
                          return Container();
                        },
                      )
                    ],
                  ),
                )),
            FlutterBankMainButton(
              label: 'Sign In',
              enabled: validateEmailAndPassword(),
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
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FlutterAccountRegistration())
                );
              },
              backgroundColor: Utils.mainThemeColor.withOpacity(0.05),
              iconColor: Utils.mainThemeColor,
              labelColor: Utils.mainThemeColor,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validateEmailAndPassword() {
    return usernameController.value.text.isNotEmpty &&
        passwordController.value.text.isNotEmpty
        && Utils.validateEmail(usernameController.value.text);
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
  String _errorMessage = '';

  String getErrorMessage() {
    return _errorMessage;
  }

  void setLoginErrorMessage(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }
  String getUserId() {
    return _userId;
  }

  Future<bool> createUserWithEmailAndPassword(String email, String pwd) async {

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pwd);
      return true;

    } on FirebaseAuthException {
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    setLoginErrorMessage('');

    try {
      UserCredential credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _userId = credentials.user!.uid;

      return true;
    } on FirebaseAuthException catch (ex) {
      setLoginErrorMessage('Error during sign-in' + ex.message!);
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

class FlutterAccountRegistration extends StatefulWidget {
  @override
  FlutterAccountRegistrationState createState() => FlutterAccountRegistrationState();
}

class FlutterAccountRegistrationState extends State<FlutterAccountRegistration> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    LoginService loginService = Provider.of<LoginService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Utils.mainThemeColor),
        backgroundColor: Colors.transparent,
        title: const Icon(Icons.savings, color: Utils.mainThemeColor, size: 40,),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Text('Create New account',
                        style: TextStyle(color: Utils.mainThemeColor, fontSize: 20),
                      ),
                    ),

                    Utils.generateInputField('Email', Icons.email,
                      usernameController,
                      false, (text) {
                       setState(() {});
                      }),

                    Utils.generateInputField('Password', Icons.lock,
                      passwordController,
                      true, (text) {
                        setState(() {});
                      }),

                    Utils.generateInputField('Confitm Password', Icons.lock,
                        confirmPasswordController,
                        true, (text) {
                          setState(() {});
                        }),
                  ],
            )
            ),

            FlutterBankMainButton(
              label: 'Register',
              enabled: validateFormFields(),
              onTap: () async{
                String username = usernameController.value.text;
                String pwd = passwordController.value.text;

                bool accountCreated =
                    await loginService.createUserWithEmailAndPassword(username, pwd);

                if (accountCreated) {
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        ),
      )
    );
  }

  bool validateFormFields() {
    return Utils.validateEmail(usernameController.value.text) &&
    usernameController.value.text.isNotEmpty &&
    passwordController.value.text.isNotEmpty &&
    confirmPasswordController.value.text.isNotEmpty &&
      (passwordController.value.text == confirmPasswordController.value.text);
  }
}