import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context) async {
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
        ORDER BY pm.id;
      ''');
      final list = rows.map((r) => Pembayaran.fromRow(r).toJson()).toList();
      return Response.json(body: list);
    }

    if (context.request.method == HttpMethod.post) {
      final form = await context.request.formData();

      // wajib: bulan_tahun, pelanggan_id, status_verifikasi, image
      final bt = form.fields['bulan_tahun'];
      final pid = int.tryParse(form.fields['pelanggan_id'] ?? '');
      final st = form.fields['status_verifikasi'];
      final filePart = form.files['image'];

      if (bt == null || pid == null || st == null || filePart == null) {
        return Response.json(statusCode: 400, body: {'error': 'Missing fields'});
      }

      // tentukan tagihan_id bila ada
      final tagRes = await conn.query('''
        SELECT id FROM tagihans
         WHERE pelanggan_id = @pid AND bulan_tahun = @bt
         LIMIT 1;
      ''', substitutionValues: {'pid': pid, 'bt': bt});
      final tid = tagRes.isEmpty ? null : tagRes.first[0] as int;

      // ambil harga dari paket
      final priceRes = await conn.query('''
        SELECT pk.harga
          FROM pelanggans pl
          JOIN pakets pk ON pl.paket_id = pk.id
         WHERE pl.id = @plid
         LIMIT 1;
      ''', substitutionValues: {'plid': pid});
      final harga = priceRes.first[0] as int;

      // simpan file
      final bytes = await filePart.readAsBytes();
      final ext = filePart.name.split('.').last;
      final imgName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Directory('uploads').create(recursive: true);
      await File('uploads/$imgName').writeAsBytes(bytes);

      final tv = (st == 'diterima' || st == 'ditolak')
          ? DateTime.now().toIso8601String().split('T')[0]
          : null;

      final result = await conn.query('''
        INSERT INTO pembayarans
          (tagihan_id, bulan_tahun, pelanggan_id, image, tanggal_kirim,
           status_verifikasi, tanggal_verifikasi, harga)
        VALUES
          (@tid, @bt, @pid, @img, CURRENT_DATE, @st, @tv, @hr)
        RETURNING id;
      ''', substitutionValues: {
        'tid': tid,
        'bt': bt,
        'pid': pid,
        'img': '/uploads/$imgName',
        'st': st,
        'tv': tv,
        'hr': harga,
      });
      final newId = result.first[0] as int;

      // update tagihan jika terhubung
      if (tid != null) {
        final newSt = st == 'diterima' ? 'lunas'
                      : st == 'ditolak' ? 'belum_dibayar'
                      : 'menunggu_verifikasi';
        await conn.query(
          'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
          substitutionValues: {'s': newSt, 'tid': tid},
        );
      }

      return Response.json(statusCode: 201, body: {'id': newId});
    }

    return Response(statusCode: 405);
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}
