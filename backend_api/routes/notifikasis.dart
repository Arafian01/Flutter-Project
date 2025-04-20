import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/notifikasi.dart';

Future<Response> onRequest(RequestContext context) async {
  await connect();
  final results = await connection.query('SELECT judul, pesan, created_at FROM notifikasis ORDER BY id DESC');
  await connection.close();

  final users = results.map((row) => {'judu l': row[0], 'pesan': row[1], 'dibuat': row[2]}).toList();
  return Response.json(body: users);
}
