// lib/pages/edit_paket_page.dart
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';

class EditPaketPage extends StatefulWidget {
  final Paket paket;
  const EditPaketPage({super.key, required this.paket});

  @override
  State<EditPaketPage> createState() => _EditPaketPageState();
}

class _EditPaketPageState extends State<EditPaketPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paket.namaPaket);
    _descController = TextEditingController(text: widget.paket.deskripsi);
    _priceController = TextEditingController(text: widget.paket.harga.toString());
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
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final paket = Paket(
        id: widget.paket.id,
        namaPaket: _nameController.text.trim(),
        deskripsi: _descController.text.trim(),
        harga: int.parse(_priceController.text.trim()),
      );
      await updatePaket(paket.id, paket);
      _showSuccessDialog('Paket berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog('Gagal memperbarui paket: $e');
    } finally {
      setState(() => _isSaving = false);
    }
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text('Edit Paket'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: const Icon(
          Icons.wifi,
          color: AppColors.white,
          size: AppSizes.iconSizeMedium,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Paket',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama paket wajib diisi';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nama Paket',
                          hintText: 'Masukkan nama paket',
                          prefixIcon: Icon(Icons.label, color: AppColors.textSecondary),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _descController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Masukkan deskripsi paket',
                          prefixIcon: Icon(Icons.description, color: AppColors.textSecondary),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      TextFormField(
                        controller: _priceController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Masukkan harga yang valid';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          hintText: 'Masukkan harga paket',
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSaving
                            ? const Center(child: CircularProgressIndicator())
                            : StrongMainButton(
                          label: 'Update',
                          onTap: _update,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}