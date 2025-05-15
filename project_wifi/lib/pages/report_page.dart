// lib/pages/report_page.dart

import 'package:flutter/material.dart';
import '../models/report_item.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../widgets/strong_main_button.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int? _startMonth, _startYear, _endMonth, _endYear;
  bool _loading = false;
  List<String> _monthsList = [];
  List<ReportItem> _items = [];

  final List<int> _months = List.generate(12, (i) => i + 1);
  final int _currentYear = DateTime.now().year;
  final List<int> _years = List.generate(11, (i) => DateTime.now().year - 5 + i);

  Future<void> _loadReport() async {
    if (_startMonth == null ||
        _startYear == null ||
        _endMonth == null ||
        _endYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih semua rentang bulan & tahun')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final from = _startMonth!.toString().padLeft(2, '0') + '-$_startYear';
      final to = _endMonth!.toString().padLeft(2, '0') + '-$_endYear';
      final result = await ReportService.fetchReport(from: from, to: to);
      setState(() {
        _monthsList = List<String>.from(result['months'] as List<String>);
        _items = result['data'] as List<ReportItem>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat laporan: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required ValueChanged<T?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pembayaran'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // rentang dari
            Row(children: [
              _buildDropdown<int>(
                label: 'Bulan Dari',
                items: _months,
                value: _startMonth,
                onChanged: (v) => setState(() => _startMonth = v),
              ),
              const SizedBox(width: 8),
              _buildDropdown<int>(
                label: 'Tahun Dari',
                items: _years,
                value: _startYear,
                onChanged: (v) => setState(() => _startYear = v),
              ),
            ]),
            const SizedBox(height: 12),
            // rentang sampai
            Row(children: [
              _buildDropdown<int>(
                label: 'Bulan Sampai',
                items: _months,
                value: _endMonth,
                onChanged: (v) => setState(() => _endMonth = v),
              ),
              const SizedBox(width: 8),
              _buildDropdown<int>(
                label: 'Tahun Sampai',
                items: _years,
                value: _endYear,
                onChanged: (v) => setState(() => _endYear = v),
              ),
            ]),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : StrongMainButton(
              label: 'Tampilkan Laporan',
              onTap: _loadReport,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: [
                    const DataColumn(label: Text('No')),
                    const DataColumn(label: Text('Nama')),
                    for (final m in _monthsList)
                      DataColumn(label: Text(m)),
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
          ],
        ),
      ),
    );
  }
}
