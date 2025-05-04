// lib/models/pelanggan.dart
import 'dart:convert';

class Pelanggan {
  final int id;
  final int userId;
  final int paketId;
  final String name;
  final String email;
  final String namaPaket;
  final String status;
  final String alamat;
  final String telepon;
  final DateTime tanggalAktif;
  final DateTime tanggalLangganan;

  Pelanggan({
    required this.id,
    required this.userId,
    required this.paketId,
    required this.name,
    required this.email,
    required this.namaPaket,
    required this.status,
    required this.alamat,
    required this.telepon,
    required this.tanggalAktif,
    required this.tanggalLangganan,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    paketId: json['paket_id'] as int,
    name: (json['name'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    namaPaket: (json['nama_paket'] as String?) ?? '',
    status: (json['status'] as String?) ?? '',
    alamat: (json['alamat'] as String?) ?? '',
    telepon: (json['telepon'] as String?) ?? '',
    tanggalAktif: json['tanggal_aktif'] != null
        ? DateTime.parse(json['tanggal_aktif'] as String)
        : DateTime.fromMillisecondsSinceEpoch(0),
    tanggalLangganan: json['tanggal_langganan'] != null
        ? DateTime.parse(json['tanggal_langganan'] as String)
        : DateTime.fromMillisecondsSinceEpoch(0),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'paket_id': paketId,
    'name': name,
    'email': email,
    'password': null, // handled separately
    'status': status,
    'alamat': alamat,
    'telepon': telepon,
    'tanggal_aktif': tanggalAktif.toIso8601String(),
    'tanggal_langganan': tanggalLangganan.toIso8601String(),
  };
}