// // lib/pages/home_page.dart
// import 'package:flutter/material.dart';
// import '../models/dashboard.dart';
// import '../services/api_service.dart';
// import '../utils/utils.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   Dashboard? dashboard;
//   bool isLoading = true;
//   String? error;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDashboard();
//   }
//
//   Future<void> loadDashboard() async {
//     try {
//       final data = await fetchSingleData('dashboard');
//       setState(() {
//         dashboard = Dashboard.fromJson(data);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (error != null) {
//       return Center(child: Text('Terjadi kesalahan: $error'));
//     }
//
//     // Siapkan list kartu
//     final items = [
//       {
//         'title': 'Total Pelanggan',
//         'value': dashboard!.pelanggan,
//         'icon': Icons.people,
//         'color': Utils.mainThemeColor,
//       },
//       {
//         'title': 'Paket Aktif',
//         'value': dashboard!.paketAktif,
//         'icon': Icons.wifi,
//         'color': Colors.blue,
//       },
//       {
//         'title': 'Tagihan Lunas',
//         'value': dashboard!.tagihanLunas,
//         'icon': Icons.check_circle,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Pending Bayar',
//         'value': dashboard!.pendingBayar,
//         'icon': Icons.pending_actions,
//         'color': Colors.orange,
//       },
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Dashboard',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 // Hitung jumlah kolom berdasarkan lebar, minimal 2
//                 int count = (constraints.maxWidth / 200).floor().clamp(2, 4);
//                 return GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: count,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1, // persegi
//                   ),
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 4,
//                       child: InkWell(
//                         onTap: () {
//                           // aksi saat kartu diketuk
//                         },
//                         borderRadius: BorderRadius.circular(16),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(item['icon'] as IconData,
//                                   size: 36, color: item['color'] as Color),
//                               const SizedBox(height: 12),
//                               Text(
//                                 '${item['value']}',
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 item['title'] as String,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
