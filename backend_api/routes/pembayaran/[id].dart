// routes/pembayaran/[id].dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final pid = int.tryParse(id);
  if (pid == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid ID'});
  }
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
        ''', substitutionValues: {'id': pid});
        if (rows.isEmpty) {
          return Response.json(statusCode: 404, body: {'error': 'Not found'});
        }
        return Response.json(body: Pembayaran.fromRow(rows.first).toJson());

      case HttpMethod.put:
        final rec = await conn.query(
          'SELECT image FROM pembayarans WHERE id = @id',
          substitutionValues: {'id': pid},
        );
        if (rec.isEmpty) {
          return Response.json(statusCode: 404, body: {'error': 'Not found'});
        }
        final oldImg = rec.first[0] as String?;

        final form = await context.request.formData();
        final st = form.fields['status_verifikasi'];
        if (st == null) {
          return Response.json(
              statusCode: 400, body: {'error': 'Missing status_verifikasi'});
        }
        final tv = (st == 'diterima' || st == 'ditolak')
            ? DateTime.now().toIso8601String().split('T')[0]
            : null;

        String? newImg;
        final filePart = form.files['image'];
        if (filePart != null) {
          if (oldImg != null) {
            final f = File('.$oldImg');
            if (await f.exists()) await f.delete();
          }
          final bts = await filePart.readAsBytes();
          final ext = filePart.name.split('.').last;
          newImg = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
          await Directory('uploads').create(recursive: true);
          await File('uploads/$newImg').writeAsBytes(bts);
        }

        await conn.transaction((ctx) async {
          await ctx.query('''
            UPDATE pembayarans
            SET status_verifikasi = @st,
                tanggal_verifikasi = @tv
                ${newImg != null ? ', image = @img' : ''}
            WHERE id = @id;
          ''', substitutionValues: {
            'st': st,
            'tv': tv,
            if (newImg != null) 'img': '/uploads/$newImg',
            'id': pid,
          });

          // perbarui status tagihan
          final tid = (await ctx.query(
            'SELECT tagihan_id FROM pembayarans WHERE id = @id',
            substitutionValues: {'id': pid},
          ))
              .first[0] as int;
          final newSt = (st == 'diterima') ? 'lunas' : 'menunggu_verifikasi';
          await ctx.query(
            'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
            substitutionValues: {'s': newSt, 'tid': tid},
          );
        });

        return Response.json(body: {'message': 'Updated'});

      case HttpMethod.delete:
        final rec2 = await conn.query(
          'SELECT image, tagihan_id FROM pembayarans WHERE id = @id',
          substitutionValues: {'id': pid},
        );
        if (rec2.isEmpty) {
          return Response.json(statusCode: 404, body: {'error': 'Not found'});
        }
        final old2 = rec2.first[0] as String?;
        final tid2 = rec2.first[1] as int;
        await conn.transaction((ctx) async {
          await ctx.query('DELETE FROM pembayarans WHERE id = @id',
              substitutionValues: {'id': pid});
          if (old2 != null) {
            final f2 = File('.$old2');
            if (await f2.exists()) await f2.delete();
          }
          await ctx.query(
            "UPDATE tagihans SET status_pembayaran='belum_dibayar' WHERE id=@tid",
            substitutionValues: {'tid': tid2},
          );
        });
        return Response.json(body: {'message': 'Deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
