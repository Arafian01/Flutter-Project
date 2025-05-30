class Tagihan {
  final int? id;
  final int pelangganId;
  final String name;
  final int bulan;
  final int tahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;
  final int harga;

  Tagihan({
    this.id,
    required this.pelangganId,
    required this.name,
    required this.bulan,
    required this.tahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
    required this.harga,
  });

  factory Tagihan.fromRow(List<dynamic> row) {
    dynamic parseDate(dynamic v) =>
        v is DateTime ? v : DateTime.parse(v as String);

    return Tagihan(
      id: row[0] as int?,
      pelangganId: row[1] as int,
      name: row[2] as String,
      bulan: row[3] as int,
      tahun: row[4] as int,
      statusPembayaran: row[5] as String,
      jatuhTempo: parseDate(row[6]),
      harga: row[7] as int,
    );
  }

  factory Tagihan.fromJson(Map<String, dynamic> json) => Tagihan(
        id: json['id'] as int?,
        pelangganId: json['pelanggan_id'] as int,
        name: json['pelanggan_name'] as String,
        bulan: json['bulan'] as int,
        tahun: json['tahun'] as int,
        statusPembayaran: json['status_pembayaran'] as String,
        jatuhTempo: DateTime.parse(json['jatuh_tempo'] as String),
        harga: json['harga'] as int,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pelanggan_id': pelangganId,
        'pelanggan_name': name,
        'bulan': bulan,
        'tahun': tahun,
        'status_pembayaran': statusPembayaran,
        'jatuh_tempo': jatuhTempo.toIso8601String(),
        'harga': harga,
      };
}