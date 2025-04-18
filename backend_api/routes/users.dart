import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/user.dart';

Future<Response> onRequest(RequestContext context) async {
  await connect();
  final results = await connection.query('SELECT id, name, email, role FROM users');
  await connection.close();

  final users = results.map((row) => {'id': row[0], 'name': row[1], 'email': row[2], 'role': row[3]}).toList();
  return Response.json(body: users);
}
