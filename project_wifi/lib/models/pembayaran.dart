// lib/models/pembayaran.dart
class Pembayaran {
  final int id;
  final int tagihanId;
  final String bulanTahun;
  final String image;
  final DateTime tanggalKirim;
  final int? adminId;
  final String? adminName;
  final int pelangganUserId;
  final String pelangganName;
  final String statusVerifikasi;
  final DateTime? tanggalVerifikasi;

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

  factory Pembayaran.fromJson(Map<String, dynamic> json) => Pembayaran(
    id: json['id'] as int,
    tagihanId: json['tagihan_id'] as int,
    bulanTahun: (json['bulan_tahun'] as String?) ?? '',
    image: (json['image'] as String?) ?? '',
    tanggalKirim: DateTime.parse(json['tanggal_kirim'] as String),
    adminId: json['admin_id'] as int?,
    adminName: json['admin_name'] as String?,
    pelangganUserId: json['pelanggan_user_id'] as int,
    pelangganName: (json['pelanggan_name'] as String?) ?? '',
    statusVerifikasi: (json['status_verifikasi'] as String?) ?? '',
    tanggalVerifikasi: json['tanggal_verifikasi'] != null
        ? DateTime.parse(json['tanggal_verifikasi'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tagihan_id': tagihanId,
    'bulan_tahun': bulanTahun,
    'image': image,
    'tanggal_kirim': tanggalKirim.toIso8601String(),
    'admin_id': adminId,
    'status_verifikasi': statusVerifikasi,
    'tanggal_verifikasi': tanggalVerifikasi?.toIso8601String(),
  };
}
