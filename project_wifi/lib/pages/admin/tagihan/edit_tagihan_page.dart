// lib/pages/edit_tagihan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/pelanggan.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';

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
  late TextEditingController _bulanCtrl;
  String _status = '';
  bool _saving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bulanCtrl = TextEditingController(text: widget.tagihan.bulanTahun);
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
    _bulanCtrl.dispose();
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
    if (!_formKey.currentState!.validate() || _selected == null) {
      if (_selected == null) {
        _showErrorDialog('Pilih pelanggan terlebih dahulu');
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await TagihanService.updateTagihan(
        widget.tagihan.id,
        pelangganId: _selected!.id,
        bulanTahun: _bulanCtrl.text.trim(),
        statusPembayaran: _status,
      );
      _showSuccessDialog('Tagihan berhasil diperbarui');
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
        leading: const Icon(
          Icons.wifi,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 0,
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
                        decoration: const InputDecoration(
                          labelText: 'Pelanggan',
                          prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                        ),
                        items: _pelanggans.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (v) => setState(() => _selected = v),
                        validator: (v) => v == null ? 'Pilih pelanggan' : null,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _bulanCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bulan-tahun wajib diisi';
                          }
                          if (!RegExp(r'^(0[1-9]|1[0-2])-\d{4}$').hasMatch(value)) {
                            return 'Format harus MM-YYYY (contoh: 01-2025)';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Bulan-Tahun',
                          hintText: 'MM-YYYY (contoh: 01-2025)',
                          prefixIcon: Icon(Icons.date_range, color: AppColors.textSecondary),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-1]?[0-9]?-?\d{0,4}')),
                          LengthLimitingTextInputFormatter(7),
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.payment, color: AppColors.textSecondary),
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
                            : StrongMainButton(
                          label: 'Update',
                          onTap: _update,
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