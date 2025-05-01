class Dashboard {
  final int totalPelanggan;
  final int totalPaket;
  final int tagihanLunas;
  final int tagihanPending;

  Dashboard({
    required this.totalPelanggan,
    required this.totalPaket,
    required this.tagihanLunas,
    required this.tagihanPending,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalPelanggan: (json['totalPelanggan'] as int?) ?? 0,
      totalPaket:     (json['totalPaket']     as int?) ?? 0,
      tagihanLunas:   (json['tagihanLunas']   as int?) ?? 0,
      tagihanPending: (json['tagihanPending'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPelanggan': totalPelanggan,
    'totalPaket': totalPaket,
    'tagihanLunas': tagihanLunas,
    'tagihanPending': tagihanPending,
  };
}
