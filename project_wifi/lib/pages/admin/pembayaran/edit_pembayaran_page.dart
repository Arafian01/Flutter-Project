// lib/pages/edit_pembayaran_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/pembayaran.dart';
import '../../../models/tagihan.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/strong_main_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditPembayaranPage extends StatefulWidget {
  final Pembayaran pembayaran;
  const EditPembayaranPage({Key? key, required this.pembayaran}) : super(key: key);
  @override State<EditPembayaranPage> createState() => _EditPembayaranPageState();
}
class _EditPembayaranPageState extends State<EditPembayaranPage> {
  final _storage = const FlutterSecureStorage();
  List<Tagihan> _tagihans = [];
  Tagihan? _sel;
  String _status = '';
  File? _image;
  bool _saving = false;

  @override void initState() {
    super.initState();
    _status = widget.pembayaran.statusVerifikasi;
    _load();
  }
  void _load() async {
    _tagihans = await fetchTagihans();
    _sel = _tagihans.firstWhere((t) => t.id == widget.pembayaran.tagihanId);
    setState((){});
  }
  Future _pickImage() async { final f=await ImagePicker().pickImage(source:ImageSource.gallery); if(f!=null) setState(()=>_image=File(f.path)); }
  Future _update() async {
    setState(()=>_saving=true);
    try{
      final stored = await _storage.read(key: 'user_id');
      final adminId = stored == null ? 0 : int.parse(stored);

      await updatePembayaran(
          id:widget.pembayaran.id,
          status:_status,
          adminId: adminId,
          imageFile:_image);
      Navigator.pop(context,true);
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Error: $e')));
    } finally{
      setState(()=>_saving=false);
    }
  }
  @override Widget build(BuildContext c)=>
      Scaffold(
        appBar:AppBar(
            title:const Text('Edit Pembayaran'),
            backgroundColor:Utils.mainThemeColor),
        body:Padding(
            padding:const EdgeInsets.all(16),
            child:ListView(
                children:[
    DropdownButtonFormField<Tagihan>(
        value:_sel,
        decoration:const InputDecoration(
            labelText:'Tagihan'),
        items:_tagihans.map((t)=>DropdownMenuItem(
            value:t,child:Text(t.bulanTahun))).toList(),onChanged:null),
    const SizedBox(height:12),
    DropdownButtonFormField<String>(
        value:_status,
        decoration:const InputDecoration(
            labelText:'Status'),
        items:['menunggu verifikasi','diterima','ditolak'].map((s)=>DropdownMenuItem(
            value:s,
            child:Text(s))).toList(),onChanged:(v)=>setState(()=>_status=v!)),
    const SizedBox(height:12),ListTile(title:Text(_image!=null?_image!.path.split('/').last:'Ganti Bukti'),trailing:const Icon(Icons.image),onTap:_pickImage),
    const SizedBox(height:20),_saving?Center(child:CircularProgressIndicator()):StrongMainButton(label:'Update',onTap:_update)
  ])),);
}
