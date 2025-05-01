import 'package:flutter/material.dart';

abstract class Utils {
  static const Color mainThemeColor = Color(0xFFFF0000);

  /// Generate a TextFormField with consistent styling and optional validator.
  static Widget generateInputField({
    required String hintText,
    required IconData iconData,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      obscuringCharacter: '*',
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(iconData),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
