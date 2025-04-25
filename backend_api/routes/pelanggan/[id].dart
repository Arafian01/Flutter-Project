import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final conn = await createConnection();
  final pid = int.parse(id);
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        // GET /pelanggan/:id
        final res = await conn.query('''
          SELECT pelanggans.id, users.name, users.email,
                 pakets.nama_paket, pelanggans.status,
                 pelanggans.alamat, pelanggans.telepon
          FROM pelanggans
          JOIN users ON pelanggans.user_id = users.id
          JOIN pakets ON pelanggans.paket_id = pakets.id
          WHERE pelanggans.id = @id
        ''', substitutionValues: {'id': pid});
        if (res.isEmpty) return Response(statusCode: 404);
        return Response.json(body: Pelanggan.fromRow(res.first).toJson());

      case HttpMethod.put:
        // PUT /pelanggan/:id
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        // update tanggal_aktif seperti logic
        String? tAktif;
        final status = jsonMap['status'] as String;
        if (status == 'aktif') {
          tAktif = DateTime.now().toIso8601String().split('T').first;
        }

        // update pelanggan
        await conn.query('''
          UPDATE pelanggans SET
            paket_id = @pid,
            alamat = @alamat,
            telepon = @telp,
            status = @status,
            tanggal_aktif = @taktif,
            tanggal_langganan = @tlang
          WHERE id = @id
        ''', substitutionValues: {
          'id': pid,
          'pid': jsonMap['paket_id'],
          'alamat': jsonMap['alamat'],
          'telp': jsonMap['telepon'],
          'status': status,
          'taktif': tAktif,
          'tlang': jsonMap['tanggal_langganan'],
        });

        // update user
        final pass = (jsonMap['password'] as String).isEmpty
            ? null
            : jsonMap['password'];
        await conn.query('''
          UPDATE users SET
            name = @name,
            email = @email,
            password = coalesce(@pass, password)
          WHERE id = (
            SELECT user_id FROM pelanggans WHERE id = @id
          )
        ''', substitutionValues: {
          'id': pid,
          'name': jsonMap['name'],
          'email': jsonMap['email'],
          'pass': pass,
        });

        return Response.json(body: {'message': 'Pelanggan updated'});

      case HttpMethod.delete:
        // DELETE /pelanggan/:id
        // hapus user dulu
        final userRes = await conn.query('SELECT user_id FROM pelanggans WHERE id = @id',
            substitutionValues: {'id': pid});
        if (userRes.isNotEmpty) {
          final uid = userRes.first[0] as int;
          await conn.query('DELETE FROM users WHERE id = @uid',
              substitutionValues: {'uid': uid});
        }
        await conn.query('DELETE FROM pelanggans WHERE id = @id',
            substitutionValues: {'id': pid});
        return Response.json(body: {'message': 'Pelanggan deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await conn.close();
  }
}
