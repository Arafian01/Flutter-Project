// lib/models/tagihan.dart
class Tagihan {
  final int id;
  final int pelangganId;
  final String pelangganName;
  final int bulan; // Ganti dari bulanTahun
  final int tahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;
  final int harga;

  Tagihan({
    required this.id,
    required this.pelangganId,
    required this.pelangganName,
    required this.bulan,
    required this.tahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
    required this.harga,
  });

  factory Tagihan.fromJson(Map<String,dynamic> json) => Tagihan(
    id: json['id'] as int,
    pelangganId: json['pelanggan_id'] as int,
    pelangganName: json['pelanggan_name'] as String? ?? '',
    bulan: json['bulan'] as int,
    tahun: json['tahun'] as int,
    statusPembayaran: json['status_pembayaran'] as String? ?? '',
    jatuhTempo: DateTime.parse(json['jatuh_tempo'] as String),
    harga: (json['harga'] as int?) ?? 0,      // ← gunakan int? dan default 0
  );


  Map<String, dynamic> toJson() => {
    'id': id,
    'pelanggan_id': pelangganId,
    'bulan': bulan,
    'tahun': tahun,
    'harga': harga,
    'status_pembayaran': statusPembayaran,
  };
}