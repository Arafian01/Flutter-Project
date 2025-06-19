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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.accentRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'Gagal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryBlue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Tambah Paket',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama paket wajib diisi';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nama Paket',
                              hintText: 'Masukkan nama paket',
                              prefixIcon: const Icon(Icons.label, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi wajib diisi';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              hintText: 'Masukkan deskripsi paket',
                              prefixIcon: const Icon(Icons.description, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
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
                            decoration: InputDecoration(
                              labelText: 'Harga',
                              hintText: 'Masukkan harga paket',
                              prefixIcon: const Icon(Icons.attach_money, color: AppColors.secondaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              labelStyle: const TextStyle(color: AppColors.textSecondaryBlue),
                            ),
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSaving
                          ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 4,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}