import 'package:flutter/material.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class PaketPage extends StatefulWidget {
  const PaketPage({super.key});

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> with SingleTickerProviderStateMixin {
  late Future<List<Paket>> _futurePakets;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPakets();
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

  void _loadPakets() {
    _futurePakets = fetchPakets();
  }

  void _showDetailModal(Paket paket) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMedium)),
      ),
      backgroundColor: AppColors.backgroundLight,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi, color: AppColors.primaryRed, size: AppSizes.iconSizeMedium),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: Text(
                      paket.namaPaket,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                'Harga: Rp ${paket.harga.toStringAsFixed(0)}/bulan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                paket.deskripsi,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/edit_paket', arguments: paket).then((refresh) {
                        if (refresh == true) {
                          setState(_loadPakets);
                          _showSuccessDialog('Paket berhasil diperbarui');
                        }
                      });
                    },
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(paket.id);
                    },
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.primaryRed),
              const SizedBox(width: AppSizes.paddingSmall),
              const Text('Konfirmasi Hapus'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin menghapus paket ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await deletePaket(id);
                  setState(_loadPakets);
                  _showSuccessDialog('Paket berhasil dihapus');
                } catch (e) {
                  _showErrorDialog('Gagal menghapus paket: $e');
                }
              },
              child: Text('Hapus', style: TextStyle(color: AppColors.primaryRed)),
            ),
          ],
        );
      },
    );
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
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Paket>>(
              future: _futurePakets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat paket: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final pakets = snapshot.data!;
                return isSmallScreen
                    ? ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: pakets.length,
                  itemBuilder: (context, index) {
                    return _buildPaketCard(pakets[index]);
                  },
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.paddingMedium,
                    mainAxisSpacing: AppSizes.paddingMedium,
                    childAspectRatio: 4 / 3,
                  ),
                  itemCount: pakets.length,
                  itemBuilder: (context, index) {
                    return _buildPaketCard(pakets[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_paket');
          if (result == true) {
            setState(_loadPakets);
            _showSuccessDialog('Paket berhasil ditambahkan');
          }
        },
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingMedium,
        horizontal: AppSizes.paddingLarge,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.secondaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            size: AppSizes.iconSizeMedium,
            color: AppColors.white,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            'Daftar Paket',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaketCard(Paket paket) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () => _showDetailModal(paket),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryRed, AppColors.secondaryRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.wifi,
                      size: AppSizes.iconSizeMedium,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          paket.namaPaket,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          paket.deskripsi,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    'Rp ${paket.harga.toStringAsFixed(0)}/bulan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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
}