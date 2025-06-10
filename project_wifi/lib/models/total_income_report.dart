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
    try {
      final monthStr = json['month'] as String? ?? '';
      final parts = monthStr.split(' ');
      final monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final bulan = monthNames.indexOf(parts[0]) + 1;
      final tahun = int.parse(parts.length > 1 ? parts[1] : '${DateTime.now().year}');
      return TotalIncomeReport(
        bulan: bulan,
        tahun: tahun,
        totalHarga: (json['total_harga'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      print('Error parsing TotalIncomeReport: $e, JSON: $json');
      return TotalIncomeReport(
        bulan: 1,
        tahun: DateTime.now().year,
        totalHarga: 0,
      );
    }
  }
}