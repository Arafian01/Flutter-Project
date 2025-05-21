import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/report_item.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int? _selectedYear;
  bool _loading = false;
  List<String> _monthsList = [];
  List<ReportItem> _items = [];

  final int _currentYear = DateTime.now().year;
  final List<int> _years = List.generate(11, (i) => DateTime.now().year - 5 + i);

  Future<void> _loadReport() async {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tahun terlebih dahulu')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ReportService.fetchReport(year: _selectedYear!);
      // Validasi struktur respons
      if (!result.containsKey('months') || !result.containsKey('data')) {
        throw Exception('Struktur respons API tidak valid');
      }
      setState(() {
        _monthsList = List<String>.from(result['months'] as List<dynamic>);
        _items = (result['data'] as List<dynamic>)
            .map((e) => ReportItem.fromJson(e as Map<String, dynamic>, _monthsList))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat laporan: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _printReport() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk dicetak')),
      );
      return;
    }
    try {
      // Buat dokumen PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Laporan Pembayaran Tahun $_selectedYear',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              defaultColumnWidth: pw.FlexColumnWidth(1),
              children: [
                // Header tabel
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Nama', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    for (final m in _monthsList)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          m.split('-')[0],
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                // Baris data
                for (var i = 0; i < _items.length; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${i + 1}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_items[i].nama),
                      ),
                      for (final m in _monthsList)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_items[i].statusByMonth[m]!),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );

      // Simpan PDF ke direktori sementara
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/laporan_$_selectedYear.pdf');
      await file.writeAsBytes(await pdf.save());

      // Buka PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Gagal membuka PDF: ${result.message}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dicetak ke PDF')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak laporan: $e')),
      );
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
      ),
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Laporan Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
            size: AppSizes.iconSizeMedium,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
        // Pilihan tahun
        _buildDropdown<int>(
        label: 'Pilih Tahun',
          items: _years,
          value: _selectedYear,
          onChanged: (v) => setState(() => _selectedYear = v),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        _loading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
              elevation: 2,
            ),
            onPressed: _loadReport,
            child: const Text(
              'Tampilkan Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        Expanded(
            child: Column(
                children: [
            Expanded(
            child: _items.isEmpty
            ? const Center(child: Text('Belum ada data'))
            : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.primaryRed.withOpacity(0.1)),
          columns: [
            const DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
              label: Text(
                'Nama',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            for (final m in _monthsList)
              DataColumn(
                label: Text(
                  m.split('-')[0],
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
          ],
          rows: List.generate(_items.length, (i) {
            final item = _items[i];
            return DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(item.nama)),
              for (final m in _monthsList)
                DataCell(Text(item.statusByMonth[m]!)),
            ]);
          }),
        ),
      ),
    ),
    if (_items.isNotEmpty)
    Padding(
    padding: const EdgeInsets.only(top: AppSizes.paddingMedium),
    child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
    ),
    backgroundColor: AppColors.primaryRed,
    foregroundColor: AppColors.white,
    elevation: 2,
    ),
    onPressed: _printReport,
    child: const Text(
    'Cetak Laporan',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    );
  }
}