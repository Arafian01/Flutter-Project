import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(Uri.parse('http://localhost:8080/users'));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load users');
  }
}
