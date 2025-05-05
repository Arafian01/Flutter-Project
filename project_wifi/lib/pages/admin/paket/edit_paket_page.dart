// lib/pages/edit_paket_page.dart
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';
import '../../../models/paket.dart';
import '../../../services/api_service.dart';

class EditPaketPage extends StatefulWidget {
  final Paket paket;
  const EditPaketPage({Key? key, required this.paket}) : super(key: key);

  @override
  State<EditPaketPage> createState() => _EditPaketPageState();
}

class _EditPaketPageState extends State<EditPaketPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paket.namaPaket);
    _descController = TextEditingController(text: widget.paket.deskripsi);
    _priceController = TextEditingController(text: widget.paket.harga.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
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
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update paket: \$e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Paket'),
        backgroundColor: Utils.mainThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Utils.generateInputField(
                hintText: 'Nama Paket',
                iconData: Icons.label,
                controller: _nameController,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              Utils.generateInputField(
                hintText: 'Deskripsi',
                iconData: Icons.description,
                controller: _descController,
                isPassword: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              Utils.generateInputField(
                hintText: 'Harga',
                iconData: Icons.attach_money,
                controller: _priceController,
                isPassword: false,
                onChanged: (_) {},
              ),
              const Spacer(),
              _isSaving
                  ? const CircularProgressIndicator()
                  : StrongMainButton(
                label: 'Update',
                onTap: _update,
              ),
            ],
          ),
        ),
      ),
    );
  }
}