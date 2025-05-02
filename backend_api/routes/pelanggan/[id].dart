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

      case HttpMethod.put:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        // Update users table
        // Always update name & email
        await connection.query(
          '''
          UPDATE users
          SET name  = @name,
              email = @email
          WHERE id = @userId;
          ''',
          substitutionValues: {
            'userId': jsonMap['user_id'],
            'name': jsonMap['name'],
            'email': jsonMap['email'],
          },
        );

        // Only update password if provided and non-empty
        final newPassword = jsonMap['password'] as String?;
        if (newPassword != null && newPassword.isNotEmpty) {
          await connection.query(
            '''
            UPDATE users
            SET password = crypt(@password, gen_salt('bf'))
            WHERE id = @userId;
            ''',
            substitutionValues: {
              'userId': jsonMap['user_id'],
              'password': newPassword,
            },
          );
        }

        // Determine tanggal_aktif
        final status = jsonMap['status'] as String;
        final tanggalAktifValue = (status == 'aktif')
            ? DateTime.now().toIso8601String()
            : null;

        // Update pelanggans table
        await connection.query(
          '''
          UPDATE pelanggans
          SET paket_id          = @paketId,
              status            = @status,
              alamat            = @alamat,
              telepon           = @telepon,
              tanggal_aktif     = @tanggalAktif,
              tanggal_langganan = @tanggalLangganan
          WHERE id = @id;
          ''',
          substitutionValues: {
            'id': pelangganId,
            'paketId': jsonMap['paket_id'],
            'status': status,
            'alamat': jsonMap['alamat'],
            'telepon': jsonMap['telepon'],
            'tanggalAktif': tanggalAktifValue,
            'tanggalLangganan': jsonMap['tanggal_langganan'],
          },
        );

        return Response.json(body: {'message': 'Pelanggan updated'});

      case HttpMethod.delete:
        final res = await connection.query(
          'SELECT user_id FROM pelanggans WHERE id = @id;', 
          substitutionValues: {'id': pelangganId},
        );
        if (res.isEmpty) return Response(statusCode: 404);
        final userId = res.first[0] as int;

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