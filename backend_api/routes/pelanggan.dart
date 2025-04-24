import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';

Future<Response> onRequest(RequestContext context) async {
  await connect();

  final results = await connection.query('''
    SELECT pelanggans.id, users.name, users.email, pakets.nama_paket, pelanggans.status, pelanggans.alamat, pelanggans.telepon
    FROM pelanggans
    JOIN users ON pelanggans.user_id = users.id
    JOIN pakets ON pelanggans.paket_id = pakets.id
  ''');

  await connection.close();

  final users = results.map((row) => {
    'id': row[0],
    'name': row[1],
    'email': row[2],
    'paket': row[3],
    'status': row[4],
    'alamat': row[5],
    'telepon': row[6],
  }).toList();

  return Response.json(body: users);
}
