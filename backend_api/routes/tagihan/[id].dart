// File: routes/tagihan/[id].dart
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final connection = await createConnection();
  final tagihanId = int.tryParse(id);
  if (tagihanId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid ID'});
  }

  try {
    switch (context.request.method) {
      // GET /tagihan/:id
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
          WHERE t.id = @id;
          ''',
          substitutionValues: {'id': tagihanId},
        );
        if (results.isEmpty) return Response(statusCode: 404);
        return Response.json(body: Tagihan.fromRow(results.first).toJson());

      // PUT /tagihan/:id
      case HttpMethod.put:
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

        // recompute jatuh_tempo from bulan_tahun
        final bulanTahun = jsonMap['bulan_tahun'] as String;
        final parts = bulanTahun.split('-');
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        final nextMonth = month == 12 ? 1 : month + 1;
        final nextYear = month == 12 ? year + 1 : year;
        final jatuhTempo = DateTime(nextYear, nextMonth, 5).toIso8601String().split('T')[0];

        await connection.query(
          '''
          UPDATE tagihans
          SET pelanggan_id      = @pelangganId,
              bulan_tahun       = @bulanTahun,
              status_pembayaran = @status,
              jatuh_tempo       = @jatuhTempo
          WHERE id = @id;
          ''',
          substitutionValues: {
            'id': tagihanId,
            'pelangganId': jsonMap['pelanggan_id'],
            'bulanTahun': bulanTahun,
            'status': status,
            'jatuhTempo': jatuhTempo,
          },
        );
        return Response.json(body: {'message': 'Tagihan updated'});

      // DELETE /tagihan/:id
      case HttpMethod.delete:
        await connection.query(
          'DELETE FROM tagihans WHERE id = @id;', substitutionValues: {'id': tagihanId},
        );
        return Response.json(body: {'message': 'Tagihan deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}
