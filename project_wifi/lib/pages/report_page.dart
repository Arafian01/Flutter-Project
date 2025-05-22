import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/report_item.dart';
import '../models/total_income_report.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

enum ReportType { payment, income }

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  int? _selectedYear;
  bool _loading = false;
  ReportType _reportType = ReportType.payment;
  List<String> _monthsList = [];
  List<ReportItem> _paymentItems = [];
  List<TotalIncomeReport> _incomeItems = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final int _currentYear = DateTime.now().year;
  final List<int> _years = List.generate(11, (i) => DateTime.now().year - 5 + i);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tahun terlebih dahulu')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      if (_reportType == ReportType.payment) {
        final result = await ReportService.fetchReport(year: _selectedYear!);
        if (!result.containsKey('months') || !result.containsKey('data')) {
          throw Exception('Struktur respons API tidak valid');
        }
        setState(() {
          _monthsList = List<String>.from(result['months'] as List<dynamic>);
          _paymentItems = (result['data'] as List<dynamic>)
              .map((e) => ReportItem.fromJson(e as Map<String, dynamic>, _monthsList))
              .toList();
          _incomeItems = [];
        });
      } else {
        final result = await ReportService.fetchTotalIncomeReport(_selectedYear!);
        setState(() {
          _monthsList = List.generate(12, (i) => '${(i + 1).toString().padLeft(2, '0')}-$_selectedYear');
          _incomeItems = result;
          _paymentItems = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat laporan: $e')),
      );
    } finally {
      setState(() => _loading = false);
      _controller.forward(from: 0);
    }
  }

  Future<void> _printReport() async {
    if (_reportType == ReportType.payment && _paymentItems.isEmpty ||
        _reportType == ReportType.income && _incomeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk dicetak')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final title = _reportType == ReportType.payment
          ? 'Laporan Pembayaran Tahun $_selectedYear'
          : 'Laporan Penghasilan Tahun $_selectedYear';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            if (_reportType == ReportType.payment) {
              return [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(),
                  defaultColumnWidth: pw.FlexColumnWidth(1),
                  children: [
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
                    for (var i = 0; i < _paymentItems.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${i + 1}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(_paymentItems[i].nama),
                          ),
                          for (final m in _monthsList)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(_paymentItems[i].statusByMonth[m]!),
                            ),
                        ],
                      ),
                  ],
                ),
              ];
            } else {
              return [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(),
                  defaultColumnWidth: pw.FlexColumnWidth(1),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Bulan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total Harga', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    for (var i = 0; i < _incomeItems.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(_incomeItems[i].month),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(_formatRupiah(_incomeItems[i].totalHarga)),
                          ),
                        ],
                      ),
                  ],
                ),
              ];
            }
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/laporan_${_reportType.name}_$_selectedYear.pdf');
      await file.writeAsBytes(await pdf.save());

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

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Laporan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadReport,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _reportType == ReportType.payment
                          ? AppColors.primaryRed
                          : AppColors.textSecondary.withOpacity(0.3),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _reportType = ReportType.payment;
                        _paymentItems = [];
                        _incomeItems = [];
                        _monthsList = [];
                      });
                    },
                    child: const Text('Laporan Pembayaran'),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _reportType == ReportType.income
                          ? AppColors.primaryRed
                          : AppColors.textSecondary.withOpacity(0.3),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _reportType = ReportType.income;
                        _paymentItems = [];
                        _incomeItems = [];
                        _monthsList = [];
                      });
                    },
                    child: const Text('Laporan Penghasilan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _reportType == ReportType.payment
                    ? _buildPaymentReport()
                    : _buildIncomeReport(),
              ),
            ),
            if (_paymentItems.isNotEmpty || _incomeItems.isNotEmpty)
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentReport() {
    if (_paymentItems.isEmpty) {
      return const Center(child: Text('Belum ada data'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primaryRed.withOpacity(0.1)),
        columns: [
          const DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
            label: Text(
              'Nama',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          for (final m in _monthsList)
            DataColumn(
              label: Text(
                m.split('-')[0],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
        rows: List.generate(_paymentItems.length, (i) {
          final item = _paymentItems[i];
          return DataRow(cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Text(item.nama)),
            for (final m in _monthsList) DataCell(Text(item.statusByMonth[m]!)),
          ]);
        }),
      ),
    );
  }

  Widget _buildIncomeReport() {
    if (_incomeItems.isEmpty) {
      return const Center(child: Text('Belum ada data'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primaryRed.withOpacity(0.1)),
        columns: [
          DataColumn(
            label: Text(
              'Bulan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Harga',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: _incomeItems.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.month)),
            DataCell(Text(_formatRupiah(item.totalHarga))),
          ]);
        }).toList(),
      ),
    );
  }
}