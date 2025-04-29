import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final connection = await createConnection();
  final pelangganId = int.tryParse(id);
  if (pelangganId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid ID'});
  }

  try {
    switch (context.request.method) {
      // GET /pelanggan/:id
      case HttpMethod.get:
        final results = await connection.query(
          '''
          SELECT p.id, p.user_id, p.paket_id,
                 u.name, u.email,
                 pk.nama_paket, p.status,
                 p.alamat, p.telepon,
                 p.tanggal_aktif, p.tanggal_langganan
          FROM pelanggans p
          JOIN users u ON p.user_id = u.id
          JOIN pakets pk ON p.paket_id = pk.id
          WHERE p.id = @id;
          ''',
          substitutionValues: {'id': pelangganId},
        );
        if (results.isEmpty) return Response(statusCode: 404);
        return Response.json(body: Pelanggan.fromRow(results.first).toJson());

      // PUT /pelanggan/:id
      case HttpMethod.put:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final updated = Pelanggan.fromJson(jsonMap);

        // update users table
        await connection.query(
          '''
          UPDATE users
          SET name     = @name,
              email    = @email,
              password = crypt(@password, gen_salt('bf'))
          WHERE id = @userId;
          ''',
          substitutionValues: {
            'userId': updated.userId,
            'name': updated.name,
            'email': updated.email,
            'password': jsonMap['password'],
          },
        );

        // determine tanggal_aktif
        final tanggalAktifValue = (updated.status == 'aktif')
            ? DateTime.now().toIso8601String()
            : null;

        // update pelanggans table
        await connection.query(
          '''
          UPDATE pelanggans
          SET paket_id           = @paketId,
              status             = @status,
              alamat             = @alamat,
              telepon            = @telepon,
              tanggal_aktif      = @tanggalAktif,
              tanggal_langganan  = @tanggalLangganan
          WHERE id = @id;
          ''',
          substitutionValues: {
            'id': updated.id,
            'paketId': updated.paketId,
            'status': updated.status,
            'alamat': updated.alamat,
            'telepon': updated.telepon,
            'tanggalAktif': tanggalAktifValue,
            'tanggalLangganan': updated.tanggalLangganan.toIso8601String(),
          },
        );

        return Response.json(body: {'message': 'Pelanggan updated'});

      // DELETE /pelanggan/:id
      case HttpMethod.delete:
        // fetch the associated user_id
        final res = await connection.query(
          'SELECT user_id FROM pelanggans WHERE id = @id;',
          substitutionValues: {'id': pelangganId},
        );
        if (res.isEmpty) return Response(statusCode: 404);
        final userId = res.first[0] as int;

        // delete pelanggan then user
        await connection.query(
          'DELETE FROM pelanggans WHERE id = @id;',
          substitutionValues: {'id': pelangganId},
        );
        await connection.query(
          'DELETE FROM users WHERE id = @userId;',
          substitutionValues: {'userId': userId},
        );

        return Response.json(body: {'message': 'Pelanggan & User deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}
