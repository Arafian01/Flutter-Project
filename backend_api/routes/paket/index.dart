import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';       // ← naik dua level ke lib
import '../../lib/models/paket.dart';   // ← naik dua level ke lib/models

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();

  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final results = await connection.query(
          'SELECT id, nama_paket, deskripsi, harga FROM pakets',
        );
        final pakets = results
            .map((row) => Paket.fromRow(row).toJson())
            .toList();
        return Response.json(body: pakets);

      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final paket = Paket.fromJson(jsonMap);

        await connection.query(
          '''
          INSERT INTO pakets (nama_paket, deskripsi, harga)
          VALUES (@nama, @desc, @harga)
          ''',
          substitutionValues: {
            'nama': paket.namaPaket,
            'desc': paket.deskripsi,
            'harga': paket.harga,
          },
        );

        return Response.json(
          body: {'message': 'Paket created', 'data': paket.toJson()},
          statusCode: 201,
        );

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await connection.close();
  }
}
