// lib/models/report_item.dart
class ReportItem {
  final int pelangganId;
  final String nama;
  final Map<String, String> statusByMonth;

  ReportItem({
    required this.pelangganId,
    required this.nama,
    required this.statusByMonth,
  });

  factory ReportItem.fromJson(
      Map<String, dynamic> json, List<String> months) {
    final map = <String, String>{};
    for (final m in months) {
      map[m] = json[m] as String? ?? '-';
    }
    return ReportItem(
      pelangganId: json['pelanggan_id'] as int,
      nama: json['nama'] as String,
      statusByMonth: map,
    );
  }
}
