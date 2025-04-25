import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppBottomBar({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed, // agar bisa lebih dari 3 item
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Paket'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Tagihan'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
      ],
    );
  }
}
