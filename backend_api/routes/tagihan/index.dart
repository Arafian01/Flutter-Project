// routes/tagihan/index.dart
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();
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
          ORDER BY t.id;
          ''',
        );
        final list = results.map((row) => Tagihan.fromRow(row).toJson()).toList();
        return Response.json(body: list);

      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        const allowed = ['belum_dibayar', 'menunggu_verifikasi', 'lunas'];
        final status = jsonMap['status_pembayaran'] as String;
        if (!allowed.contains(status)) {
          return Response.json(statusCode: 400, body: {'error': 'Invalid status_pembayaran'});
        }

        // hitung jatuh_tempo: tanggal 5 bulan berikutnya
        final bulanTahun = jsonMap['bulan_tahun'] as String; // format "MM-YYYY"
        final parts = bulanTahun.split('-');
        final m = int.parse(parts[0]), y = int.parse(parts[1]);
        final nm = m == 12 ? 1 : m + 1;
        final ny = m == 12 ? y + 1 : y;
        final jatuhTempo = DateTime(ny, nm, 5).toIso8601String().split('T')[0];

        final result = await connection.query(
          '''
          INSERT INTO tagihans
            (pelanggan_id, bulan_tahun, status_pembayaran, jatuh_tempo, harga)
          VALUES
            (@pid, @bt, @st, @jt,
             (SELECT pk.harga
                FROM pelanggans pl
                JOIN pakets pk ON pl.paket_id = pk.id
               WHERE pl.id = @pid)
            )
          RETURNING id;
          ''',
          substitutionValues: {
            'pid': jsonMap['pelanggan_id'],
            'bt': bulanTahun,
            'st': status,
            'jt': jatuhTempo,
          },
        );
        final newId = result.first[0] as int;
        return Response.json(statusCode: 201, body: {'message': 'Tagihan created', 'id': newId});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}
