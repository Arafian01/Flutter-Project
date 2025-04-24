import 'dart:convert';
import 'package:http/http.dart' as http;

// Fungsi umum untuk mengambil data dari API
Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('http://10.10.201.83:8080/$endpoint'); // Ganti dengan URL API yang sesuai

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load data');
  }
}
