import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/paket.dart';
import '../models/pelanggan.dart';
import '../models/dashboard.dart';
import '../models/tagihan.dart';
import '../models/pembayaran.dart';
import '../models/report_item.dart';
import '../models/dashboard_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Header JSON dan optional Authorization
Map<String, String> _headers([String? token]) {
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  return headers;
}

/// Generic GET list dengan timeout
Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('${AppConstants.baseUrl}/$endpoint');
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
  final url = Uri.parse('${AppConstants.baseUrl}/$endpoint');
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

/// Fetch all pelanggan, then return the one matching this user_id
Future<Pelanggan> fetchPelangganByUserId(int userId) async {
  final all = await fetchPelanggans();       // your existing fetchPelanggans()
  return all.firstWhere((p) => p.userId == userId,
      orElse: () => throw Exception('Pelanggan not found for user $userId'));
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
  final url = Uri.parse('${AppConstants.baseUrl}/dashboard');
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


/// Tagihan CRUD via API terbaru
class TagihanService {
  /// GET /tagihan
  static Future<List<Tagihan>> fetchTagihans() async {
    final url = Uri.parse('${AppConstants.baseUrl}/tagihan');
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body) as List;
      return data.map((e) => Tagihan.fromJson(e)).toList();
    }
    throw Exception('Failed to load tagihans: ${resp.statusCode}');
  }

  static Future<List<Tagihan>> fetchTagihansByPelanggan(int pelangganId) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/tagihan/pelanggan/$pelangganId');
    final resp = await http.get(uri).timeout(Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body) as List;
      return data.map((e) => Tagihan.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat tagihan pelanggan (${resp.statusCode})');
  }

  /// POST /tagihan
  static Future<void> createTagihan({
    required int pelangganId,
    required String bulanTahun,
    required String statusPembayaran,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tagihan');
    final body = {
      'pelanggan_id': pelangganId,
      'bulan_tahun': bulanTahun,
      'status_pembayaran': statusPembayaran,
    };
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      final msg = jsonDecode(resp.body)['error'] ?? resp.statusCode;
      throw Exception('Create tagihan failed: $msg');
    }
  }

  /// PUT /tagihan/:id
  static Future<void> updateTagihan(
      int id, {
        required int pelangganId,
        required String bulanTahun,
        required String statusPembayaran,
      }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tagihan/$id');
    final body = {
      'pelanggan_id': pelangganId,
      'bulan_tahun': bulanTahun,
      'status_pembayaran': statusPembayaran,
    };
    final resp = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) throw Exception('Update tagihan failed');
  }

  /// DELETE /tagihan/:id
  static Future<void> deleteTagihan(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/tagihan/$id');
    final resp = await http.delete(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) throw Exception('Delete tagihan failed');
  }
}

class PembayaranService {
  /// Ambil semua pembayaran (admin)
  static Future<List<Pembayaran>> fetchPembayarans() async {
    final resp = await http.get(Uri.parse('${AppConstants.baseUrl}/pembayaran'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List;
      return list.map((e) => Pembayaran.fromJson(e)).toList();
    }
    throw Exception('Failed load pembayaran');
  }

  /// Ambil semua pembayaran untuk pelanggan (user)
  static Future<List<Pembayaran>> fetchPembayaransByPelanggan(int pid) async {
    final resp = await http.get(Uri.parse('${AppConstants.baseUrl}/pembayaran/pelanggan/$pid'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List;
      return list.map((e) => Pembayaran.fromJson(e)).toList();
    }
    throw Exception('Failed load pembayaran pelanggan');
  }

  /// Create pembayaran (admin)
  static Future<void> createPembayaran({
    required int tagihanId,
    required String statusVerifikasi,
    required File imageFile,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/pembayaran');
    final req = http.MultipartRequest('POST', uri)
      ..fields['tagihan_id'] = tagihanId.toString()
      ..fields['status_verifikasi'] = statusVerifikasi
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final res = await req.send().timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Create pembayaran failed (${res.statusCode})');
    }
  }

  /// Edit pembayaran
  static Future<void> updatePembayaran({
    required int id,
    required String statusVerifikasi,
    File? imageFile,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/pembayaran/$id');
    final req = http.MultipartRequest('PUT', uri)
      ..fields['status_verifikasi'] = statusVerifikasi;
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final res = await req.send().timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Update pembayaran failed (${res.statusCode})');
    }
  }

  /// Hapus pembayaran
  static Future<void> deletePembayaran(int id) async {
    final resp = await http.delete(Uri.parse('${AppConstants.baseUrl}/pembayaran/$id'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Delete pembayaran failed (${resp.statusCode})');
    }
  }

  /// Tambah pembayaran (user)
  static Future<void> createPembayaranUser({
    required int pelangganId,
    required String bulanTahun,
    required String statusVerifikasi,
    required File imageFile,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/pembayaran/pelanggan/$pelangganId');
    final req = http.MultipartRequest('POST', uri)
      ..fields['bulan_tahun'] = bulanTahun
      ..fields['status_verifikasi'] = statusVerifikasi
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final res = await req.send().timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Create pembayaran user failed (${res.statusCode})');
    }
  }
}

class DashboardUserService {
  static Future<DashboardUser> fetchDashboardUser(int pelangganId) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/dashboard_user/$pelangganId');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      return DashboardUser.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to load dashboard user (${resp.statusCode})');
  }
}

class ReportService {
  /// GET /report?from=MM-YYYY&to=MM-YYYY
  static Future<Map<String, dynamic>> fetchReport({
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/report?from=$from&to=$to');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Gagal memuat laporan (${resp.statusCode})');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final months = List<String>.from(body['months'] as List);
    final data = (body['data'] as List)
        .map((e) => ReportItem.fromJson(e as Map<String, dynamic>, months))
        .toList();
    return {'months': months, 'data': data};
  }
}