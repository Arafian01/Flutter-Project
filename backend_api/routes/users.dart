import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/user.dart';

Future<Response> onRequest(RequestContext context) async {
  await connect();
  final results = await connection.query('SELECT users.name, pakets.nama_paket, pelanggans.status FROM pelanggans JOIN users ON pelanggans.user_id = users.id JOIN pakets ON pelanggans.paket_id = pakets.id');
  await connection.close();

  final users = results.map((row) => {'nama': row[0], 'paket': row[1], 'status': row[2]}).toList();
  return Response.json(body: users);
}
