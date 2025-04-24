import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red,
      title: Text('StrongNet'),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            // Aksi ketika ikon diklik
          },
        ),
      ],
    );
  }
}
