import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/dashboard.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();

  try {
    // setiap query mengembalikan List<List<dynamic>>
    final pelangganRows   = await connection.query('SELECT COUNT(*) FROM pelanggans');
    final paketRows       = await connection.query('SELECT COUNT(*) FROM pakets');
    final lunasRows       = await connection.query(
      "SELECT COUNT(*) FROM tagihans WHERE status_pembayaran = 'Lunas'");
    final pendingRows     = await connection.query(
      "SELECT COUNT(*) FROM tagihans WHERE status_pembayaran = 'Belum Lunas'");

    // ambil elemen pertama dari row pertama
    final totalPelanggan = (pelangganRows.first[0] as int?) ?? 0;
    final totalPaket     = (paketRows.first[0]     as int?) ?? 0;
    final tagihanLunas   = (lunasRows.first[0]     as int?) ?? 0;
    final tagihanPending = (pendingRows.first[0]   as int?) ?? 0;

    final dashboard = Dashboard(
      totalPelanggan: totalPelanggan,
      totalPaket: totalPaket,
      tagihanLunas: tagihanLunas,
      tagihanPending: tagihanPending,
    );

    return Response.json(body: dashboard.toJson());
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}
