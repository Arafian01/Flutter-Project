// lib/models/dashboard.dart
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

  factory Dashboard.fromRow(List<List<dynamic>> rows) {
    return Dashboard(
      pelanggan: rows[0][0] as int,
      paketAktif: rows[1][0] as int,
      tagihanLunas: rows[2][0] as int,
      pendingBayar: rows[3][0] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'pelanggan': pelanggan,
        'paket_aktif': paketAktif,
        'tagihan_lunas': tagihanLunas,
        'pending_bayar': pendingBayar,
      };
}
