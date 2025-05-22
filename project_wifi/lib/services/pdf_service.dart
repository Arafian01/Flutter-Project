import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../utils/constants.dart';

class PdfService {
  static Future<void> generatePdf(String latexContent, String fileName) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/pdf/generate');
    final response = await http.post(
      uri,
      body: latexContent,
      headers: {'Content-Type': 'text/plain'},
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghasilkan PDF: ${response.statusCode}');
    }

    // Simpan PDF ke direktori sementara
    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/$fileName');
    await pdfFile.writeAsBytes(response.bodyBytes);

    // Buka PDF
    final result = await OpenFile.open(pdfFile.path);
    if (result.type != ResultType.done) {
      throw Exception('Gagal membuka PDF: ${result.message}');
    }
  }
}