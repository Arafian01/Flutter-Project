// lib/models/dashboard_user.dart

class DashboardUser {
  final int totalTagihan;
  final int tagihanLunas;
  final int tagihanPending;
  final String? paketAktif;
  final String statusAkun;
  final DateTime? tanggalAktif;
  final DateTime? tanggalLangganan;

  DashboardUser({
    required this.totalTagihan,
    required this.tagihanLunas,
    required this.tagihanPending,
    this.paketAktif,
    required this.statusAkun,
    this.tanggalAktif,
    this.tanggalLangganan,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) => s == null ? null : DateTime.parse(s);

    return DashboardUser(
      totalTagihan: json['total_tagihan'] as int? ?? 0,
      tagihanLunas: json['tagihan_lunas'] as int? ?? 0,
      tagihanPending: json['tagihan_pending'] as int? ?? 0,
      paketAktif: json['paket_aktif'] as String?,
      statusAkun: json['status_akun'] as String? ?? '',
      tanggalAktif: parse(json['tanggal_aktif'] as String?),
      tanggalLangganan: parse(json['tanggal_langganan'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_tagihan': totalTagihan,
    'tagihan_lunas': tagihanLunas,
    'tagihan_pending': tagihanPending,
    'paket_aktif': paketAktif,
    'status_akun': statusAkun,
    'tanggal_aktif': tanggalAktif?.toIso8601String(),
    'tanggal_langganan': tanggalLangganan?.toIso8601String(),
  };
}
