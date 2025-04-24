import 'package:flutter/material.dart';
import '../utils/utils.dart';

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
