import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import '../lib/database.dart'; // Import ke file database.dart yang benar
import '../lib/models/paket.dart'; // Import ke model paket yang benar

// Endpoint untuk route /paket
Future<Response> onRequest(RequestContext context) async {
  late final PostgreSQLConnection connection;

  try {
    connection = await createConnection(); // Membuat koneksi ke database

    // Query untuk mengambil data paket dari database
    final results = await connection.query('''
      SELECT id, nama_paket, deskripsi, harga FROM pakets
    ''');

    // Mapping hasil query ke model Paket
    final paketList = results.map((row) => Paket.fromRow(row)).toList();

    return Response.json(body: paketList); // Mengembalikan data paket sebagai JSON
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500); // Menangani error jika terjadi
  } finally {
    await connection.close(); // Menutup koneksi setelah selesai
  }
}
