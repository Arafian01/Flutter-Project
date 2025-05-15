// routes/dashboard_user/[id].dart

import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/dashboard_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = int.tryParse(id);
  if (userId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid user id'},
    );
  }

  final conn = await createConnection();
  try {
    if (context.request.method != HttpMethod.get) {
      return Response.json(statusCode: 405, body: {'error': 'Method Not Allowed'});
    }

    // Query counts and profile info for this user
    final pelangganRow = await conn.query(
      '''
      SELECT
        COUNT(t.id) FILTER (WHERE t.pelanggan_id = p.id) AS total_tagihan,
        COUNT(t.id) FILTER (WHERE t.pelanggan_id = p.id AND t.status_pembayaran = 'lunas') AS tagihan_lunas,
        COUNT(t.id) FILTER (WHERE t.pelanggan_id = p.id AND t.status_pembayaran != 'lunas') AS tagihan_pending,
        pk.nama_paket     AS paket_aktif,
        p.status          AS status_akun,
        p.tanggal_aktif,
        p.tanggal_langganan
      FROM pelanggans p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN tagihans t ON t.pelanggan_id = p.id
      JOIN pakets pk ON p.paket_id = pk.id
      WHERE p.id = @uid
      GROUP BY pk.nama_paket, p.status, p.tanggal_aktif, p.tanggal_langganan;
      ''',
      substitutionValues: {'uid': userId},
    );

    if (pelangganRow.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'User not found or not a pelanggan'});
    }

    final row = pelangganRow.first;
    // Extract fields
    final totalTagihan = (row[0] as int?) ?? 0;
    final tagihanLunas = (row[1] as int?) ?? 0;
    final tagihanPending = (row[2] as int?) ?? 0;
    final paketAktif = row[3] as String?;
    final statusAkun = row[4] as String? ?? '';
    final tanggalAktif = row[5] as DateTime?;
    final tanggalLangganan = row[6] as DateTime?;

    final dashboard = DashboardUser(
      totalTagihan: totalTagihan,
      tagihanLunas: tagihanLunas,
      tagihanPending: tagihanPending,
      paketAktif: paketAktif,
      statusAkun: statusAkun,
      tanggalAktif: tanggalAktif,
      tanggalLangganan: tanggalLangganan,
    );

    return Response.json(body: dashboard.toJson());
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}