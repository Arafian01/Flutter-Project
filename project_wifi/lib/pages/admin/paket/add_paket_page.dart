import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';

class AddPaketPage extends StatefulWidget {
  const AddPaketPage({Key? key}) : super(key: key);

  @override
  State<AddPaketPage> createState() => _AddPaketPageState();
}

class _AddPaketPageState extends State<AddPaketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
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
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan paket: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tambah Paket'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Paket Baru',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Utils.mainThemeColor,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      prefixIcon: Icon(Icons.label, color: Utils.mainThemeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textInputAction: TextInputAction.next,
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
                      prefixIcon: Icon(Icons.description, color: Utils.mainThemeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Harga wajib diisi';
                      }
                      if (int.tryParse(value.trim()) == null || int.parse(value.trim()) <= 0) {
                        return 'Masukkan harga yang valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      hintText: 'Masukkan harga paket',
                      prefixIcon: Icon(Icons.attach_money, color: Utils.mainThemeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Utils.mainThemeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _save,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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