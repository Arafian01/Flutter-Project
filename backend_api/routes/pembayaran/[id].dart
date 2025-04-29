import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../lib/database.dart';
import 'package:path/path.dart' as path;

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;

  if (request.method == HttpMethod.get) {
    return _getPembayaranById(int.parse(id));
  } else if (request.method == HttpMethod.put) {
    return _updatePembayaran(context, int.parse(id));
  } else if (request.method == HttpMethod.delete) {
    return _deletePembayaran(int.parse(id));
  }

  return Response.json(statusCode: 405, body: {'error': 'Method not allowed'});
}

// GET
Future<Response> _getPembayaranById(int id) async {
  final conn = await createConnection();

  final results = await conn.mappedResultsQuery('''
    SELECT pb.id, pb.tagihan_id, t.bulan_tahun, pb.image, pb.tanggal_kirim,
           u.name, pb.status_verifikasi, pb.tanggal_verifikasi
    FROM pembayaran pb
    JOIN tagihan t ON pb.tagihan_id = t.id
    JOIN pelanggan p ON t.pelanggan_id = p.id
    JOIN users u ON p.user_id = u.id
    WHERE pb.id = @id
  ''', substitutionValues: {'id': id});

  await conn.close();

  if (results.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Pembayaran tidak ditemukan'});
  }

  final row = results.first;
  final pb = row['pb']!;
  final t = row['t']!;
  final u = row['u']!;

  return Response.json(body: {
    'id': pb['id'],
    'tagihan_id': pb['tagihan_id'],
    'bulan_tahun': t['bulan_tahun'],
    'image': pb['image'],
    'tanggal_kirim': pb['tanggal_kirim'],
    'name': u['name'],
    'status_verifikasi': pb['status_verifikasi'],
    'tanggal_verifikasi': pb['tanggal_verifikasi'],
  });
}

// PUT
Future<Response> _updatePembayaran(RequestContext context, int id) async {
  final conn = await createConnection();

  final oldData = await conn.query(
    'SELECT image, tagihan_id FROM pembayaran WHERE id = @id',
    substitutionValues: {'id': id},
  );

  if (oldData.isEmpty) {
    await conn.close();
    return Response.json(statusCode: 404, body: {'error': 'Data tidak ditemukan'});
  }

  String? oldImage = oldData.first[0] as String?;
  int tagihanId = oldData.first[1] as int;

  final headers = context.request.headers;
  final contentType = headers['content-type'];
  if (contentType == null || !contentType.startsWith('multipart/form-data')) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid content type'});
  }

  final boundary = contentType.split('boundary=')[1];
  final transformer = MimeMultipartTransformer(boundary);
  final parts = await transformer.bind(context.request.body()).toList();

  String? imagePath = oldImage;
  String statusVerifikasi = 'menunggu verifikasi';
  DateTime? tanggalVerifikasi;
  int? newUserId;
  int? newTagihanId;

  for (final part in parts) {
    final contentDisposition = part.headers['content-disposition'];
    if (contentDisposition == null) continue;

    final nameMatch = RegExp(r'name="(.+?)"').firstMatch(contentDisposition);
    final name = nameMatch?.group(1);

    if (name == 'image') {
      final content = await part.toList();
      final bytes = content.expand((e) => e).toList();
      final ext = lookupMimeType('', headerBytes: bytes)?.split('/').last ?? 'jpg';
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final file = File('public/uploads/$filename');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      imagePath = '/uploads/$filename';

      // Hapus gambar lama
      if (oldImage != null) {
        final oldFile = File('public$oldImage');
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
    } else {
      final content = await utf8.decoder.bind(part).join();
      switch (name) {
        case 'status_verifikasi':
          statusVerifikasi = content;
          break;
        case 'user_id':
          newUserId = int.tryParse(content);
          break;
        case 'tagihan_id':
          newTagihanId = int.tryParse(content);
          break;
      }
    }
  }

  if (statusVerifikasi == 'diterima' || statusVerifikasi == 'ditolak') {
    tanggalVerifikasi = DateTime.now();
  }

  await conn.query('''
    UPDATE pembayaran
    SET tagihan_id = @tagihan_id,
        user_id = @user_id,
        image = @image,
        status_verifikasi = @status_verifikasi,
        tanggal_verifikasi = @tanggal_verifikasi
    WHERE id = @id
  ''', substitutionValues: {
    'id': id,
    'tagihan_id': newTagihanId ?? tagihanId,
    'user_id': newUserId ?? 0,
    'image': imagePath,
    'status_verifikasi': statusVerifikasi,
    'tanggal_verifikasi': tanggalVerifikasi,
  });

  // Update tagihan status
  String statusPembayaran = (statusVerifikasi == 'diterima') ? 'lunas' : 'menunggu_verifikasi';
  await conn.query(
    'UPDATE tagihan SET status_pembayaran = @status WHERE id = @id',
    substitutionValues: {'status': statusPembayaran, 'id': newTagihanId ?? tagihanId},
  );

  await conn.close();
  return Response.json(body: {'message': 'Data pembayaran berhasil diperbarui'});
}

// DELETE
Future<Response> _deletePembayaran(int id) async {
  final conn = await createConnection();

  final result = await conn.query(
    'SELECT image, tagihan_id FROM pembayaran WHERE id = @id',
    substitutionValues: {'id': id},
  );

  if (result.isEmpty) {
    await conn.close();
    return Response.json(statusCode: 404, body: {'error': 'Data tidak ditemukan'});
  }

  final imagePath = result.first[0] as String?;
  final tagihanId = result.first[1] as int;

  final tagihanStatus = await conn.query(
    'SELECT status_pembayaran FROM tagihan WHERE id = @id',
    substitutionValues: {'id': tagihanId},
  );

  final currentStatus = tagihanStatus.first[0] as String;
  if (currentStatus == 'lunas') {
    await conn.close();
    return Response.json(statusCode: 400, body: {
      'status': 'error',
      'message': 'Pembayaran sudah lunas, tidak bisa dihapus'
    });
  }

  await conn.query('DELETE FROM pembayaran WHERE id = @id', substitutionValues: {'id': id});
  await conn.query(
    'UPDATE tagihan SET status_pembayaran = @status WHERE id = @id',
    substitutionValues: {'status': 'belum_dibayar', 'id': tagihanId},
  );

  if (imagePath != null) {
    final file = File('public$imagePath');
    if (await file.exists()) {
      await file.delete();
    }
  }

  await conn.close();
  return Response.json(body: {
    'status': 'success',
    'message': 'Pembayaran berhasil dihapus'
  });
}
