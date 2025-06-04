class TotalIncomeReport {
  final int bulan;
  final int tahun;
  final int totalHarga;

  TotalIncomeReport({
    required this.bulan,
    required this.tahun,
    required this.totalHarga,
  });

  factory TotalIncomeReport.fromJson(Map<String, dynamic> json) {
    return TotalIncomeReport(
      bulan: json['bulan'] as int,
      tahun: json['tahun'] as int,
      totalHarga: json['total_harga'] as int,
    );
  }
}