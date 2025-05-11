// routes/tagihan/index.dart

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
        final results = await connection.query('''
          SELECT t.id,
                 t.pelanggan_id,
                 u.name,
                 t.bulan_tahun,
                 t.status_pembayaran,
                 t.jatuh_tempo,
                 t.harga
          FROM tagihans t
          JOIN pelanggans p ON t.pelanggan_id = p.id
          JOIN users u      ON p.user_id     = u.id
          ORDER BY t.id;
        ''');
        final list = results.map((r) => Tagihan.fromRow(r).toJson()).toList();
        return Response.json(body: list);

      // POST /tagihan — create new tagihan, with duplicate check
      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        final pid = jsonMap['pelanggan_id'] as int?;
        final bt  = jsonMap['bulan_tahun'] as String?;
        final status = jsonMap['status_pembayaran'] as String?;
        if (pid == null || bt == null || status == null) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'Field pelanggan_id, bulan_tahun, dan status_pembayaran wajib diisi'},
          );
        }

        // cek duplikasi
        final dup = await connection.query('''
          SELECT 1 FROM tagihans 
           WHERE pelanggan_id = @pid AND bulan_tahun = @bt
          LIMIT 1;
        ''', substitutionValues: {'pid': pid, 'bt': bt});
        if (dup.isNotEmpty) {
          return Response.json(
            statusCode: 409,
            body: {'error': 'Tagihan untuk periode $bt sudah ada'},
          );
        }

        // hitung jatuh_tempo otomatis tanggal 5 bulan berikutnya
        final parts = bt.split('-');
        final month = int.parse(parts[0]);
        final year  = int.parse(parts[1]);
        final nextMonth = month == 12 ? 1 : month + 1;
        final nextYear  = month == 12 ? year + 1 : year;
        final jatuhTempo = DateTime(nextYear, nextMonth, 5).toIso8601String().split('T').first;

        // ambil harga dari paket pelanggan
        final priceRes = await connection.query('''
          SELECT pk.harga
            FROM pelanggans pl
            JOIN pakets pk ON pl.paket_id = pk.id
           WHERE pl.id = @pid
           LIMIT 1;
        ''', substitutionValues: {'pid': pid});
        if (priceRes.isEmpty) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Pelanggan tidak ditemukan'},
          );
        }
        final harga = priceRes.first[0] as int;

        // insert
        final result = await connection.query('''
          INSERT INTO tagihans
            (pelanggan_id, bulan_tahun, status_pembayaran, jatuh_tempo, harga)
          VALUES
            (@pid, @bt, @st, @jt, @hr)
          RETURNING id;
        ''', substitutionValues: {
          'pid': pid,
          'bt': bt,
          'st': status,
          'jt': jatuhTempo,
          'hr': harga,
        });
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
