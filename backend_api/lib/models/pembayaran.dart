class Pembayaran {
  final int id;
  final int? tagihanId;        // boleh null
  final String bulanTahun;      // format MM-YYYY
  final int pelangganId;
  final String image;
  final String tanggalKirim;    // ISO date string
  final String statusVerifikasi;
  final String? tanggalVerifikasi; // boleh null
  final int harga;              // diambil dari pelanggan→paket

  Pembayaran({
    required this.id,
    this.tagihanId,
    required this.bulanTahun,
    required this.pelangganId,
    required this.image,
    required this.tanggalKirim,
    required this.statusVerifikasi,
    this.tanggalVerifikasi,
    required this.harga,
  });

  factory Pembayaran.fromRow(List row) {
    String fmtDate(dynamic v) =>
        v is DateTime ? v.toIso8601String().split('T')[0] : v as String;

    return Pembayaran(
      id: row[0] as int,
      tagihanId: row[1] as int?,                   
      bulanTahun: row[2] as String,               
      pelangganId: row[3] as int,                 
      image: row[4] as String,
      tanggalKirim: fmtDate(row[5]),
      statusVerifikasi: row[6] as String,
      tanggalVerifikasi:
        row[7] != null ? fmtDate(row[7]) : null,
      harga: row[8] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (tagihanId != null) 'tagihan_id': tagihanId,
    'bulan_tahun': bulanTahun,
    'pelanggan_id': pelangganId,
    'image': image,
    'tanggal_kirim': tanggalKirim,
    'status_verifikasi': statusVerifikasi,
    if (tanggalVerifikasi != null) 'tanggal_verifikasi': tanggalVerifikasi,
    'harga': harga,
  };
}
