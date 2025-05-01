// lib/pages/profil_page.dart
import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil Saya', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Contoh data profil, nanti ganti dengan data dinamis
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nama'),
            subtitle: Text('Nama User'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text('user@example.com'),
          ),
        ],
      ),
    );
  }
}