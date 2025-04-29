import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../../lib/database.dart';
import '../../lib/models/pembayaran.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method == HttpMethod.get) {
    return _getAllPembayaran();
  } else if (request.method == HttpMethod.post) {
    return _createPembayaran(context);
  }

  return Response.json(statusCode: 405, body: {'error': 'Method not allowed'});
}

Future<Response> _getAllPembayaran() async {
  final conn = await createConnection();

  final results = await conn.mappedResultsQuery('''
    SELECT pb.id, pb.tagihan_id, t.bulan_tahun, pb.image, pb.tanggal_kirim,
           u.name, pb.status_verifikasi, pb.tanggal_verifikasi
    FROM pembayaran pb
    JOIN tagihan t ON pb.tagihan_id = t.id
    JOIN pelanggan p ON t.pelanggan_id = p.id
    JOIN users u ON p.user_id = u.id
  ''');

  final pembayaranList = results.map((row) {
    final pb = row['pb']!;
    final t = row['t']!;
    final u = row['u']!;
    return Pembayaran(
      id: pb['id'] as int,
      tagihanId: pb['tagihan_id'] as int,
      bulanTahun: t['bulan_tahun'] as String,
      image: pb['image'] as String,
      tanggalKirim: pb['tanggal_kirim'] as DateTime,
      name: u['name'] as String,
      statusVerifikasi: pb['status_verifikasi'] as String,
      tanggalVerifikasi: pb['tanggal_verifikasi'] as DateTime?,
    ).toJson();
  }).toList();

  await conn.close();
  return Response.json(body: pembayaranList);
}

Future<Response> _createPembayaran(RequestContext context) async {
  final conn = await createConnection();
  final headers = context.request.headers;
  final contentType = headers['content-type'];
  if (contentType == null || !contentType.startsWith('multipart/form-data')) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid content type'});
  }

  final boundary = contentType.split('boundary=')[1];
  final transformer = MimeMultipartTransformer(boundary);
  final bodyStream = context.request.body();
  final parts = await transformer.bind(bodyStream).toList();

  int tagihanId = 0;
  String statusVerifikasi = 'menunggu verifikasi';
  String? imagePath;
  DateTime tanggalKirim = DateTime.now();
  DateTime? tanggalVerifikasi;
  int userId = 0;

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
    } else {
      final content = await utf8.decoder.bind(part).join();
      switch (name) {
        case 'tagihan_id':
          tagihanId = int.parse(content);
          break;
        case 'status_verifikasi':
          statusVerifikasi = content;
          break;
        case 'user_id':
          userId = int.parse(content);
          break;
      }
    }
  }

  // Tanggal verifikasi logika
  if (statusVerifikasi == 'diterima' || statusVerifikasi == 'ditolak') {
    tanggalVerifikasi = DateTime.now();
  }

  await conn.query('''
    INSERT INTO pembayaran (tagihan_id, image, tanggal_kirim, user_id, status_verifikasi, tanggal_verifikasi)
    VALUES (@tagihan_id, @image, CURRENT_DATE, @user_id, @status_verifikasi, @tanggal_verifikasi)
  ''', substitutionValues: {
    'tagihan_id': tagihanId,
    'image': imagePath,
    'user_id': userId,
    'status_verifikasi': statusVerifikasi,
    'tanggal_verifikasi': tanggalVerifikasi,
  });

  // Update status tagihan
  String newStatus = 'menunggu_verifikasi';
  if (statusVerifikasi == 'diterima') {
    newStatus = 'lunas';
  } else if (statusVerifikasi == 'ditolak') {
    newStatus = 'belum_dibayar';
  }

  await conn.query('UPDATE tagihan SET status_pembayaran = @status WHERE id = @id', substitutionValues: {
    'status': newStatus,
    'id': tagihanId,
  });

  await conn.close();
  return Response.json(body: {'message': 'Pembayaran berhasil ditambahkan'});
}
