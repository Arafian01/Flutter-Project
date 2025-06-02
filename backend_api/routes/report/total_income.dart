import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';

List<Map<String, dynamic>> _generateMonths(int year) {
  final result = <Map<String, dynamic>>[];
  for (var month = 1; month <= 12; month++) {
    result.add({'bulan': month, 'tahun': year});
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
  final monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final conn = await createConnection();
  try {
    final rows = await conn.query('''
      SELECT bulan, tahun, COALESCE(SUM(harga), 0) as total_harga
      FROM tagihans
      WHERE status_pembayaran = 'lunas' AND tahun = @year
      GROUP BY bulan, tahun
      ORDER BY tahun, bulan
    ''', substitutionValues: {'year': year});

    final totalMap = {for (var row in rows) '${row[0]}-${row[1]}': row[2] as int};
    final report = <Map<String, dynamic>>[];

    for (var i = 0; i < months.length; i++) {
      final key = '${months[i]['bulan']}-${months[i]['tahun']}';
      report.add({
        'month': '${monthNames[i]} ${months[i]['tahun']}',
        'total_harga': totalMap[key] ?? 0,
      });
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