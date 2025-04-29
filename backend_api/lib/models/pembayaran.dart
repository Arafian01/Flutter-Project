// lib/models/pembayaran.dart

class Pembayaran {
  final int? id;
  final int tagihanId;
  final String bulanTahun;
  final String imageName;
  final DateTime tanggalKirim;
  final int userId;
  final String name;
  final String statusVerifikasi;
  final DateTime? tanggalVerifikasi;

  Pembayaran({
    this.id,
    required this.tagihanId,
    required this.bulanTahun,
    required this.imageName,
    required this.tanggalKirim,
    required this.userId,
    required this.name,
    required this.statusVerifikasi,
    this.tanggalVerifikasi,
  });

  /// Creates a Pembayaran object from a database row.
  factory Pembayaran.fromRow(List<dynamic> row) {
    DateTime parseDate(dynamic v) =>
        v is DateTime ? v : DateTime.parse(v as String);
    DateTime? parseNullable(dynamic v) =>
        v == null ? null : parseDate(v);

    return Pembayaran(
      id: row[0] as int?,
      tagihanId: row[1] as int,
      bulanTahun: row[2] as String,
      imageName: row[3] as String,
      tanggalKirim: parseDate(row[4]),
      userId: row[5] as int,
      name: row[6] as String,
      statusVerifikasi: row[7] as String,
      tanggalVerifikasi: parseNullable(row[8]),
    );
  }

  /// Converts the object to JSON for API responses.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      if (id != null) 'id': id,
      'tagihan_id': tagihanId,
      'bulan_tahun': bulanTahun,
      'image_name': imageName,
      'tanggal_kirim': tanggalKirim.toIso8601String(),
      'user_id': userId,
      'name': name,
      'status_verifikasi': statusVerifikasi,
    };
    if (tanggalVerifikasi != null) {
      map['tanggal_verifikasi'] = tanggalVerifikasi!.toIso8601String();
    }
    return map;
  }
}