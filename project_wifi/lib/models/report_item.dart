class ReportItem {
  final int pelangganId;
  final String nama;
  final Map<String, String> statusByMonth;

  ReportItem({
    required this.pelangganId,
    required this.nama,
    required this.statusByMonth,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json, List<String> months) {
    final statusByMonth = <String, String>{};
    for (final month in months) {
      statusByMonth[month] = json[month] as String? ?? '-';
    }
    return ReportItem(
      pelangganId: json['pelanggan_id'] as int,
      nama: json['nama'] as String,
      statusByMonth: statusByMonth,
    );
  }
}