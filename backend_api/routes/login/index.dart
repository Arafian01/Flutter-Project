import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../lib/database.dart';
import '../../lib/models/user.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(statusCode: 405, body: {'error': 'Method Not Allowed'});
  }

  try {
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final email = data['email']?.toString().trim();
    final password = data['password']?.toString();

    if (email == null || password == null) {
      return Response.json(statusCode: 400, body: {
        'error': 'Email dan password wajib diisi',
      });
    }

    final conn = await createConnection();

    try {
      final result = await conn.query(
        'SELECT id, name, email, password, role FROM users WHERE email = @e',
        substitutionValues: {'e': email},
      );

      if (result.isEmpty) {
        return Response.json(statusCode: 401, body: {'error': 'Email tidak ditemukan'});
      }

      final row = result.first;
      final user = User.fromRow(row);

      // Bandingkan password input dengan hash dari database
      final isValid = BCrypt.checkpw(password, user.password);

      if (!isValid) {
        return Response.json(statusCode: 401, body: {'error': 'Password salah'});
      }

      return Response.json(body: {
        'message': 'Login berhasil',
        'user': user.toJson(),
      });
    } finally {
      await conn.close();
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Terjadi kesalahan: $e'});
  }
}
