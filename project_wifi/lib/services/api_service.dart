import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/paket.dart';
import '../models/pelanggan.dart';
import '../models/dashboard.dart';
import '../models/tagihan.dart';
import '../models/pembayaran.dart';

/// Header JSON dan optional Authorization
Map<String, String> _headers([String? token]) {
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  return headers;
}

/// Generic GET list dengan timeout
Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

/// Generic POST/PUT/DELETE
Future<void> sendData(
    String method,
    String endpoint, {
      Map<String, dynamic>? body,
    }) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final encoded = body == null ? null : jsonEncode(body);
  late http.Response resp;
  switch (method) {
    case 'POST':
      resp = await http.post(url, headers: _headers(), body: encoded).timeout(const Duration(seconds: 10));
      break;
    case 'PUT':
      resp = await http.put(url, headers: _headers(), body: encoded).timeout(const Duration(seconds: 10));
      break;
    case 'DELETE':
      resp = await http.delete(url, headers: _headers()).timeout(const Duration(seconds: 10));
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }
  if (resp.statusCode >= 400) {
    final msg = resp.body.isNotEmpty
        ? (jsonDecode(resp.body) as Map<String, dynamic>)['error'] ?? resp.statusCode
        : resp.statusCode;
    throw Exception('$method $endpoint failed: $msg');
  }
}

/// Fetch daftar paket
Future<List<Paket>> fetchPakets() async {
  final list = await fetchData('paket');
  return list.map((m) => Paket.fromJson(m)).toList();
}

/// Create paket
Future<void> createPaket(Paket p) async =>
    sendData('POST', 'paket', body: p.toJson());

/// Update paket
Future<void> updatePaket(int id, Paket p) async =>
    sendData('PUT', 'paket/$id', body: p.toJson());

/// Delete paket
Future<void> deletePaket(int id) async => sendData('DELETE', 'paket/$id');

/// Fetch dashboard data
Future<Dashboard> fetchDashboard() async {
  final url = Uri.parse('$baseUrl/dashboard');
  final resp = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return Dashboard.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }
  throw Exception('GET dashboard failed: ${resp.statusCode}');
}

/// Pelanggan API
Future<List<Pelanggan>> fetchPelanggans() async {
  final list = await fetchData('pelanggan');
  return list.map((m) => Pelanggan.fromJson(m)).toList();
}

Future<void> createPelanggan(Map<String, dynamic> data) async =>
    sendData('POST', 'pelanggan', body: data);

Future<void> updatePelanggan(int id, Map<String, dynamic> data) async =>
    sendData('PUT', 'pelanggan/$id', body: data);

Future<void> deletePelanggan(int id) async => sendData('DELETE', 'pelanggan/$id');

/// Tagihan CRUD
Future<List<Tagihan>> fetchTagihans() async {
  final list = await fetchData('tagihan');
  return list.map((m) => Tagihan.fromJson(m)).toList();
}

Future<void> createTagihan(Map<String, dynamic> data) async =>
    sendData('POST', 'tagihan', body: data);

Future<void> updateTagihan(int id, Map<String, dynamic> data) async =>
    sendData('PUT', 'tagihan/$id', body: data);

Future<void> deleteTagihan(int id) async => sendData('DELETE', 'tagihan/$id');

/// Pembayaran CRUD
Future<List<Pembayaran>> fetchPembayarans() async {
  final list = await fetchData('pembayaran');
  return list.map((m) => Pembayaran.fromJson(m)).toList();
}

Future<void> createPembayaran({
  required int tagihanId,
  required int pelangganUserId,
  String status = 'menunggu verifikasi',
  required File imageFile,
}) async {
  final uri = Uri.parse('$baseUrl/pembayaran');
  final req = http.MultipartRequest('POST', uri);
  req.fields['tagihan_id'] = tagihanId.toString();
  req.fields['status_verifikasi'] = status;
  req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  final resp = await req.send();
  if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Create pembayaran failed');
}

Future<void> updatePembayaran({
  required int id,
  required String status,
  required int adminId,
  File? imageFile,
}) async {
  final uri = Uri.parse('$baseUrl/pembayaran/$id');
  final req = http.MultipartRequest('PUT', uri);
  req.fields['status_verifikasi'] = status;
  req.fields['user_id'] = adminId.toString();
  if (imageFile != null) req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  final resp = await req.send();
  if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Update pembayaran failed');
}

Future<void> deletePembayaran(int id) async => sendData('DELETE', 'pembayaran/$id');
