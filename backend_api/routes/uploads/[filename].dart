import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context, String filename) async {
  final file = File('uploads/$filename');

  if (!await file.exists()) {
    return Response.json(statusCode: 404, body: {'error': 'File not found'});
  }

  // Baca file sebagai bytes
  final bytes = await file.readAsBytes();
  // Tentukan MIME type, misal image/png
  final contentType = lookupMimeType(file.path) ?? 'application/octet-stream';

  // Kirim bytes sebagai response
  return Response.bytes(
    body: bytes,
    headers: {'Content-Type': contentType},
  );
}
