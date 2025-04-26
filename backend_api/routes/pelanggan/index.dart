import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();

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
          '''
        );
        final pelanggans = results.map((row) => Pelanggan.fromRow(row).toJson()).toList();
        return Response.json(body: pelanggans);

      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final pelanggan = Pelanggan.fromJson(jsonMap);

        await connection.query(
          '''
          INSERT INTO pelanggans (user_id, paket_id, status, alamat, telepon, tanggal_aktif, tanggal_langganan)
          VALUES (@userId, @paketId, @status, @alamat, @telepon, @tanggalAktif, @tanggalLangganan)
          ''',
          substitutionValues: {
            'userId': pelanggan.userId,
            'paketId': pelanggan.paketId,
            'status': pelanggan.status,
            'alamat': pelanggan.alamat,
            'telepon': pelanggan.telepon,
            'tanggalAktif': pelanggan.tanggalAktif.toIso8601String(),
            'tanggalLangganan': pelanggan.tanggalLangganan.toIso8601String(),
          },
        );

        return Response.json(
          body: {'message': 'Pelanggan created', 'data': pelanggan.toJson()},
          statusCode: 201,
        );

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await connection.close();
  }
}
