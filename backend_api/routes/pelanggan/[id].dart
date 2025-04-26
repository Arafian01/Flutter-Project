import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final connection = await createConnection();
  final pelangganId = int.parse(id);

  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final results = await connection.query(
          '''
          SELECT pelanggans.id, pelanggans.user_id, pelanggans.paket_id,
                 users.name, users.email,
                 pakets.nama_paket, pelanggans.status,
                 pelanggans.alamat, pelanggans.telepon,
                 pelanggans.tanggal_aktif, pelanggans.tanggal_langganan
          FROM pelanggans
          JOIN users ON pelanggans.user_id = users.id
          JOIN pakets ON pelanggans.paket_id = pakets.id
          WHERE pelanggans.id = @id
          ''',
          substitutionValues: {'id': pelangganId},
        );
        if (results.isEmpty) return Response(statusCode: 404);
        return Response.json(
          body: Pelanggan.fromRow(results.first).toJson(),
        );

      case HttpMethod.put:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final updated = Pelanggan.fromJson(jsonMap);

        await connection.query(
          '''
          UPDATE pelanggans
          SET user_id = @userId, paket_id = @paketId,
              status = @status, alamat = @alamat, telepon = @telepon,
              tanggal_aktif = @tanggalAktif, tanggal_langganan = @tanggalLangganan
          WHERE id = @id
          ''',
          substitutionValues: {
            'id': pelangganId,
            'userId': updated.userId,
            'paketId': updated.paketId,
            'status': updated.status,
            'alamat': updated.alamat,
            'telepon': updated.telepon,
            'tanggalAktif': updated.tanggalAktif.toIso8601String(),
            'tanggalLangganan': updated.tanggalLangganan.toIso8601String(),
          },
        );
        return Response.json(body: {'message': 'Pelanggan updated'});

      case HttpMethod.delete:
        await connection.query(
          'DELETE FROM pelanggans WHERE id = @id',
          substitutionValues: {'id': pelangganId},
        );
        return Response.json(body: {'message': 'Pelanggan deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await connection.close();
  }
}
