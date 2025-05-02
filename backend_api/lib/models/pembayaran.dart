// lib/models/pembayaran.dart
class Pembayaran {
  final int id;
  final int tagihanId;
  final String bulanTahun;
  final String image;
  final String tanggalKirim;
  final int? adminId;
  final String? adminName;
  final int pelangganUserId;
  final String pelangganName;
  final String statusVerifikasi;
  final String? tanggalVerifikasi;

  Pembayaran({
    required this.id,
    required this.tagihanId,
    required this.bulanTahun,
    required this.image,
    required this.tanggalKirim,
    this.adminId,
    this.adminName,
    required this.pelangganUserId,
    required this.pelangganName,
    required this.statusVerifikasi,
    this.tanggalVerifikasi,
  });

  /// Buat instance dari satu baris hasil query
  factory Pembayaran.fromRow(List row) {
    return Pembayaran(
      id: row[0] as int,
      tagihanId: row[1] as int,
      bulanTahun: row[2] as String,
      image: row[3] as String,
      tanggalKirim: (row[4] as DateTime).toIso8601String(),
      adminId: row[5] as int?,          // user_id sebagai admin yang verifikasi
      adminName: row[6] as String?,     // nama admin, bisa null
      pelangganUserId: row[9] as int,    // user_id pelanggan dari relasi
      pelangganName: row[10] as String,  // nama pelanggan
      statusVerifikasi: row[7] as String,
      tanggalVerifikasi: row[8] != null
          ? (row[8] as DateTime).toIso8601String()
          : null,
    );
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagihan_id': tagihanId,
      'bulan_tahun': bulanTahun,
      'image': image,
      'tanggal_kirim': tanggalKirim,
      'admin_id': adminId,
      'admin_name': adminName,
      'pelanggan_user_id': pelangganUserId,
      'pelanggan_name': pelangganName,
      'status_verifikasi': statusVerifikasi,
      'tanggal_verifikasi': tanggalVerifikasi,
    };
  }
}
