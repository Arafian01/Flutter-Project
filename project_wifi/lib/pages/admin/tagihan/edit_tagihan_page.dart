import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/pelanggan.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import 'package:intl/intl.dart';

class EditTagihanPage extends StatefulWidget {
  final Tagihan tagihan;
  const EditTagihanPage({super.key, required this.tagihan});

  @override
  State<EditTagihanPage> createState() => _EditTagihanPageState();
}

class _EditTagihanPageState extends State<EditTagihanPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<Pelanggan> _pelanggans = [];
  Pelanggan? _selected;
  int? _selectedMonth;
  int? _selectedYear;
  String _status = '';
  bool _saving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _months = [
    {'name': 'Januari', 'value': 1},
    {'name': 'Februari', 'value': 2},
    {'name': 'Maret', 'value': 3},
    {'name': 'April', 'value': 4},
    {'name': 'Mei', 'value': 5},
    {'name': 'Juni', 'value': 6},
    {'name': 'Juli', 'value': 7},
    {'name': 'Agustus', 'value': 8},
    {'name': 'September', 'value': 9},
    {'name': 'Oktober', 'value': 10},
    {'name': 'November', 'value': 11},
    {'name': 'Desember', 'value': 12},
  ];
  final _currentYear = DateTime.now().year;
  final List<int> _years = List.generate(11, (i) => DateTime.now().year - 5 + i);

  @override
  void initState() {
    super.initState();
    final parts = widget.tagihan.bulanTahun.split('-');
    _selectedMonth = int.parse(parts[0]);
    _selectedYear = int.parse(parts[1]);
    _status = widget.tagihan.statusPembayaran;
    _loadPelanggans();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPelanggans() async {
    try {
      _pelanggans = await fetchPelanggans();
      setState(() {
        _selected = _pelanggans.firstWhere(
              (p) => p.id == widget.tagihan.pelangganId,
          orElse: () => _pelanggans.first,
        );
      });
      if (_pelanggans.isEmpty) {
        _showErrorDialog('Tidak ada pelanggan tersedia');
      } else if (_selected == null) {
        _showErrorDialog('Pelanggan tidak ditemukan');
      }
    } catch (e) {
      _showErrorDialog('Gagal memuat pelanggan: $e');
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _selected == null || _selectedMonth == null || _selectedYear == null) {
      if (_selected == null) {
        _showErrorDialog('Pilih pelanggan terlebih dahulu');
      } else if (_selectedMonth == null) {
        _showErrorDialog('Pilih bulan terlebih dahulu');
      } else if (_selectedYear == null) {
        _showErrorDialog('Pilih tahun terlebih dahulu');
      }
      return;
    }
    setState(() => _saving = true);
    try {
      final bulanTahun = '${_selectedMonth.toString().padLeft(2, '0')}-$_selectedYear';
      await TagihanService.updateTagihan(
        widget.tagihan.id,
        pelangganId: _selected!.id,
        bulanTahun: bulanTahun,
        statusPembayaran: _status,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Tagihan berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog('Gagal memperbarui tagihan: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Berhasil'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Gagal'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Edit Tagihan'),
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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Tagihan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      DropdownButtonFormField<Pelanggan>(
                        value: _selected,
                        decoration: InputDecoration(
                          labelText: 'Pelanggan',
                          prefixIcon: const Icon(Icons.person, color: AppColors.primaryRed),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        items: _pelanggans.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (v) => setState(() => _selected = v),
                        validator: (v) => v == null ? 'Pilih pelanggan' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<int>(
                        value: _selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'Bulan',
                          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        items: _months.map((m) => DropdownMenuItem<int>(value: m['value'] as int, child: Text(m['name'] as String))).toList(),
                        onChanged: (v) => setState(() => _selectedMonth = v),
                        validator: (v) => v == null ? 'Pilih bulan' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Tahun',
                          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                        onChanged: (v) => setState(() => _selectedYear = v),
                        validator: (v) => v == null ? 'Pilih tahun' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(Icons.payment, color: AppColors.primaryRed),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        items: ['belum_dibayar', 'menunggu_verifikasi', 'lunas']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                        validator: (v) => v == null ? 'Pilih status' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _saving
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
                            onPressed: _saving ? null : _update,
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}