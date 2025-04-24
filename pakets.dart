import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/paket.dart';

Future<Response> onRequest(RequestContext context) async {
  await connect();
  final results = await connection.query('SELECT nama_paket, harga, deskripsi FROM pakets');
  await connection.close();

  final users = results.map((row) => {'nama': row[0], 'harga': row[1], 'deskripsi': row[2]}).toList();
  return Response.json(body: users);
}
