import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  try {
    final latexContent = await context.request.body();
    final tempDir = Directory.systemTemp.createTempSync('latex_');
    final texFile = File('${tempDir.path}/report.tex');
    await texFile.writeAsString(latexContent);

    // Jalankan latexmk untuk mengompilasi LaTeX ke PDF
    final result = await Process.run(
      'latexmk',
      ['-pdf', '-pdflatex=pdflatex', '-outdir=${tempDir.path}', 'report.tex'],
      workingDirectory: tempDir.path,
    );

    if (result.exitCode != 0) {
      throw Exception('Kompilasi LaTeX gagal: ${result.stderr}');
    }

    final pdfFile = File('${tempDir.path}/report.pdf');
    if (!await pdfFile.exists()) {
      throw Exception('File PDF tidak dihasilkan');
    }

    final pdfBytes = await pdfFile.readAsBytes();

    // Bersihkan file sementara
    await tempDir.delete(recursive: true);

    return Response.bytes(
      body: pdfBytes,
      headers: {'Content-Type': 'application/pdf'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Gagal menghasilkan PDF: $e'},
    );
  }
}