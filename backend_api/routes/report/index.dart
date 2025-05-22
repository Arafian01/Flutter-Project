import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';

List<String> _generateMonths(int year) {
  final result = <String>[];
  for (var month = 1; month <= 12; month++) {
    result.add('${month.toString().padLeft(2, '0')}-$year');
  }
  return result;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final qs = context.request.uri.queryParameters;
  final yearStr = qs['year'];
  if (yearStr == null) {
    return Response.json(statusCode: 400, body: {'error': 'Parameter tahun diperlukan'});
  }
  late int year;
  try {
    year = int.parse(yearStr);
  } catch (e) {
    return Response.json(statusCode: 400, body: {'error': 'Format tahun tidak valid'});
  }
  final months = _generateMonths(year);

  final conn = await createConnection();
  try {
    // Ambil semua tagihan untuk tahun tertentu
    final rows = await conn.query('''
      SELECT p.id AS pelanggan_id, u.name AS nama,
             t.bulan_tahun, t.status_pembayaran
      FROM tagihans t
      JOIN pelanggans p ON t.pelanggan_id = p.id
      JOIN users u ON p.user_id = u.id
      WHERE t.bulan_tahun LIKE @pattern;
    ''', substitutionValues: {
      'pattern': '%-$yearStr',
    });

    // Buat peta per pelanggan
    final Map<int, Map<String, String>> statusMap = {};
    final Map<int, String> nameMap = {};
    for (final r in rows) {
      final pid = r[0] as int;
      final nama = r[1] as String;
      final bt = r[2] as String;
      final st = r[3] as String;
      nameMap[pid] = nama;
      statusMap.putIfAbsent(pid, () => {})[bt] = st;
    }

    final report = <Map<String, dynamic>>[];
    for (final pid in nameMap.keys) {
      final entry = <String, dynamic>{
        'pelanggan_id': pid,
        'nama': nameMap[pid],
      };
      for (final m in months) {
        entry[m] = statusMap[pid]?[m] ?? '-';
      }
      report.add(entry);
    }

    return Response.json(body: {
      'months': months,
      'data': report,
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await conn.close();
  }
}