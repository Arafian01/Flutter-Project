// File: routes/tagihan/pelanggan/[id].dart

import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';
import '../../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  // Parse path‐parameter pelanggan_id
  final pelangganId = int.tryParse(id);
  if (pelangganId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid pelanggan id'},
    );
  }

  // Only GET is allowed
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed'},
    );
  }

  final conn = await createConnection();
  try {
    // Query semua tagihan milik pelanggan ini, urut dari ID terbesar (terbaru)
    final results = await conn.query(
      '''
      SELECT
        t.id,
        t.pelanggan_id,
        u.name AS pelanggan_name,
        t.bulan_tahun,
        t.status_pembayaran,
        t.jatuh_tempo,
        t.harga
      FROM tagihans t
      JOIN pelanggans p ON t.pelanggan_id = p.id
      JOIN users u       ON p.user_id      = u.id
      WHERE t.pelanggan_id = @pid
      ORDER BY t.id DESC;
      ''',
      substitutionValues: {'pid': pelangganId},
    );

    // Map setiap baris ke JSON lewat model Tagihan
    final list = results
        .map((row) => Tagihan.fromRow(row).toJson())
        .toList();

    return Response.json(body: list);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  } finally {
    await conn.close();
  }
}
