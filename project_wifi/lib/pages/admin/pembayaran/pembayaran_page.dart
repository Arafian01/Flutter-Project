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
  AnimationController? _controller; // Made nullable to handle disposal
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _load();
    _checkSuccessMessage();
    _initializeController();
  }

  void _initializeController() {
    if (mounted) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
      );
      _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
      );
      _controller?.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null; // Clear reference
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = PembayaranService.fetchPembayarans();
      if (_controller != null && mounted) {
        _controller?.reset();
        _controller?.forward();
      }
    });
  }

  Future<void> _checkSuccessMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final message = prefs.getString('success_message');
    if (message != null && mounted) {
      _showSuccessDialog(message);
      await prefs.remove('success_message');
    }
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

  void _confirmDelete(int id) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.white,
        elevation: 8,
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            Text('Hapus Pembayaran', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue)),
          ],
        ),
        content: Text('Yakin ingin menghapus pembayaran ini?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryBlue)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              try {
                await PembayaranService.deletePembayaran(id);
                _load();
                _showSuccessDialog('Pembayaran berhasil dihapus');
              } catch (e) {
                _showErrorDialog('Gagal menghapus pembayaran: $e');
              }
            },
            child: Text('Hapus', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.white,
        elevation: 8,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryBlue, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            Text('Berhasil', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue)),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.white,
        elevation: 8,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            Text('Error', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue)),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Gagal memuat gambar',
                style: TextStyle(color: AppColors.textSecondaryBlue),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Manajemen Pembayaran',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: const Icon(Icons.payment, color: AppColors.white, size: AppSizes.iconSizeMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: AppSizes.iconSizeMedium),
            onPressed: _load,
            tooltip: 'Refresh Data',
          ),
        ],
        elevation: 4,
      ),
      body: FutureBuilder<List<Pembayaran>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                strokeWidth: 5,
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat pembayaran: ${snap.error}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.accentRed),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Belum ada pembayaran',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryBlue),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accentRed,
            backgroundColor: AppColors.white,
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];
                return _buildPembayaranCard(p, isSmallScreen);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_pembayaran');
          if (result == true && mounted) {
            _load();
            _checkSuccessMessage();
          }
        },
        child: const Icon(Icons.add, size: AppSizes.iconSizeMedium),
        tooltip: 'Tambah Pembayaran',
      ),
    );
  }

  Widget _buildPembayaranCard(Pembayaran p, bool isSmallScreen) {
    final imageUrl = p.image.isNotEmpty ? '${AppConstants.baseUrl}${p.image}' : null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 6,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
          margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.white, AppColors.backgroundLight.withOpacity(0.9)],
              ),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondaryBlue.withOpacity(0.2),
                child: const Icon(
                  Icons.payment,
                  size: AppSizes.iconSizeSmall,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: Text(
                p.pelangganName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${_formatBulanTahun(p.bulan, p.tahun)} • ${_formatter.format(p.harga)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryBlue,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.statusVerifikasi == 'diterima'
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : p.statusVerifikasi == 'ditolak'
                      ? AppColors.accentRed.withOpacity(0.1)
                      : AppColors.textSecondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  _formatStatus(p.statusVerifikasi),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: p.statusVerifikasi == 'diterima'
                        ? AppColors.primaryBlue
                        : p.statusVerifikasi == 'ditolak'
                        ? AppColors.accentRed
                        : AppColors.textSecondaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      _buildDetailRow('Tagihan ID', p.tagihanId.toString()),
                      _buildDetailRow('Pelanggan', p.pelangganName),
                      _buildDetailRow('Periode', _formatBulanTahun(p.bulan, p.tahun)),
                      _buildDetailRow('Harga', _formatter.format(p.harga)),
                      _buildDetailRow('Status', _formatStatus(p.statusVerifikasi)),
                      _buildDetailRow('Dikirim', _dateFormatter.format(p.tanggalKirim.toLocal())),
                      if (p.tanggalVerifikasi != null)
                        _buildDetailRow('Verifikasi', _dateFormatter.format(p.tanggalVerifikasi!.toLocal())),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Text(
                        'Bukti Pembayaran',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      imageUrl != null
                          ? GestureDetector(
                        onTap: () => _showImagePreview(imageUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          child: Image.network(
                            imageUrl,
                            height: isSmallScreen ? 120 : 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                'Gagal memuat gambar',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondaryBlue,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                          : Text(
                        'Gambar tidak tersedia',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.secondaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            icon: const Icon(Icons.edit, size: AppSizes.iconSizeSmall),
                            label: const Text('Edit'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit_pembayaran', arguments: p).then((r) {
                                if (r == true && mounted) {
                                  _load();
                                  _checkSuccessMessage();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            icon: const Icon(Icons.delete, size: AppSizes.iconSizeSmall),
                            label: const Text('Hapus'),
                            onPressed: () => _confirmDelete(p.id),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}