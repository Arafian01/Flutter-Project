// lib/models/paket.dart

class Paket {
  final int id;
  final String namaPaket;
  final String deskripsi;
  final double harga;

  Paket({
    required this.id,
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
  });

  /// Buat instance Paket dari JSON
  factory Paket.fromJson(Map<String, dynamic> json) {
    return Paket(
      id: json['id'] as int,
      namaPaket: json['nama_paket'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: (json['harga'] as num).toDouble(),
    );
  }

  /// Konversi Paket ke JSON untuk request
  Map<String, dynamic> toJson() {
    return {
      'nama_paket': namaPaket,
      'deskripsi': deskripsi,
      'harga': harga,
    };
  }
}