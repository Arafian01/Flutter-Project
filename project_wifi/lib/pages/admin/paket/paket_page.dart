import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class PaketPage extends StatefulWidget {
  const PaketPage({super.key});

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> with SingleTickerProviderStateMixin {
  late Future<List<Paket>> _future;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPakets();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  void _loadPakets() {
    _future = fetchPakets();
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  void _showDeleteDialog(Paket paket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.accentRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Hapus paket ${paket.namaPaket}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await deletePaket(paket.id);
                setState(_loadPakets);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Paket dihapus'),
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

  Widget _buildPaketCard(Paket paket, int index) {
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
                '/edit_paket',
                arguments: paket,
              );
              if (result == true) setState(_loadPakets);
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
                    child: const Icon(
                      Icons.wifi,
                      size: AppSizes.iconSizeMedium,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paket.namaPaket,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(paket.harga ?? 0),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.accentRed),
                    onPressed: () => _showDeleteDialog(paket),
                    tooltip: 'Hapus Paket',
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
        title: const Text('Kelola Paket'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_loadPakets),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Paket>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final pakets = snap.data!;
          if (pakets.isEmpty) {
            return const Center(child: Text('Belum ada paket'));
          }
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: pakets.length,
              itemBuilder: (ctx, i) => _buildPaketCard(pakets[i], i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_paket');
          if (result == true) setState(_loadPakets);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Paket',
      ),
    );
  }
}