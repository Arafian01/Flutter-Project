// File: routes/pembayaran/index.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post &&
      context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

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
ORDER BY pm.id;
''');
      final list = rows.map((r) => Pembayaran.fromRow(r).toJson()).toList();
      return Response.json(body: list);
    } // POST
    final formData = await context.request.formData();
    final tagihanId = int.tryParse(formData.fields['tagihan_id'] ?? '');
    final userId = int.tryParse(formData.fields['user_id'] ?? '');
    final status = formData.fields['status_verifikasi'];
    if (tagihanId == null || userId == null || status == null) {
      return Response.json(statusCode: 400, body: {'error': 'Missing fields'});
    }

    final filePart = formData.files['image'];
    if (filePart == null) {
      return Response.json(statusCode: 400, body: {'error': 'Image required'});
    }

    final bytes = await filePart.readAsBytes(); // List<int>
    final Uint8List ubytes = Uint8List.fromList(bytes);

    final ext = filePart.name.split('.').last;
    final imageName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final uploadDir = Directory('uploads');
    await uploadDir.create(recursive: true);
    await File('uploads/$imageName').writeAsBytes(ubytes);


    final tv = (status == 'diterima' || status == 'ditolak')
        ? DateTime.now().toIso8601String().split('T').first
        : null;

    final result = await conn.query('''
  INSERT INTO pembayarans
    (tagihan_id, image, tanggal_kirim, user_id, status_verifikasi, tanggal_verifikasi)
  VALUES
    (@tid, @img, CURRENT_DATE, @uid, @st, @tv)
  RETURNING id;
''', substitutionValues: {
      'tid': tagihanId,
      'img': '/uploads/$imageName',
      'uid': userId,
      'st': status,
      'tv': tv,
    });
    final newId = result.first[0] as int;

// update tagihan
    String newSt = status == 'diterima'
        ? 'lunas'
        : (status == 'ditolak' ? 'belum_dibayar' : 'menunggu_verifikasi');
    await conn.query('UPDATE tagihans SET status_pembayaran=@s WHERE id=@tid',
        substitutionValues: {
          's': newSt,
          'tid': tagihanId,
        });

    return Response.json(statusCode: 201, body: {'id': newId});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
