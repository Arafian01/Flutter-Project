import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/pelanggan.dart';
import '../../../utils/utils.dart';

class AddTagihanPage extends StatefulWidget {
  const AddTagihanPage({Key? key}) : super(key: key);

  @override
  State<AddTagihanPage> createState() => _AddTagihanPageState();
}

class _AddTagihanPageState extends State<AddTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  Pelanggan? _selectedPelanggan;
  List<Pelanggan> _pelanggans = [];
  int? _bulan;
  int? _tahun;
  bool _isLoading = false;
  String _statusPembayaran = 'belum_dibayar';

  // Daftar nama bulan untuk dropdown dengan tipe eksplisit
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
    _loadPelanggans();
  }

  Future<void> _loadPelanggans() async {
    try {
      final pelanggans = await fetchPelanggans();
      setState(() => _pelanggans = pelanggans);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveTagihan() async {
    if (_formKey.currentState!.validate() && _selectedPelanggan != null && _bulan != null && _tahun != null) {
      setState(() => _isLoading = true);
      try {
        await TagihanService.createTagihan(
          pelangganId: _selectedPelanggan!.id,
          bulan: _bulan!,
          tahun: _tahun!,
          statusPembayaran: _statusPembayaran,
        );
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tagihan dibuat')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Tambah Tagihan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<Pelanggan>(
                  decoration: const InputDecoration(
                    labelText: 'Pelanggan',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _pelanggans
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPelanggan = value),
                  validator: (value) => value == null ? 'Pilih pelanggan' : null,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Bulan',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: _bulanOptions
                      .map((m) => DropdownMenuItem<int>(
                    value: m['nomor'] as int,
                    child: Text(m['nama'] as String),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _bulan = value),
                  validator: (value) => value == null ? 'Pilih bulan' : null,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: List.generate(11, (i) => DateTime.now().year - 5 + i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (value) => setState(() => _tahun = value),
                  validator: (value) => value == null ? 'Pilih tahun' : null,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status Pembayaran',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  value: _statusPembayaran,
                  items: ['belum_dibayar', 'menunggu_verifikasi', 'lunas']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _statusPembayaran = value!),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _saveTagihan,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}