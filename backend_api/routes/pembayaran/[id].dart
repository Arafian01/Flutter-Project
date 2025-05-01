// File: routes/pembayaran/[id].dart
import 'dart:io';
import 'dart:convert';
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
        SELECT pm.id, pm.tagihan_id, t.bulan_tahun, pm.image, pm.tanggal_kirim,
               pm.user_id, u.name, pm.status_verifikasi, pm.tanggal_verifikasi
        FROM pembayarans pm
        JOIN tagihans t ON pm.tagihan_id = t.id
        JOIN pelanggans p ON t.pelanggan_id = p.id
        JOIN users u ON p.user_id = u.id
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

      final formData = await context.request.formData();
      final status = formData.fields['status_verifikasi'];
      if (status == null) return Response.json(statusCode: 400, body: {'error': 'Missing status'});
      final tv = (status == 'diterima' || status == 'ditolak')
          ? DateTime.now().toIso8601String().split('T').first
          : null;

      String? imageName;
      final filePart = formData.files['image'];
      if (filePart != null) {
        // delete old
        if (oldImage != null) {
          final f = File('.$oldImage');
          if (await f.exists()) await f.delete();
        }
        final bytes = Uint8List.fromList(await filePart.readAsBytes());
        final ext = filePart.name.split('.').last;
        imageName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        await Directory('uploads').create(recursive: true);
        await File('uploads/$imageName').writeAsBytes(bytes);
      }

      await conn.query('''
        UPDATE pembayarans
        SET status_verifikasi = @st,
            tanggal_verifikasi = @tv
            ${imageName != null ? ', image = @img' : ''}
        WHERE id = @id;
      ''', substitutionValues: {
        'st': status,
        'tv': tv,
        if (imageName != null) 'img': '/uploads/$imageName',
        'id': pid,
      });

      final tid = (await conn.query(
        'SELECT tagihan_id FROM pembayarans WHERE id = @id',
        substitutionValues: {'id': pid},
      )).first[0] as int;
      final newSt = status == 'diterima' ? 'lunas' : 'menunggu_verifikasi';
      await conn.query(
        'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
        substitutionValues: {'s': newSt, 'tid': tid},
      );

      return Response.json(body: {'message': 'Updated'});
    }

    if (context.request.method == HttpMethod.delete) {
      final rec = await conn.query(
        'SELECT image, tagihan_id FROM pembayarans WHERE id = @id',
        substitutionValues: {'id': pid},
      );
      if (rec.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      final oldImage = rec.first[0] as String?;
      final tid2 = rec.first[1] as int;

      await conn.query('DELETE FROM pembayarans WHERE id = @id', substitutionValues: {'id': pid});
      if (oldImage != null) {
        final f = File('.$oldImage');
        if (await f.exists()) await f.delete();
      }
      await conn.query(
        "UPDATE tagihans SET status_pembayaran='belum_dibayar' WHERE id=@tid",
        substitutionValues: {'tid': tid2},
      );
      return Response.json(body: {'message': 'Deleted'});
    }

    return Response(statusCode: 405);
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}