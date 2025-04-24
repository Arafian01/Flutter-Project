import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pelanggan.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<List<Pelanggan>> fetchPelanggan() async {
    final response = await http.get(Uri.parse('$baseUrl/pelanggan'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Pelanggan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pelanggan');
    }
  }
}
