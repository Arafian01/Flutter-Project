import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../models/pelanggan.dart';
import '../../../services/api_service.dart';
import '/utils/utils.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> with SingleTickerProviderStateMixin {
  late Future<List<Pelanggan>> _pelangganFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPelanggan();
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

  void _loadPelanggan() {
    _pelangganFuture = fetchPelanggans();
  }

  void _showDeleteDialog(Pelanggan pelanggan) {
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
        content: Text('Hapus pelanggan ${pelanggan.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await deletePelanggan(pelanggan.id);
                setState(_loadPelanggan);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pelanggan dihapus')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganCard(Pelanggan pelanggan, int index) {
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
                '/edit_pelanggan',
                arguments: pelanggan,
              );
              if (result == true) setState(_loadPelanggan);
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
                      Icons.person,
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
                          pelanggan.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pelanggan.email,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          pelanggan.namaPaket,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.accentRed),
                    onPressed: () => _showDeleteDialog(pelanggan),
                    tooltip: 'Hapus Pelanggan',
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
        title: const Text('Kelola Pelanggan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_loadPelanggan),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Pelanggan>>(
        future: _pelangganFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final pelanggans = snap.data!;
          if (pelanggans.isEmpty) {
            return const Center(child: Text('Belum ada pelanggan'));
          }
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: pelanggans.length,
              itemBuilder: (ctx, i) => _buildPelangganCard(pelanggans[i], i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_pelanggan');
          if (result == true) setState(_loadPelanggan);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Pelanggan',
      ),
    );
  }
}