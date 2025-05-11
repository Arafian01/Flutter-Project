// lib/models/tagihan.dart
class Tagihan {
  final int id;
  final int pelangganId;
  final String pelangganName;
  final String bulanTahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;
  final int harga;

  Tagihan({
    required this.id,
    required this.pelangganId,
    required this.pelangganName,
    required this.bulanTahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
    required this.harga,
  });

  factory Tagihan.fromJson(Map<String,dynamic> json) => Tagihan(
    id: json['id'] as int,
    pelangganId: json['pelanggan_id'] as int,
    pelangganName: json['pelanggan_name'] as String? ?? '',
    bulanTahun: json['bulan_tahun'] as String? ?? '',
    statusPembayaran: json['status_pembayaran'] as String? ?? '',
    jatuhTempo: DateTime.parse(json['jatuh_tempo'] as String),
    harga: (json['harga'] as int?) ?? 0,      // ← gunakan int? dan default 0
  );


  Map<String, dynamic> toJson() => {
    'pelanggan_id': pelangganId,
    'bulan_tahun': bulanTahun,
    'status_pembayaran': statusPembayaran,
  };
}