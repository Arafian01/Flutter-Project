// routes/pembayaran/pelanggan/[id].dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';
import '../../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final pelangganId = int.tryParse(id);
  if (pelangganId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid pelanggan id'});
  }

  final conn = await createConnection();
  try {
    if (context.request.method == HttpMethod.get) {
      final rows = await conn.query('''
        SELECT
        pm.id,
        pm.tagihan_id,
        pm.image,
        pm.tanggal_kirim,
        pm.status_verifikasi,
        pm.tanggal_verifikasi,
        u.name            AS pelanggan_name,
        t.bulan_tahun,
        pk.harga
      FROM pembayarans pm
      JOIN tagihans t       ON pm.tagihan_id   = t.id
      JOIN pelanggans p     ON t.pelanggan_id  = p.id
      JOIN users u          ON p.user_id       = u.id
      JOIN pakets pk        ON p.paket_id      = pk.id
      ORDER BY pm.id;
      ''', substitutionValues: {'pid': pelangganId});

      return Response.json(
        body: rows.map((r) => Pembayaran.fromRow(r).toJson()).toList(),
      );
    }

    // pelanggan tidak boleh POST di sini—pakai /pembayaran untuk admin,
    // atau endpoint khusus untuk user jika memang diperlukan.

    return Response.json(statusCode: 405, body: {'error': 'Method Not Allowed'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
