// File: routes/pembayaran/[id].dart
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
          t.bulan_tahun,
          pm.image,
          pm.tanggal_kirim,
          pm.user_id AS admin_id,
          u_admin.name AS admin_name,
          pm.status_verifikasi,
          pm.tanggal_verifikasi,
          p.user_id AS pelanggan_user_id,
          u_pelanggan.name AS pelanggan_name
        FROM pembayarans pm
        JOIN tagihans t ON pm.tagihan_id = t.id
        JOIN pelanggans p ON t.pelanggan_id = p.id
        JOIN users u_pelanggan ON p.user_id = u_pelanggan.id
        LEFT JOIN users u_admin ON pm.user_id = u_admin.id
        WHERE pm.id = @id;
      ''', substitutionValues: {'id': pid});
      if (rows.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      return Response.json(body: Pembayaran.fromRow(rows.first).toJson());
    }

    if (context.request.method == HttpMethod.put) {
      // ambil existing record
      final rec = await conn.query(
        'SELECT image FROM pembayarans WHERE id = @id',
        substitutionValues: {'id': pid},
      );
      if (rec.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Not found'});
      final oldImage = rec.first[0] as String?;

      // parse multipart form-data
      final formData = await context.request.formData();
      final status = formData.fields['status_verifikasi'];
      final adminId = formData.fields['user_id'];
      if (status == null) return Response.json(statusCode: 400, body: {'error': 'Missing status_verifikasi'});

      if (adminId == null) {
        return Response.json(statusCode: 401, body: {'error': 'Unauthorized: missing user id in header'});
      }

      // tentukan tanggal verifikasi jika status final
      final tv = (status == 'diterima' || status == 'ditolak')
          ? DateTime.now().toIso8601String().split('T').first
          : null;

      // handle optional file upload
      String? imageName;
      final filePart = formData.files['image'];
      if (filePart != null) {
        if (oldImage != null) {
          final f = File('.$oldImage');
          if (await f.exists()) await f.delete();
        }
        final bytes = Uint8List.fromList(await filePart.readAsBytes());
        final ext = filePart.name.split('.').last;
        imageName = 'img_\${DateTime.now().millisecondsSinceEpoch}.\$ext';
        await Directory('uploads').create(recursive: true);
        await File('uploads/\$imageName').writeAsBytes(bytes);
      }

      // update pembayaran
      await conn.transaction((ctx) async {
        await ctx.query('''
          UPDATE pembayarans
          SET status_verifikasi = @st,
              tanggal_verifikasi = @tv,
              user_id           = @uid
              ${imageName != null ? ', image = @img' : ''}
          WHERE id = @id;
        ''', substitutionValues: {
          'st': status,
          'tv': tv,
          'uid': adminId,
          if (imageName != null) 'img': '/uploads/\$imageName',
          'id': pid,
        });

        // update status tagihan
        final newSt = status == 'diterima' ? 'lunas' : 'menunggu_verifikasi';
        await ctx.query(
          'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
          substitutionValues: {'s': newSt, 'tid': pid},
        );
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
      final tid2 = rec2.first[1] as int;

      await conn.transaction((ctx) async {
        await ctx.query('DELETE FROM pembayarans WHERE id = @id', substitutionValues: {'id': pid});
        if (oldImage2 != null) {
          final f2 = File('.$oldImage2');
          if (await f2.exists()) await f2.delete();
        }
        await ctx.query(
          "UPDATE tagihans SET status_pembayaran = 'belum_dibayar' WHERE id = @tid",
          substitutionValues: {'tid': tid2},
        );
      });

      return Response.json(body: {'message': 'Deleted'});
    }

    return Response(statusCode: 405);
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
