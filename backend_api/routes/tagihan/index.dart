import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final results = await connection.query('''
          SELECT t.id,
                 t.pelanggan_id,
                 u.name,
                 t.bulan,
                 t.tahun,
                 t.status_pembayaran,
                 t.jatuh_tempo,
                 t.harga
          FROM tagihans t
          JOIN pelanggans p ON t.pelanggan_id = p.id
          JOIN users u ON p.user_id = u.id
          ORDER BY t.id;
        ''');
        final list = results.map((r) => Tagihan.fromRow(r).toJson()).toList();
        return Response.json(body: list);

      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        final pid = jsonMap['pelanggan_id'] as int?;
        final bulan = jsonMap['bulan'] as int?;
        final tahun = jsonMap['tahun'] as int?;
        final status = jsonMap['status_pembayaran'] as String?;
        if (pid == null || bulan == null || tahun == null || status == null) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'Field pelanggan_id, bulan, tahun, dan status_pembayaran wajib diisi'},
          );
        }

        final dup = await connection.query(
          'SELECT 1 FROM tagihans WHERE pelanggan_id = @pid AND bulan = @bulan AND tahun = @tahun LIMIT 1',
          substitutionValues: {'pid': pid, 'bulan': bulan, 'tahun': tahun},
        );
        if (dup.isNotEmpty) {
          return Response.json(
            statusCode: 409,
            body: {'error': 'Tagihan untuk periode $bulan-$tahun sudah ada'},
          );
        }

        final nextMonth = bulan == 12 ? 1 : bulan + 1;
        final nextYear = bulan == 12 ? tahun + 1 : tahun;
        final jatuhTempo = DateTime(nextYear, nextMonth, 5).toIso8601String().split('T').first;

        final priceRes = await connection.query(
          'SELECT pk.harga FROM pelanggans pl JOIN pakets pk ON pl.paket_id = pk.id WHERE pl.id = @pid LIMIT 1',
          substitutionValues: {'pid': pid},
        );
        if (priceRes.isEmpty) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Pelanggan tidak ditemukan'},
          );
        }
        final harga = priceRes.first[0] as int;

        final result = await connection.query(
          'INSERT INTO tagihans (pelanggan_id, bulan, tahun, status_pembayaran, jatuh_tempo, harga) VALUES (@pid, @bulan, @tahun, @st, @jt, @hr) RETURNING id',
          substitutionValues: {
            'pid': pid,
            'bulan': bulan,
            'tahun': tahun,
            'st': status,
            'jt': jatuhTempo,
            'hr': harga,
          },
        );
        final newId = result.first[0] as int;
        return Response.json(
          statusCode: 201,
          body: {'message': 'Tagihan dibuat', 'id': newId},
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