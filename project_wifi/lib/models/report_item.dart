class ReportItem {
  final String nama;
  final Map<int, String> statusByMonth;

  ReportItem({
    required this.nama,
    required this.statusByMonth,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json, List<String> monthsList) {
    final statusMap = <int, String>{};
    final data = json['data'] as Map<String, dynamic>;
    for (int i = 0; i < monthsList.length; i++) {
      final month = i + 1;
      statusMap[month] = data[month.toString()] ?? '-';
    }
    return ReportItem(
      nama: json['nama'] as String,
      statusByMonth: statusMap,
    );
  }
}