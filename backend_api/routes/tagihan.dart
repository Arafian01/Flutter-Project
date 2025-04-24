import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import '../lib/database.dart';  // Pastikan sudah mengimpor database.dart dengan benar
import '../lib/models/tagihan.dart'; // Pastikan sudah mengimpor model Tagihan dengan benar

// Endpoint untuk route /tagihan
Future<Response> onRequest(RequestContext context) async {
  late final PostgreSQLConnection connection;

  try {
    connection = await createConnection(); // Membuat koneksi ke database

    // Query untuk mengambil data tagihan dari database dengan relasi pelanggan -> user -> name
    final results = await connection.query('''
      SELECT tagihans.id, users.name, tagihans.bulan_tahun, tagihans.status_pembayaran, tagihans.jatuh_tempo
      FROM tagihans
      JOIN pelanggans ON tagihans.pelanggan_id = pelanggans.id
      JOIN users ON pelanggans.user_id = users.id
    ''');

    // Mapping hasil query ke model Tagihan
    final tagihanList = results.map((row) => Tagihan.fromRow(row)).toList();

    return Response.json(body: tagihanList); // Mengembalikan data tagihan sebagai JSON
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500); // Menangani error jika terjadi
  } finally {
    await connection.close(); // Menutup koneksi setelah selesai
  }
}
