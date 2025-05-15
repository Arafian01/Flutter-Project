// routes/report/index.dart
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';

DateTime _parseMonthYear(String s) {
  final parts = s.split('-');
  if (parts.length != 2) throw FormatException('Invalid format');
  final month = int.parse(parts[0]);
  final year = int.parse(parts[1]);
  return DateTime(year, month);
}

List<String> _generateMonths(DateTime from, DateTime to) {
  var cur = DateTime(from.year, from.month);
  final end = DateTime(to.year, to.month);
  final result = <String>[];
  while (!cur.isAfter(end)) {
    result.add('${cur.month.toString().padLeft(2,'0')}-${cur.year}');
    cur = DateTime(cur.year, cur.month + 1);
  }
  return result;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final qs = context.request.uri.queryParameters;
  final fromStr = qs['from'];
  final toStr = qs['to'];
  if (fromStr == null || toStr == null) {
    return Response.json(statusCode: 400, body: {'error': 'Missing from/to'});
  }
  late DateTime fromDt, toDt;
  try {
    fromDt = _parseMonthYear(fromStr);
    toDt = _parseMonthYear(toStr);
  } catch (e) {
    return Response.json(statusCode: 400, body: {'error': 'Bad date format'});
  }
  final months = _generateMonths(fromDt, toDt);

  final conn = await createConnection();
  try {
    // ambil semua tagihan dalam rentang
    final rows = await conn.query('''
      SELECT p.id AS pelanggan_id, u.name AS nama,
             t.bulan_tahun, t.status_pembayaran
      FROM tagihans t
      JOIN pelanggans p ON t.pelanggan_id = p.id
      JOIN users u       ON p.user_id = u.id
      WHERE to_date(t.bulan_tahun, 'MM-YYYY') BETWEEN @from AND @to;
    ''', substitutionValues: {
      'from': fromDt.toIso8601String().split('T').first,
      'to': toDt.toIso8601String().split('T').first,
    });

    // build map per pelanggan
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
