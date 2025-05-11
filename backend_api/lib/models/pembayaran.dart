class Pembayaran {
  final int id;
  final int tagihanId;
  final String image;
  final DateTime tanggalKirim;
  final String statusVerifikasi;
  final DateTime? tanggalVerifikasi;
  final String pelangganName;
  final String bulanTahun;
  final int harga;

  Pembayaran({
    required this.id,
    required this.tagihanId,
    required this.image,
    required this.tanggalKirim,
    required this.statusVerifikasi,
    this.tanggalVerifikasi,
    required this.pelangganName,
    required this.bulanTahun,
    required this.harga,
  });

  factory Pembayaran.fromRow(List row) {
    DateTime parseDate(dynamic v) =>
        v is DateTime ? v : DateTime.parse(v as String);

    return Pembayaran(
      id: row[0] as int,
      tagihanId: row[1] as int,
      image: row[2] as String,
      tanggalKirim: parseDate(row[3]),
      statusVerifikasi: row[4] as String,
      tanggalVerifikasi:row[5] != null ? parseDate(row[5]) : null,
      pelangganName: row[6] as String,
      bulanTahun: row[7] as String,
      harga: row[8] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tagihan_id': tagihanId,
        'image': image,
        'tanggal_kirim': tanggalKirim.toIso8601String(),
        'status_verifikasi': statusVerifikasi,
        if (tanggalVerifikasi != null)
          'tanggal_verifikasi': tanggalVerifikasi!.toIso8601String(),
        'pelanggan_name': pelangganName,
        'bulan_tahun': bulanTahun,
        'harga': harga,
      };
}
