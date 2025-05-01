import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import '../../lib/database.dart'; // Pastikan path ini sesuai
import '../../lib/models/user.dart'; // Pastikan path ini sesuai

Future<Response> onRequest(RequestContext context) async {
  // Hanya terima POST
  if (context.request.method != HttpMethod.post) {
    return Response.json(statusCode: 405, body: {
      'error': 'Method Not Allowed',
    });
  }

  try {
    final body = await context.request.body();
    final data = jsonDecode(body);

    final email = data['email']?.toString().trim();
    final password = data['password']?.toString();

    if (email == null || password == null) {
      return Response.json(statusCode: 400, body: {
        'error': 'Email dan password wajib diisi',
      });
    }

    final conn = await createConnection();

    // Gunakan parameter untuk keamanan
    final result = await conn.query(
      'SELECT id, name, email, password, role FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isEmpty) {
      return Response.json(statusCode: 401, body: {
        'error': 'Email tidak ditemukan',
      });
    }

    final row = result.first;
    final user = User.fromRow(row);

    // Bandingkan password biasa (plaintext) — GUNAKAN hash di produksi!
    if (user.password != password) {
      return Response.json(statusCode: 401, body: {
        'error': 'Password salah',
      });
    }

    // Sukses, kembalikan data user tanpa password
    return Response.json(body: {
      'message': 'Login berhasil',
      'user': user.toJson(),
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {
      'error': 'Terjadi kesalahan: $e',
    });
  }
}
