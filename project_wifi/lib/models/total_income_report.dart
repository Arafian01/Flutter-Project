class TotalIncomeReport {
  final String month;
  final int totalHarga;

  TotalIncomeReport({
    required this.month,
    required this.totalHarga,
  });

  factory TotalIncomeReport.fromJson(Map<String, dynamic> json) {
    return TotalIncomeReport(
      month: json['month'] as String,
      totalHarga: json['total_harga'] as int,
    );
  }
}