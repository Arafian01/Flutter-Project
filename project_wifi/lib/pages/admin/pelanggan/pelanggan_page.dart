import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';
import '../../../models/pelanggan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> with SingleTickerProviderStateMixin {
  late Future<List<Pelanggan>> _pelangganFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPelanggan();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  void _loadPelanggan() {
    setState(() {
      _pelangganFuture =fetchPelanggans();
    });
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

  void _showDeleteDialog(Pelanggan pelanggan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.accentRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Hapus',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Hapus pelanggan ${pelanggan.name}?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryBlue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await deletePelanggan(pelanggan.id);
                if (mounted) {
                  _loadPelanggan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Pelanggan dihapus'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: AppColors.accentRed,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Hapus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganCard(Pelanggan pelanggan, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.white,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/edit_pelanggan',
                  arguments: pelanggan,
                );
                if (result == true && mounted) {
                  _loadPelanggan();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pelanggan.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pelanggan.email,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryBlue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pelanggan.namaPaket ?? '-',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryBlue,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pelanggan.status ?? '-',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: pelanggan.status == 'aktif' ? Colors.green : AppColors.accentRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.accentRed, size: 24),
                      onPressed: () => _showDeleteDialog(pelanggan),
                      tooltip: 'Hapus Pelanggan',
                    ),
                  ],
                ),
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
            hintText: 'Cari pelanggan...',
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
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => setState(() => _searchQuery = value.trim()),
        )
            : const Text(
          'Kelola Pelanggan',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
                _loadPelanggan();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<Pelanggan>>(
          future: _pelangganFuture,
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
                      onPressed: _loadPelanggan,
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
            final pelanggans = snap.data ?? [];
            final filteredPelanggans = _searchQuery.isEmpty
                ? pelanggans
                : pelanggans
                .where((pelanggan) =>
            pelanggan.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                pelanggan.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (pelanggan.namaPaket?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                .toList();
            if (filteredPelanggans.isEmpty) {
              return Center(
                child: Text(
                  _searchQuery.isEmpty ? 'Belum ada pelanggan' : 'Tidak ada pelanggan ditemukan',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryBlue,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPelanggans.length,
                itemBuilder: (ctx, i) => _buildPelangganCard(filteredPelanggans[i], i),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_pelanggan');
          if (result == true && mounted) {
            _loadPelanggan();
          }
        },
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 24),
        tooltip: 'Tambah Pelanggan',
      ),
    );
  }
}