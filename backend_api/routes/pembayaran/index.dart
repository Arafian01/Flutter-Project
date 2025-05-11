// routes/pembayaran/index.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = await createConnection();
  try {
    switch (context.request.method) {
      case HttpMethod.get:
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
    ''');
        return Response.json(
          body: rows.map((r) => Pembayaran.fromRow(r).toJson()).toList(),
        );

      case HttpMethod.post:
        final form = await context.request.formData();
        final tidStr = form.fields['tagihan_id'];
        final st = form.fields['status_verifikasi'];
        final file = form.files['image'];

        if (tidStr == null || st == null || file == null) {
          return Response.json(
              statusCode: 400, body: {'error': 'Missing fields'});
        }
        final tid = int.tryParse(tidStr);
        if (tid == null) {
          return Response.json(
              statusCode: 400, body: {'error': 'Invalid tagihan_id'});
        }

        // Cek duplikasi
        final dup = await conn.query(
          'SELECT 1 FROM pembayarans WHERE tagihan_id = @tid LIMIT 1',
          substitutionValues: {'tid': tid},
        );
        if (dup.isNotEmpty) {
          return Response.json(
              statusCode: 409,
              body: {'error': 'Pembayaran untuk tagihan ini sudah ada'});
        }

        // Ambil harga & nama pelanggan
        final rel = await conn.query('''
          SELECT u.name AS pelanggan_name, pk.harga,
                t.bulan_tahun
          FROM tagihans t
          JOIN pelanggans pl ON t.pelanggan_id = pl.id
          JOIN users u       ON pl.user_id     = u.id
          JOIN pakets pk     ON pl.paket_id    = pk.id
          WHERE t.id = @tid;
        ''', substitutionValues: {'tid': tid});
        if (rel.isEmpty) {
          return Response.json(
              statusCode: 404, body: {'error': 'Tagihan tidak ditemukan'});
        }
        final pelangganName = rel.first[0] as String;
        final harga = rel.first[1] as int;

        // Simpan gambar
        final bytes = await file.readAsBytes();
        final ext = file.name.split('.').last;
        final img = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        await Directory('uploads').create(recursive: true);
        await File('uploads/$img').writeAsBytes(bytes);

        // Tanggal verifikasi
        final tv = (st == 'diterima' || st == 'ditolak')
            ? DateTime.now().toIso8601String().split('T')[0]
            : null;

        final result = await conn.query('''
          INSERT INTO pembayarans
            (tagihan_id, image,
             tanggal_kirim, status_verifikasi, tanggal_verifikasi)
          VALUES
            (@tid, @img,
             CURRENT_DATE, @st, @tv)
          RETURNING id;
        ''', substitutionValues: {
          'tid': tid,
          'img': '/uploads/$img',
          'st': st,
          'tv': tv,
        });
        final newId = result.first[0] as int;

        // Update status tagihan
        final newSt = (st == 'diterima') ? 'lunas' : 'menunggu_verifikasi';
        await conn.query(
          'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
          substitutionValues: {'s': newSt, 'tid': tid},
        );

        return Response.json(statusCode: 201, body: {'id': newId});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
