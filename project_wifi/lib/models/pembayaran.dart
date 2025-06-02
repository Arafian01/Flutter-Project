class Pembayaran {
  final int id;
  final int tagihanId;             // sekarang wajib
  final int bulan; // Ganti dari bulanTahun
  final int tahun;
  final String image;
  final DateTime tanggalKirim;
  final String statusVerifikasi;
  final DateTime? tanggalVerifikasi;
  final String pelangganName;
  final int harga;

  Pembayaran({
    required this.id,
    required this.tagihanId,
    required this.bulan,
    required this.tahun,
    required this.image,
    required this.tanggalKirim,
    required this.statusVerifikasi,
    this.tanggalVerifikasi,
    required this.pelangganName,
    required this.harga,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) =>
        s == null ? null : DateTime.parse(s);

    return Pembayaran(
      id: json['id'] as int,
      tagihanId: json['tagihan_id'] as int,                  // non-null
      bulan: json['bulan'] as int,
      tahun: json['tahun'] as int,
      image: json['image'] as String? ?? '',
      tanggalKirim: DateTime.parse(json['tanggal_kirim'] as String),
      statusVerifikasi: json['status_verifikasi'] as String? ?? '',
      tanggalVerifikasi: parseDate(json['tanggal_verifikasi'] as String?),
      pelangganName: json['pelanggan_name'] as String? ?? '',
      harga: (json['harga'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagihan_id': tagihanId,
      'status_verifikasi': statusVerifikasi,
      // jangan kirim image/tanggal_kirim—file via multipart
    };
  }
}
