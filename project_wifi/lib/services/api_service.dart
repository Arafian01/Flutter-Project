import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pelanggan.dart';
import '../utils/constants.dart';

Future<List<Pelanggan>> fetchPelanggan() async {
  final response = await http.get(Uri.parse('$baseUrl/pelanggan'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Pelanggan.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data pelanggan');
  }
}
