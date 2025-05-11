// lib/models/tagihan.dart

class Tagihan {
  final int? id;
  final int pelangganId;
  final String name;           // nama pelanggan
  final String bulanTahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;
  final int harga;

  Tagihan({
    this.id,
    required this.pelangganId,
    required this.name,
    required this.bulanTahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
    required this.harga,
  });

  /// Buat instance Tagihan dari satu baris hasil SQL query
  factory Tagihan.fromRow(List<dynamic> row) {
    dynamic parseDate(dynamic v) =>
        v is DateTime ? v : DateTime.parse(v as String);

    return Tagihan(
      id: row[0] as int?,
      pelangganId: row[1] as int,
      name: row[2] as String,
      bulanTahun: row[3] as String,
      statusPembayaran: row[4] as String,
      jatuhTempo: parseDate(row[5]),
      harga: row[6] as int,
    );
  }

  /// Buat instance Tagihan dari JSON (response API)
  factory Tagihan.fromJson(Map<String, dynamic> json) => Tagihan(
        id: json['id'] as int?,
        pelangganId: json['pelanggan_id'] as int,
        name: json['pelanggan_name'] as String,
        bulanTahun: json['bulan_tahun'] as String,
        statusPembayaran: json['status_pembayaran'] as String,
        jatuhTempo: DateTime.parse(json['jatuh_tempo'] as String),
        harga: json['harga'] as int,
      );

  /// Konversi Tagihan ke JSON untuk request/response
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pelanggan_id': pelangganId,
        'pelanggan_name': name,
        'bulan_tahun': bulanTahun,
        'status_pembayaran': statusPembayaran,
        'jatuh_tempo': jatuhTempo.toIso8601String(),
        'harga': harga,
      };
}
