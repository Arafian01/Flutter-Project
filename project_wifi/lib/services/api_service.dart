import 'dart:convert';
import '../models/dashboard.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/paket.dart';

/// Ambil header JSON & optional auth
Map<String,String> _headers([String? token]) {
  final h = {'Content-Type':'application/json'};
  if(token!=null) h['Authorization']='Bearer $token';
  return h;
}

/// Generic GET dengan timeout
Future<List<Map<String,dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http.get(url, headers:_headers()).timeout(const Duration(seconds:10));
  if (resp.statusCode==200) {
    return (jsonDecode(resp.body) as List).cast<Map<String,dynamic>>();
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

/// Khusus paket, return model
Future<List<Paket>> fetchPakets() async {
  final list = await fetchData('paket');
  return list.map((m)=>Paket.fromJson(m)).toList();
}

/// Create paket
Future<void> createPaket(Paket p) async {
  final url = Uri.parse('$baseUrl/paket');
  final resp = await http.post(url,
    headers: _headers(),
    body: jsonEncode(p.toJson()),
  ).timeout(const Duration(seconds:10));
  if (resp.statusCode!=201) {
    final msg = (jsonDecode(resp.body) as Map)['error'] ?? resp.statusCode;
    throw Exception('Create paket failed: $msg');
  }
}

/// Update paket
Future<void> updatePaket(int id, Paket p) async {
  final url = Uri.parse('$baseUrl/paket/$id');
  final resp = await http.put(url,
    headers: _headers(),
    body: jsonEncode(p.toJson()),
  ).timeout(const Duration(seconds:10));
  if (resp.statusCode!=200) throw Exception('Update paket failed');
}

/// Delete paket
Future<void> deletePaket(int id) async {
  final url = Uri.parse('$baseUrl/paket/$id');
  final resp = await http.delete(url, headers:_headers())
      .timeout(const Duration(seconds:10));
  if (resp.statusCode!=200) throw Exception('Delete paket failed');
}

/// Ambil satu objek dari endpoint
Future<Map<String, dynamic>> fetchSingleData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final response = await http.get(url).timeout(const Duration(seconds: 10));
  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Gagal mengambil data tunggal dari $endpoint (status ${response.statusCode})');
  }
}

/// Fetch dashboard data
Future<Dashboard> fetchDashboard() async {
  final jsonMap = await fetchSingleData('dashboard');
  return Dashboard.fromJson(jsonMap);
}
