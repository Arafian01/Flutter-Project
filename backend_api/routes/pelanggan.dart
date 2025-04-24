import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart'; // Pastikan import PostgreSQL
import '../lib/database.dart';  // Pastikan import ke database.dart dengan path yang benar
import '../lib/models/pelanggan.dart';  // Pastikan import ke pelanggan.dart dengan path yang benar

Future<Response> onRequest(RequestContext context) async {
  late final PostgreSQLConnection connection;

  try {
    connection = await createConnection();

    final results = await connection.query('''
      SELECT pelanggans.id, users.name, users.email, pakets.nama_paket, pelanggans.status, pelanggans.alamat, pelanggans.telepon
      FROM pelanggans
      JOIN users ON pelanggans.user_id = users.id
      JOIN pakets ON pelanggans.paket_id = pakets.id
    ''');

    // Mapping hasil query ke model Pelanggan
    final pelangganList = results.map((row) => Pelanggan.fromRow(row)).toList();

    return Response.json(body: pelangganList);
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await connection.close();
  }
}
