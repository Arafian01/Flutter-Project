import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final pid = int.tryParse(id);
  if (pid == null) return Response.json(statusCode: 400, body: {'error': 'Invalid ID'});

  final conn = await createConnection();
  try {
    if (context.request.method == HttpMethod.get) {
      final rows = await conn.query('''
        SELECT
          pm.id,
          pm.tagihan_id,
          pm.bulan_tahun,
          pm.pelanggan_id,
          pm.image,
          pm.tanggal_kirim,
          pm.status_verifikasi,
          pm.tanggal_verifikasi,
          pm.harga
        FROM pembayarans pm
        WHERE pm.id = @id;
      ''', substitutionValues: {'id': pid});
      if (rows.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      return Response.json(body: Pembayaran.fromRow(rows.first).toJson());
    }

    if (context.request.method == HttpMethod.put) {
      final rec = await conn.query(
        'SELECT image FROM pembayarans WHERE id = @id',
        substitutionValues: {'id': pid},
      );
      if (rec.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      final oldImage = rec.first[0] as String?;

      final form = await context.request.formData();
      final st = form.fields['status_verifikasi'];
      if (st == null) return Response.json(statusCode: 400, body: {'error': 'Missing status_verifikasi'});

      // tanggals
      final tv = (st == 'diterima' || st == 'ditolak')
          ? DateTime.now().toIso8601String().split('T')[0]
          : null;

      String? imgName;
      final filePart = form.files['image'];
      if (filePart != null) {
        if (oldImage != null) {
          final f = File('.$oldImage');
          if (await f.exists()) await f.delete();
        }
        final bytes = await filePart.readAsBytes();
        final ext = filePart.name.split('.').last;
        imgName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        await Directory('uploads').create(recursive: true);
        await File('uploads/$imgName').writeAsBytes(bytes);
      }

      await conn.transaction((ctx) async {
        await ctx.query('''
          UPDATE pembayarans
          SET status_verifikasi = @st,
              tanggal_verifikasi = @tv
              ${imgName != null ? ', image = @img' : ''}
          WHERE id = @id;
        ''', substitutionValues: {
          'st': st,
          'tv': tv,
          if (imgName != null) 'img': '/uploads/$imgName',
          'id': pid,
        });

        // jika terhubung ke tagihan, update status_pembayaran
        final tagRes = await ctx.query(
          'SELECT tagihan_id FROM pembayarans WHERE id = @id',
          substitutionValues: {'id': pid},
        );
        final tid = tagRes.first[0] as int?;
        if (tid != null) {
          final newSt = st == 'diterima' ? 'lunas' : 'menunggu_verifikasi';
          await ctx.query(
            'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
            substitutionValues: {'s': newSt, 'tid': tid},
          );
        }
      });

      return Response.json(body: {'message': 'Updated'});
    }

    if (context.request.method == HttpMethod.delete) {
      final rec2 = await conn.query(
        'SELECT image, tagihan_id FROM pembayarans WHERE id = @id',
        substitutionValues: {'id': pid},
      );
      if (rec2.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      final oldImage2 = rec2.first[0] as String?;
      final tid2      = rec2.first[1] as int?;

      await conn.transaction((ctx) async {
        await ctx.query('DELETE FROM pembayarans WHERE id = @id', substitutionValues: {'id': pid});
        if (oldImage2 != null) {
          final f2 = File('.$oldImage2');
          if (await f2.exists()) await f2.delete();
        }
        if (tid2 != null) {
          await ctx.query(
            "UPDATE tagihans SET status_pembayaran='belum_dibayar' WHERE id=@tid",
            substitutionValues: {'tid': tid2},
          );
        }
      });

      return Response.json(body: {'message': 'Deleted'});
    }

    return Response(statusCode: 405);
  } finally {
    await conn.close();
  }
}
