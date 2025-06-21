import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/pelanggan.dart';
import '../../../models/tagihan.dart';
import '../../../utils/utils.dart';

class EditTagihanPage extends StatefulWidget {
  final Tagihan tagihan;
  const EditTagihanPage({super.key, required this.tagihan});

  @override
  State<EditTagihanPage> createState() => _EditTagihanPageState();
}

class _EditTagihanPageState extends State<EditTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  Pelanggan? _selectedPelanggan;
  List<Pelanggan> _pelanggans = [];
  int? _bulan;
  int? _tahun;
  bool _isLoading = false;
  String _statusPembayaran = 'belum_dibayar';

  final List<Map<String, dynamic>> _bulanOptions = [
    {'nama': 'Januari', 'nomor': 1},
    {'nama': 'Februari', 'nomor': 2},
    {'nama': 'Maret', 'nomor': 3},
    {'nama': 'April', 'nomor': 4},
    {'nama': 'Mei', 'nomor': 5},
    {'nama': 'Juni', 'nomor': 6},
    {'nama': 'Juli', 'nomor': 7},
    {'nama': 'Agustus', 'nomor': 8},
    {'nama': 'September', 'nomor': 9},
    {'nama': 'Oktober', 'nomor': 10},
    {'nama': 'November', 'nomor': 11},
    {'nama': 'Desember', 'nomor': 12},
  ];

  @override
  void initState() {
    super.initState();
    _bulan = widget.tagihan.bulan;
    _tahun = widget.tagihan.tahun;
    _statusPembayaran = widget.tagihan.statusPembayaran;
    _loadPelanggans();
  }

  Future<void> _loadPelanggans() async {
    try {
      final pelanggans = await fetchPelanggans();
      setState(() {
        _pelanggans = pelanggans;
        _selectedPelanggan = pelanggans.firstWhere(
              (p) => p.id == widget.tagihan.pelangganId,
          orElse: () => pelanggans.isNotEmpty ? pelanggans.first : throw Exception('No pelanggan available'),
        );
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat pelanggan: $e');
    }
  }

  Future<void> _saveTagihan() async {
    if (!_formKey.currentState!.validate() || _selectedPelanggan == null || _bulan == null || _tahun == null) {
      _showErrorDialog('Lengkapi semua field');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await TagihanService.updateTagihan(
        widget.tagihan.id,
        pelangganId: _selectedPelanggan!.id,
        bulan: _bulan!,
        tahun: _tahun!,
        statusPembayaran: _statusPembayaran,
      );
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tagihan diperbarui'), backgroundColor: AppColors.primaryBlue),
      );
    } catch (e) {
      _showErrorDialog('Gagal memperbarui tagihan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(Icons.error_outline, color: AppColors.accentRed, size: 24),
          SizedBox(width: 8),
          Text('Error'),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.accentRed)),
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
        backgroundColor: AppColors.primaryBlue,
        title: Text('Edit Tagihan', style: TextStyle(color: AppColors.white, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      DropdownButtonFormField<Pelanggan>(
                        decoration: InputDecoration(
                          labelText: 'Pelanggan',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: _selectedPelanggan,
                        items: _pelanggans.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (value) => setState(() => _selectedPelanggan = value),
                        validator: (value) => value == null ? 'Pilih pelanggan' : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Bulan',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: _bulan,
                        items: _bulanOptions
                            .map((m) => DropdownMenuItem<int>(value: m['nomor'] as int, child: Text(m['nama'] as String)))
                            .toList(),
                        onChanged: (value) => setState(() => _bulan = value),
                        validator: (value) => value == null ? 'Pilih bulan' : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Tahun',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: _tahun,
                        items: List.generate(11, (i) => DateTime.now().year - 5 + i)
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (value) => setState(() => _tahun = value),
                        validator: (value) => value == null ? 'Pilih tahun' : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status Pembayaran',
                          prefixIcon: Icon(Icons.payment),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: _statusPembayaran,
                        items: ['belum_dibayar', 'menunggu_verifikasi', 'lunas']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                            .toList(),
                        onChanged: (value) => setState(() => _statusPembayaran = value!),
                      ),
                      SizedBox(height: 16),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTagihan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Simpan'),
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