import 'package:flutter/material.dart';

class Utils {
  static const Color mainThemeColor = Color(0xFFFF0000); // Warna merah

  static Widget generateInputField({
    required String hintText,
    required IconData iconData,
    required TextEditingController controller,
    required bool isPassword,
    required Function(String) onChanged,
  }) {
    return TextField(
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
}
