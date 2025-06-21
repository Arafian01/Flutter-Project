import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../models/pembayaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> with SingleTickerProviderStateMixin {
  late Future<List<Pembayaran>> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _debounce;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
    _checkSuccessMessage();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = PembayaranService.fetchPembayarans();
    });
  }

  Future<void> _checkSuccessMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final message = prefs.getString('success_message');
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      await prefs.remove('success_message');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
        });
      }
    });
  }

  String _formatBulanTahun(int month, int year) {
    try {
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '$month-$year';
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }



  Widget _buildPembayaranCard(Pembayaran pembayaran, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 300),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/pembayaran_detail',
                arguments: pembayaran,
              );
              if (result == true && mounted) {
                _load();
                _checkSuccessMessage();
              }
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment,
                      size: AppSizes.iconSizeMedium,
                      color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pembayaran.pelangganName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatBulanTahun(pembayaran.bulan, pembayaran.tahun),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatter.format(pembayaran.harga),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatStatus(pembayaran.statusVerifikasi),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: pembayaran.statusVerifikasi == 'diterima' ? Colors.green : AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Cari pembayaran...',
            hintStyle: TextStyle(color: AppColors.white.withOpacity(0.6)),
            border: InputBorder.none,
            prefixIcon: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                });
              },
              tooltip: 'Kembali',
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.white, size: 24),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
                : const Icon(Icons.search, color: AppColors.white, size: 24),
          ),
        )
            : const Text(
          'Manajemen Pembayaran',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.white,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.white, size: 24),
              onPressed: () => setState(() => _isSearching = true),
              tooltip: 'Cari',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white, size: 24),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _isSearching = false;
                _load();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<Pembayaran>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                ),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gagal memuat data: ${snap.error}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            final pembayarans = snap.data ?? [];
            final filteredPembayarans = _searchQuery.isEmpty
                ? pembayarans
                : pembayarans
                .where((p) =>
            p.pelangganName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                _formatBulanTahun(p.bulan, p.tahun).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                _formatter.format(p.harga).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                _formatStatus(p.statusVerifikasi).toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
            if (filteredPembayarans.isEmpty) {
              return Center(
                child: Text(
                  _searchQuery.isEmpty ? 'Belum ada pembayaran' : 'Tidak ada pembayaran ditemukan',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryBlue,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: filteredPembayarans.length,
                itemBuilder: (ctx, i) => _buildPembayaranCard(filteredPembayarans[i], i),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_pembayaran');
          if (result == true && mounted) {
            _load();
            _checkSuccessMessage();
          }
        },
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 24),
        tooltip: 'Tambah Pembayaran',
      ),
    );
  }
}