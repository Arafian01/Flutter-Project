// lib/models/tagihan.dart
class Tagihan {
  final int id;
  final int pelangganId;
  final String pelangganName;
  final String bulanTahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;

  Tagihan({
    required this.id,
    required this.pelangganId,
    required this.pelangganName,
    required this.bulanTahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      id: json['id'] as int,
      pelangganId: json['pelanggan_id'] as int,
      pelangganName: (json['name'] as String?) ?? '',
      bulanTahun: (json['bulan_tahun'] as String?) ?? '',
      statusPembayaran: (json['status_pembayaran'] as String?) ?? '',
      jatuhTempo: DateTime.parse(json['jatuh_tempo'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pelanggan_id': pelangganId,
      'bulan_tahun': bulanTahun,
      'status_pembayaran': statusPembayaran,
      'jatuh_tempo': jatuhTempo.toIso8601String(),
    };
  }
}