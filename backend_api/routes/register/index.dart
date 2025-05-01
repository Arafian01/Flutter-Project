// File: routes/register/index.dart

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../lib/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;

  final name                  = data['name']?.toString().trim();
  final email                 = data['email']?.toString().trim();
  final password              = data['password']?.toString();
  final passwordConfirmation  = data['password_confirmation']?.toString();
  final paketId               = int.tryParse(data['paket_id']?.toString() ?? '');
  final alamat                = data['alamat']?.toString().trim();
  final telepon               = data['telepon']?.toString().trim();

  // validate required
  if ([name, email, password, passwordConfirmation, alamat, telepon].any((e) => e == null)
      || paketId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Semua field wajib diisi'});
  }
  if (password != passwordConfirmation) {
    return Response.json(statusCode: 400, body: {'error': 'Password dan konfirmasi harus sama'});
  }

  final conn = await createConnection();
  try {
    // run in transaction
    await conn.transaction((ctx) async {
      // hash password
      final hashed = BCrypt.hashpw(password!, BCrypt.gensalt());

      // insert user
      final userRes = await ctx.query(
        '''INSERT INTO users (name, email, password, role)
           VALUES (@name, @email, @pwd, 'pelanggan')
           RETURNING id;''',
        substitutionValues: {
          'name': name,
          'email': email,
          'pwd': hashed,
        },
      );
      final userId = userRes.first[0] as int;

      // insert pelanggan
      await ctx.query(
        '''INSERT INTO pelanggans
             (user_id, paket_id, alamat, telepon, status, tanggal_aktif, tanggal_langganan)
           VALUES
             (@uid, @pid, @alamat, @telepon, 'belum_verifikasi', NULL, CURRENT_DATE);''',
        substitutionValues: {
          'uid': userId,
          'pid': paketId,
          'alamat': alamat,
          'telepon': telepon,
        },
      );
    });

    return Response.json(statusCode: 201, body: {'message': 'Registrasi berhasil'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
