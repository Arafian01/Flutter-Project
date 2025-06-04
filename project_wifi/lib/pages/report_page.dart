import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/report_item.dart';
import '../../../models/total_income_report.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

enum ReportType { payment, income }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  int? _selectedYear;
  bool _loading = false;
  ReportType _reportType = ReportType.payment;
  List<int> _monthsList = [];
  List<ReportItem> _paymentItems = [];
  List<TotalIncomeReport> _incomeItems = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final int _currentYear = DateTime.now().year;
  final List<int> _years = List.generate(11, (i) => DateTime.now().year - 5 + i);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
        const SnackBar(
          content: Text('Pilih tahun terlebih dahulu'),
          backgroundColor: AppColors.accentRed,
        ),
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
        if (mounted) {
          setState(() {
            _monthsList = List<int>.from(result['months']);
            _paymentItems = (result['data'] as List<dynamic>)
                .map((e) => ReportItem.fromJson(e as Map<String, dynamic>, _monthsList.map((m) => m.toString()).toList()))
                .toList();
            _incomeItems = [];
          });
        }
      } else {
        final result = await ReportService.fetchTotalIncomeReport(_selectedYear!);
        if (mounted) {
          setState(() {
            _monthsList = List.generate(12, (i) => i + 1);
            _incomeItems = result;
            _paymentItems = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat laporan: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _controller.forward(from: 0);
      }
    }
  }

  Future<void> _printReport() async {
    if (_reportType == ReportType.payment && _paymentItems.isEmpty ||
        _reportType == ReportType.income && _incomeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk dicetak'),
          backgroundColor: AppColors.accentRed,
        ),
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
          margin: const pw.EdgeInsets.all(32),
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
                  defaultColumnWidth: const pw.FlexColumnWidth(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
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
                              DateFormat('MMMM', 'id_ID').format(DateTime(_selectedYear!, m)),
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
                              child: pw.Text(_paymentItems[i].statusByMonth[m] ?? '-'),
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
                  defaultColumnWidth: const pw.FlexColumnWidth(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
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
                    for (var item in _incomeItems)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              DateFormat('MMMM yyyy', 'id_ID').format(DateTime(item.tahun, item.bulan)),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(_formatRupiah(item.totalHarga)),
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
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka PDF: ${result.message}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dicetak ke PDF'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak laporan: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
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
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.textSecondaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
      ),
      value: value,
      items: items
          .map((e) => DropdownMenuItem<T>(
        value: e,
        child: Text('$e'),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Laporan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white, size: AppSizes.iconSizeMedium),
            onPressed: _loadReport,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _reportType == ReportType.payment ? AppColors.primaryBlue : AppColors.white,
                      foregroundColor: _reportType == ReportType.payment ? AppColors.white : AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
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
                      backgroundColor: _reportType == ReportType.income ? AppColors.primaryBlue : AppColors.white,
                      foregroundColor: _reportType == ReportType.income ? AppColors.white : AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
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
            _buildDropdown(
              label: 'Pilih Tahun',
              items: _years,
              value: _selectedYear,
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _loading
                  ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                ),
              )
                  : SizedBox(
                key: ValueKey('button'),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
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
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _reportType == ReportType.payment ? _buildPaymentReport() : _buildIncomeReport(),
              ),
            ),
            if (_paymentItems.isNotEmpty || _incomeItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.paddingMedium),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
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
      return const Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondaryBlue),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.secondaryBlue.withOpacity(0.1)),
        columns: [
          DataColumn(
            label: Text(
              'No',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Nama',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final m in _monthsList)
            DataColumn(
              label: Text(
                DateFormat('MMMM', 'id_ID').format(DateTime(_selectedYear!, m)),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        rows: List.generate(_paymentItems.length, (i) {
          final item = _paymentItems[i];
          return DataRow(
            cells: [
              DataCell(Text('${i + 1}', style: const TextStyle(color: AppColors.textSecondaryBlue))),
              DataCell(Text(item.nama, style: const TextStyle(color: AppColors.textSecondaryBlue))),
              for (final m in _monthsList)
                DataCell(
                  Text(
                    item.statusByMonth[m] ?? '-',
                    style: const TextStyle(color: AppColors.textSecondaryBlue),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildIncomeReport() {
    if (_incomeItems.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondaryBlue),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.secondaryBlue.withOpacity(0.1)),
        columns: [
          DataColumn(
            label: Text(
              'Bulan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Harga',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: _incomeItems.map((item) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(DateTime(item.tahun, item.bulan)),
                  style: const TextStyle(color: AppColors.textSecondaryBlue),
                ),
              ),
              DataCell(
                Text(
                  _formatRupiah(item.totalHarga),
                  style: const TextStyle(color: AppColors.textSecondaryBlue),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}