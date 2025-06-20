import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> with SingleTickerProviderStateMixin {
  late Future<List<Tagihan>> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTagihans();
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

  void _loadTagihans() {
    setState(() {
      _future = TagihanService.fetchTagihans();
    });
  }

  String formatPeriode(int bulan, int tahun) {
    final date = DateTime(tahun, bulan);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
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

  void _showDeleteDialog(Tagihan tagihan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Hapus tagihan untuk ${formatPeriode(tagihan.bulan, tagihan.tahun)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await TagihanService.deleteTagihan(tagihan.id);
                _loadTagihans();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tagihan dihapus'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus: $e'),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagihanCard(Tagihan tagihan, int index) {
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
                '/edit_tagihan',
                arguments: tagihan,
              );
              if (result == true) _loadTagihans();
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
                      Icons.receipt,
                      size: AppSizes.iconSizeMedium,
                      color: tagihan.statusPembayaran == 'lunas' ? Colors.green : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tagihan.pelangganName ?? '-',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatPeriode(tagihan.bulan, tagihan.tahun),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(tagihan.harga),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tagihan.statusPembayaran.replaceAll('_', ' ').toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tagihan.statusPembayaran == 'lunas' ? Colors.green : AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.accentRed),
                    onPressed: () => _showDeleteDialog(tagihan),
                    tooltip: 'Hapus Tagihan',
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
            hintText: 'Cari tagihan...',
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
          'Kelola Tagihan',
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
                _loadTagihans();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<Tagihan>>(
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
                      onPressed: _loadTagihans,
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
            final tagihans = snap.data ?? [];
            final filteredTagihans = _searchQuery.isEmpty
                ? tagihans
                : tagihans
                .where((tagihan) =>
            formatPeriode(tagihan.bulan, tagihan.tahun)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
                tagihan.statusPembayaran.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                _formatRupiah(tagihan.harga).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (tagihan.pelangganName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                .toList();
            if (filteredTagihans.isEmpty) {
              return Center(
                child: Text(
                  _searchQuery.isEmpty ? 'Belum ada tagihan' : 'Tidak ada tagihan ditemukan',
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
                itemCount: filteredTagihans.length,
                itemBuilder: (ctx, i) => _buildTagihanCard(filteredTagihans[i], i),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_tagihan');
          if (result == true) _loadTagihans();
        },
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 24),
        tooltip: 'Tambah Tagihan',
      ),
    );
  }
}