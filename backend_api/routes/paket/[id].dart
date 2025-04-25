import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';     // ← benar
import '../../lib/models/paket.dart'; // ← benar

Future<Response> onRequest(RequestContext context, String id) async {
  final connection = await createConnection();
  final paketId = int.parse(id);

  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final results = await connection.query(
          'SELECT id, nama_paket, deskripsi, harga FROM pakets WHERE id = @id',
          substitutionValues: {'id': paketId},
        );
        if (results.isEmpty) return Response(statusCode: 404);
        return Response.json(
          body: Paket.fromRow(results.first).toJson(),
        );

      case HttpMethod.put:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final updated = Paket.fromJson(jsonMap);

        await connection.query(
          '''
          UPDATE pakets
          SET nama_paket = @nama, deskripsi = @desc, harga = @harga
          WHERE id = @id
          ''',
          substitutionValues: {
            'id': paketId,
            'nama': updated.namaPaket,
            'desc': updated.deskripsi,
            'harga': updated.harga,
          },
        );
        return Response.json(body: {'message': 'Paket updated'});

      case HttpMethod.delete:
        await connection.query(
          'DELETE FROM pakets WHERE id = @id',
          substitutionValues: {'id': paketId},
        );
        return Response.json(body: {'message': 'Paket deleted'});

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await connection.close();
  }
}
