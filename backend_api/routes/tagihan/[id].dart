// routes/tagihan/[id].dart
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final connection = await createConnection();
  final tid = int.tryParse(id);
  if (tid == null) return Response.json(statusCode: 400, body: {'error': 'Invalid ID'});

  try {
    switch (context.request.method) {
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
          substitutionValues: {'id': tid},
        );
        if (results.isEmpty) return Response(statusCode: 404);
        return Response.json(body: Tagihan.fromRow(results.first).toJson());

      case HttpMethod.put:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        const allowed = ['belum_dibayar', 'menunggu_verifikasi', 'lunas'];
        final status = jsonMap['status_pembayaran'] as String;
        if (!allowed.contains(status)) {
          return Response.json(statusCode: 400, body: {'error': 'Invalid status_pembayaran'});
        }

        // recompute jatuh_tempo
        final bulanTahun = jsonMap['bulan_tahun'] as String;
        final parts = bulanTahun.split('-');
        final m = int.parse(parts[0]), y = int.parse(parts[1]);
        final nm = m == 12 ? 1 : m + 1;
        final ny = m == 12 ? y + 1 : y;
        final jatuhTempo = DateTime(ny, nm, 5).toIso8601String().split('T')[0];

        await connection.query(
          '''
          UPDATE tagihans
          SET pelanggan_id      = @pid,
              bulan_tahun       = @bt,
              status_pembayaran = @st,
              jatuh_tempo       = @jt,
              harga             = (
                SELECT pk.harga
                  FROM pelanggans pl
                  JOIN pakets pk ON pl.paket_id = pk.id
                 WHERE pl.id = @pid
              )
          WHERE id = @id;
          ''',
          substitutionValues: {
            'id': tid,
            'pid': jsonMap['pelanggan_id'],
            'bt': bulanTahun,
            'st': status,
            'jt': jatuhTempo,
          },
        );
        return Response.json(body: {'message': 'Tagihan updated'});

      case HttpMethod.delete:
        await connection.query(
          'DELETE FROM tagihans WHERE id = @id;', substitutionValues: {'id': tid});
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
