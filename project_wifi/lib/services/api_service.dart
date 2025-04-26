import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/paket.dart';

/// Fungsi untuk mengambil list data dari endpoint (seperti untuk tabel/list)
Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Gagal mengambil data dari $endpoint');
  }
}

/// ✅ Fungsi untuk mengambil data tunggal (seperti dashboard)
Future<Map<String, dynamic>> fetchSingleData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Gagal mengambil data tunggal dari $endpoint');
  }
}

Future<List<Paket>> fetchPakets() async {
  final response = await http.get(Uri.parse('$baseUrl/paket'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Paket>.from(data.map((item) => Paket.fromJson(item)));
  } else {
    throw Exception('Gagal memuat data paket');
  }
}

/// Create new paket
Future<void> createPaket(Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/paket');
  final resp = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  if (resp.statusCode != 201) throw Exception('Gagal menambah paket');
}

/// Update existing paket
Future<void> updatePaket(int id, Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/paket/$id');
  final resp = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  if (resp.statusCode != 200) throw Exception('Gagal update paket');
}

/// Delete paket
Future<void> deletePaket(int id) async {
  final url = Uri.parse('$baseUrl/paket/$id');
  final resp = await http.delete(url);
  if (resp.statusCode != 200) throw Exception('Gagal hapus paket');
}

Future<void> createPelanggan(Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/pelanggan');
  final r = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data));
  if (r.statusCode != 201) throw Exception('Failed create pelanggan');
}

Future<void> updatePelanggan(int id, Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/pelanggan/$id');
  final r = await http.put(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data));
  if (r.statusCode != 200) throw Exception('Failed update pelanggan');
}

Future<void> deletePelanggan(int id) async {
  final url = Uri.parse('$baseUrl/pelanggan/$id');
  final r = await http.delete(url);
  if (r.statusCode != 200) throw Exception('Failed delete pelanggan');
}