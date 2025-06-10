class ReportItem {
  final String nama;
  final Map<int, String> statusByMonth;

  ReportItem({
    required this.nama,
    required this.statusByMonth,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json, List<int> monthsList) {
    try {
      final nama = json['nama'] as String? ?? 'Unknown';
      final statusMap = <int, String>{};
      for (final month in monthsList) {
        final key = '$month-${json['tahun'] ?? DateTime.now().year}';
        statusMap[month] = json[key] as String? ?? '-';
      }
      return ReportItem(
        nama: nama,
        statusByMonth: statusMap,
      );
    } catch (e) {
      print('Error parsing ReportItem: $e, JSON: $json');
      return ReportItem(
        nama: 'Error',
        statusByMonth: {for (var m in monthsList) m: '-'},
      );
    }
  }
}