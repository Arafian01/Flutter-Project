// File: routes/pembayaran/index.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    final conn = await createConnection();
    try {
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
        ORDER BY pm.id;
      ''');
      final list = rows.map((r) => Pembayaran.fromRow(r).toJson()).toList();
      return Response.json(body: list);
    } finally {
      await conn.close();
    }
  }

  if (context.request.method == HttpMethod.post) {
    final formData = await context.request.formData();
    final tagihanId = int.tryParse(formData.fields['tagihan_id'] ?? '');
    final status = formData.fields['status_verifikasi'];
    if (tagihanId == null || status == null) {
      return Response.json(statusCode: 400, body: {'error': 'Missing fields'});
    }

    final filePart = formData.files['image'];
    if (filePart == null) {
      return Response.json(statusCode: 400, body: {'error': 'Image required'});
    }

    final bytes = await filePart.readAsBytes();
    final ext = filePart.name.split('.').last;
    final imageName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await Directory('uploads').create(recursive: true);
    await File('uploads/$imageName').writeAsBytes(bytes);

    final tv = (status == 'diterima' || status == 'ditolak')
        ? DateTime.now().toIso8601String().split('T').first
        : null;

    final conn = await createConnection();
    try {
      // On creation, admin (user_id) is null
      final result = await conn.query('''
        INSERT INTO pembayarans
          (tagihan_id, image, tanggal_kirim, status_verifikasi, tanggal_verifikasi)
        VALUES
          (@tid, @img, CURRENT_DATE, @st, @tv)
        RETURNING id;
      ''', substitutionValues: {
        'tid': tagihanId,
        'img': '/uploads/$imageName',
        'st': status,
        'tv': tv,
      });
      final newId = result.first[0] as int;

      String newSt;
      if (status == 'diterima') newSt = 'lunas';
      else if (status == 'ditolak') newSt = 'belum_dibayar';
      else newSt = 'menunggu verifikasi';

      await conn.query(
        'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
        substitutionValues: {'s': newSt, 'tid': tagihanId},
      );

      return Response.json(statusCode: 201, body: {'id': newId});
    } finally {
      await conn.close();
    }
  }

  return Response(statusCode: 405);
}
