import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = await createConnection();
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        print('Fetching all pembayarans');
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
        print('Rows fetched: ${rows.length}');
        return Response.json(
          body: rows.map((r) => Pembayaran.fromRow(r).toJson()).toList(),
        );

      case HttpMethod.post:
        print('Handling POST request for pembayaran');
        final form = await context.request.formData();
        final tidStr = form.fields['tagihan_id'];
        final st = form.fields['status_verifikasi'];
        final file = form.files['image'];

        print('Form data: tagihan_id=$tidStr, status_verifikasi=$st, image=${file?.name}');

        if (tidStr == null || st == null || file == null) {
          print('Missing fields detected');
          return Response.json(
              statusCode: 400, body: {'error': 'Missing fields'});
        }
        final tid = int.tryParse(tidStr);
        if (tid == null) {
          print('Invalid tagihan_id: $tidStr');
          return Response.json(
              statusCode: 400, body: {'error': 'Invalid tagihan_id'});
        }

        // Cek duplikasi
        print('Checking for duplicate pembayaran with tagihan_id=$tid');
        final dup = await conn.query(
          'SELECT 1 FROM pembayarans WHERE tagihan_id = @tid LIMIT 1',
          substitutionValues: {'tid': tid},
        );
        if (dup.isNotEmpty) {
          print('Duplicate found for tagihan_id=$tid');
          return Response.json(
              statusCode: 409,
              body: {'error': 'Pembayaran untuk tagihan ini sudah ada'});
        }

        // Ambil harga & nama pelanggan
        print('Fetching tagihan details for tagihan_id=$tid');
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
          print('Tagihan not found for tagihan_id=$tid');
          return Response.json(
              statusCode: 404, body: {'error': 'Tagihan tidak ditemukan'});
        }
        final pelangganName = rel.first[0] as String;
        final harga = rel.first[1] as int;
        print('Tagihan found: pelanggan_name=$pelangganName, harga=$harga');

        // Simpan gambar
        print('Saving image for pembayaran');
        final bytes = await file.readAsBytes();
        final ext = file.name.split('.').last;
        final img = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final uploadDir = Directory('uploads');
        if (!await uploadDir.exists()) {
          print('Creating uploads directory');
          await uploadDir.create(recursive: true);
        }
        final filePath = 'uploads/$img';
        print('Writing image to $filePath');
        await File(filePath).writeAsBytes(bytes);

        // Tanggal verifikasi
        final tv = (st == 'diterima' || st == 'ditolak')
            ? DateTime.now().toIso8601String().split('T')[0]
            : null;
        print('Tanggal verifikasi: $tv');

        // Insert pembayaran
        print('Inserting pembayaran into database');
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
        print('Pembayaran inserted with id=$newId');

        // Update status tagihan
        final newSt = (st == 'diterima') ? 'lunas' : 'menunggu_verifikasi';
        print('Updating tagihan status to $newSt for tagihan_id=$tid');
        await conn.query(
          'UPDATE tagihans SET status_pembayaran = @s WHERE id = @tid',
          substitutionValues: {'s': newSt, 'tid': tid},
        );

        print('Pembayaran created successfully');
        return Response.json(statusCode: 201, body: {'id': newId});

      default:
        print('Method not allowed: ${context.request.method}');
        return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error in pembayaran endpoint: $e');
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}