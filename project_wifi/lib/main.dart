import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(StrongWifiApp());
}

class StrongWifiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strong WiFi Manager',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: Utils.mainThemeColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => StrongSplash(),
        '/landing': (_) => StrongLandingPage(),
        '/login': (_) => StrongLogin(),
        '/register': (_) => StrongAccountRegistration(),
        '/main': (_) => StrongWifiMain(),
      },
    );
  }
}

class StrongSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/landing');
    });

    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
      body: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.wifi,
              color: Colors.white,
              size: 80,
            ),
          ),
          const Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class StrongSplash extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 2), () {
//       // Setelah splash, langsung ke landing page
//       Navigator.of(context).pushReplacementNamed('/landing');
//     });
//
//     return Scaffold(
//       backgroundColor: Utils.mainThemeColor,
//       body: const Center(
//         child: CircularProgressIndicator(
//           strokeWidth: 8,
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       ),
//     );
//   }
// }

class StrongLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.mainThemeColor,
        title: const Text('Strong App'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/register'),
            child: const Text('Register', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Menemukan perusahaan Strong Net!',
          style: TextStyle(
            color: Utils.mainThemeColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StrongLogin extends StatefulWidget {
  @override
  _StrongLoginState createState() => _StrongLoginState();
}

class _StrongLoginState extends State<StrongLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 60),
          CircleAvatar(
            radius: 40,
            backgroundColor: Utils.mainThemeColor.withOpacity(0.1),
            child: Icon(
              Icons.wifi,
              size: 40,
              color: Utils.mainThemeColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const Text(
            'Strong WiFi Manager',
            style: TextStyle(
              color: Utils.mainThemeColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Utils.generateInputField(
            hintText: 'Email',
            iconData: Icons.email,
            controller: emailController,
            isPassword: false,
            onChanged: (text) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Utils.generateInputField(
            hintText: 'Password',
            iconData: Icons.lock,
            controller: passwordController,
            isPassword: true,
            onChanged: (text) => setState(() {}),
          ),
          const SizedBox(height: 40),
          StrongMainButton(
            label: 'Sign In',
            onTap: () => Navigator.of(context).pushReplacementNamed('/main'),
          ),
          const SizedBox(height: 16),
          StrongMainButton(
              label: 'Register',
              icon: Icons.person_add,
              backgroundColor: Colors.transparent,
              labelColor: Utils.mainThemeColor,
              iconColor: Utils.mainThemeColor,
              onTap: () => Navigator.of(context).pushNamed('/register'),
    ),
    ],
    ),
    ),
    );
  }
}

class StrongAccountRegistration extends StatefulWidget {
  @override
  StrongAccountRegistrationState createState() => StrongAccountRegistrationState();
}

class StrongAccountRegistrationState extends State<StrongAccountRegistration> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Utils.mainThemeColor),
        title: const Icon(Icons.wifi, color: Utils.mainThemeColor, size: 40),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Create New Account',
              style: TextStyle(
                color: Utils.mainThemeColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Utils.generateInputField(
              hintText: 'Email',
              iconData: Icons.email,
              controller: emailController,
              isPassword: false,
              onChanged: (text) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Password',
              iconData: Icons.lock,
              controller: passwordController,
              isPassword: true,
              onChanged: (text) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Utils.generateInputField(
              hintText: 'Confirm Password',
              iconData: Icons.lock,
              controller: confirmController,
              isPassword: true,
              onChanged: (text) => setState(() {}),
            ),
            const Spacer(),
            StrongMainButton(
              label: 'Register',
              onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

class StrongWifiMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.mainThemeColor,
        title: const Text('Strong WiFi Manager'),
      ),
      body: Center(
        child: Text(
          'Selamat datang di halaman utama!',
          style: TextStyle(
            color: Utils.mainThemeColor,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class StrongMainButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;

  const StrongMainButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor = Utils.mainThemeColor,
    this.iconColor = Colors.white,
    this.labelColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: backgroundColor,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Utils {
  static const Color mainThemeColor = Color(0xFFFF0000);

  static Widget generateInputField({
    required String hintText,
    required IconData iconData,
    required TextEditingController controller,
    required bool isPassword,
    required Function(String) onChanged,
  }) =>
      TextField(
        controller: controller,
        obscureText: isPassword,
        obscuringCharacter: '*',
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(iconData, color: mainThemeColor),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      );
}