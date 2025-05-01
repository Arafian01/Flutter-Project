// lib/pages/dashboard_user_page.dart
import 'package:flutter/material.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Dashboard User',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}