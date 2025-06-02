import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';
import '../../../lib/models/tagihan.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final pelangganId = int.tryParse(id);
  if (pelangganId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid pelanggan id'},
    );
  }

  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed'},
    );
  }

  final conn = await createConnection();
  try {
    final results = await conn.query(
      '''
      SELECT
        t.id,
        t.pelanggan_id,
        u.name AS pelanggan_name,
        t.bulan,
        t.tahun,
        t.status_pembayaran,
        t.jatuh_tempo,
        t.harga
      FROM tagihans t
      JOIN pelanggans p ON t.pelanggan_id = p.id
      JOIN users u ON p.user_id = u.id
      WHERE t.pelanggan_id = @pid
      ORDER BY 
        CASE t.status_pembayaran
          WHEN 'belum_dibayar' THEN 1
          WHEN 'menunggu_verifikasi' THEN 2
          WHEN 'lunas' THEN 3
          ELSE 4
        END,
        t.tahun ASC,
        t.bulan DESC;
      ''',
      substitutionValues: {'pid': pelangganId},
    );

    final list = results.map((row) => Tagihan.fromRow(row).toJson()).toList();
    return Response.json(body: list);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  } finally {
    await conn.close();
  }
}