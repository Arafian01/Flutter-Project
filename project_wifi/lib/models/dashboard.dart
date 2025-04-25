class Dashboard {
  final int pelanggan;
  final int paketAktif;
  final int tagihanLunas;
  final int pendingBayar;

  Dashboard({
    required this.pelanggan,
    required this.paketAktif,
    required this.tagihanLunas,
    required this.pendingBayar,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      pelanggan: json['pelanggan'] ?? 0,
      paketAktif: json['paket_aktif'] ?? 0,
      tagihanLunas: json['tagihan_lunas'] ?? 0,
      pendingBayar: json['pending_bayar'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pelanggan': pelanggan,
      'paket_aktif': paketAktif,
      'tagihan_lunas': tagihanLunas,
      'pending_bayar': pendingBayar,
    };
  }
}
