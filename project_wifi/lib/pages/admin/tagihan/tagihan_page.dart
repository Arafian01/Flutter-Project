import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Animation<double> _scaleAnimation;
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
      _future = TagihanService.fetchTagihans();
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
      final year = parts[1];
      final date = DateTime(int.parse(year), month);
      return DateFormat('MMMM-yyyy', 'id_ID').format(date);
    } catch (e) {
      return bulanTahun;
    }
  }

  void _showDetail(Tagihan t) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMedium)),
      ),
      backgroundColor: AppColors.backgroundLight,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: AppColors.primaryRed, size: AppSizes.iconSizeMedium),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'Pelanggan: ${t.pelangganName}',
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
              'Periode: ${_formatBulanTahun(t.bulanTahun)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'Status: ${t.statusPembayaran.replaceAll('_', ' ').toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'Jatuh Tempo: ${t.jatuhTempo.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              'Harga: ${_formatter.format(t.harga)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
                    Navigator.pushNamed(context, '/edit_tagihan', arguments: t).then((r) {
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
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(t.id);
                  },
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            const Text('Hapus Tagihan'),
          ],
        ),
        content: const Text('Yakin ingin menghapus tagihan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await TagihanService.deleteTagihan(id);
                _load();
                _showSuccessDialog('Tagihan berhasil dihapus');
              } catch (e) {
                _showErrorDialog('Gagal menghapus tagihan: $e');
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
        title: const Text('Daftar Tagihan'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: Icon(
          Icons.receipt,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Tagihan>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat tagihan: ${snap.error}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final t = list[i];
                    return _buildTagihanCard(t);
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
          final result = await Navigator.pushNamed(context, '/add_tagihan');
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

  Widget _buildTagihanCard(Tagihan t) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () => _showDetail(t),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.receipt,
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
                          '${_formatBulanTahun(t.bulanTahun)} - ${t.pelangganName}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          'Status: ${t.statusPembayaran.replaceAll('_', ' ').toUpperCase()} • ${_formatter.format(t.harga)}',
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
            ),
          ),
        ),
      ),
    );
  }
}