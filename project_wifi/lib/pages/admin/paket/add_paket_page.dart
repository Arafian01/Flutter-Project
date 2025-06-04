import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/utils.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';

class AddPaketPage extends StatefulWidget {
  const AddPaketPage({super.key});

  @override
  State<AddPaketPage> createState() => _AddPaketPageState();
}

class _AddPaketPageState extends State<AddPaketPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final paket = Paket(
        id: 0,
        namaPaket: _nameController.text.trim(),
        deskripsi: _descController.text.trim(),
        harga: int.parse(_priceController.text.trim()),
      );
      await createPaket(paket);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('success_message', 'Paket berhasil ditambahkan');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal menyimpan paket: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.accentRed, size: AppSizes.iconSizeMedium),
            const SizedBox(width: AppSizes.paddingSmall),
            const Text('Gagal'),
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.accentRed)),
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
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Tambah Paket'),
        foregroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppSizes.iconSizeMedium),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
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
                        'Buat Paket Baru',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Nama paket wajib diisi';
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
                          if (value == null || value.trim().isEmpty) return 'Deskripsi wajib diisi';
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
                          if (value == null || value.trim().isEmpty) return 'Harga wajib diisi';
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) return 'Masukkan harga yang valid';
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
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed)))
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('Simpan'),
                          ),
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