// routes/dashboard.dart
import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart';
import '../lib/models/dashboard.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection(); // gunakan koneksi global jika ada

  try {
    final pelanggan = await connection.query('SELECT COUNT(*) FROM pelanggans');
    final paketAktif = await connection.query('SELECT COUNT(*) FROM pakets');
    final tagihanLunas = await connection.query("SELECT COUNT(*) FROM tagihans WHERE status_pembayaran = 'Lunas'");
    final pendingBayar = await connection.query("SELECT COUNT(*) FROM tagihans WHERE status_pembayaran = 'Belum Lunas'");

    final dashboard = Dashboard.fromRow([pelanggan[0], paketAktif[0], tagihanLunas[0], pendingBayar[0]]);
    return Response.json(body: dashboard.toJson());
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
