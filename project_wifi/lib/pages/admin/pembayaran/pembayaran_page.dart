import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Animation<double> _scaleAnimation;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _load();
    _checkSuccessMessage();
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

  void _load() {
    setState(() {
      _future = PembayaranService.fetchPembayarans();
    });
  }

  Future<void> _checkSuccessMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final message = prefs.getString('success_message');
    if (message != null) {
      _showSuccessDialog(message);
      await prefs.remove('success_message');
    }
  }

  String _formatBulanTahun(String bulanTahun) {
    try {
      final parts = bulanTahun.split('-');
      if (parts.length != 2) return bulanTahun;
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return bulanTahun;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Hapus Pembayaran'),
          ],
        ),
        content: const Text('Yakin ingin menghapus pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PembayaranService.deletePembayaran(id);
                _load();
                _showSuccessDialog('Pembayaran berhasil dihapus');
              } catch (e) {
                _showErrorDialog('Gagal menghapus pembayaran: $e');
              }
            },
            child: Text('Hapus', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Manajemen Pembayaran'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: Icon(
          Icons.payment,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 2,
      ),
      body: FutureBuilder<List<Pembayaran>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Gagal memuat pembayaran: ${snap.error}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          final list = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final p = list[i];
              return _buildPembayaranCard(p);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_pembayaran');
          if (result == true) {
            _load();
            _checkSuccessMessage();
          }
        },
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      ),
    );
  }

  Widget _buildPembayaranCard(Pembayaran p) {
    final imageUrl = p.image.isNotEmpty ? '${AppConstants.baseUrl}${p.image}' : null;
    print('Image URL for ${p.id}: $imageUrl'); // Log untuk debugging

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
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
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.payment,
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
                        '${_formatBulanTahun(p.bulanTahun)} - ${p.pelangganName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Status: ${_formatStatus(p.statusVerifikasi)} • ${_formatter.format(p.harga)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Tagihan ID: ${p.tagihanId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Pelanggan: ${p.pelangganName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Periode: ${_formatBulanTahun(p.bulanTahun)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Harga: ${_formatter.format(p.harga)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Status: ${_formatStatus(p.statusVerifikasi)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Dikirim: ${_dateFormatter.format(p.tanggalKirim.toLocal())}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    if (p.tanggalVerifikasi != null)
                      Text(
                        'Verifikasi: ${_dateFormatter.format(p.tanggalVerifikasi!.toLocal())}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    const Text(
                      'Bukti Pembayaran:',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image for ${p.id}: $error');
                          return const Text(
                            'Gagal memuat gambar',
                            style: TextStyle(color: AppColors.white),
                          );
                        },
                      ),
                    )
                        : const Text(
                      'Gambar tidak tersedia',
                      style: TextStyle(color: AppColors.white),
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
                            Navigator.pushNamed(context, '/edit_pembayaran', arguments: p).then((r) {
                              if (r == true) {
                                _load();
                                _checkSuccessMessage();
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
                          onPressed: () => _confirmDelete(p.id),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}