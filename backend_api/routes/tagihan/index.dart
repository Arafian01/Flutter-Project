// File: routes/tagihan/index.dart
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();
  try {
    switch (context.request.method) {
      // GET /tagihan — list all tagihans
      case HttpMethod.get:
        final results = await connection.query(
          '''
          SELECT t.id,
                 t.pelanggan_id,
                 u.name AS pelanggan_name,
                 t.bulan_tahun,
                 t.status_pembayaran,
                 t.jatuh_tempo,
                 pk.harga
          FROM tagihans t
          JOIN pelanggans p ON t.pelanggan_id = p.id
          JOIN users u      ON p.user_id     = u.id
          JOIN pakets pk    ON p.paket_id     = pk.id
          ORDER BY t.id;
          ''',
        );
        final list = results.map((row) => Tagihan.fromRow(row).toJson()).toList();
        return Response.json(body: list);

      // POST /tagihan — create new tagihan
      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        const allowed = ['belum_dibayar', 'menunggu_verifikasi', 'lunas'];
        final status = jsonMap['status_pembayaran'] as String;
        if (!allowed.contains(status)) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'Invalid status_pembayaran'},
          );
        }

        // derive jatuh_tempo: 5th of next month
        final bulanTahun = jsonMap['bulan_tahun'] as String; // e.g. "06-2025"
        final parts = bulanTahun.split('-');
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        final nextMonth = month == 12 ? 1 : month + 1;
        final nextYear = month == 12 ? year + 1 : year;
        final jatuhTempo = DateTime(nextYear, nextMonth, 5).toIso8601String().split('T')[0];

        final result = await connection.query(
          '''
          INSERT INTO tagihans
            (pelanggan_id, bulan_tahun, status_pembayaran, jatuh_tempo)
          VALUES
            (@pelangganId, @bulanTahun, @status, @jatuhTempo)
          RETURNING id;
          ''',
          substitutionValues: {
            'pelangganId': jsonMap['pelanggan_id'],
            'bulanTahun': bulanTahun,
            'status': status,
            'jatuhTempo': jatuhTempo,
          },
        );
        final newId = result.first[0] as int;
        return Response.json(
          statusCode: 201,
          body: {'message': 'Tagihan created', 'id': newId},
        );

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}