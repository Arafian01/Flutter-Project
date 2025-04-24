class Tagihan {
  final int id;
  final String name;
  final String bulanTahun;
  final String statusPembayaran;
  final DateTime jatuhTempo;

  Tagihan({
    required this.id,
    required this.name,
    required this.bulanTahun,
    required this.statusPembayaran,
    required this.jatuhTempo,
  });

  // Fungsi untuk membuat instance Tagihan dari row hasil query
  factory Tagihan.fromRow(List<dynamic> row) {
    // Periksa apakah kolom jatuh_tempo benar-benar berupa DateTime atau string yang dapat diparse
    DateTime jatuhTempo;
    if (row[4] is DateTime) {
      jatuhTempo = row[4]; // Langsung gunakan jika sudah DateTime
    } else if (row[4] is String) {
      jatuhTempo = DateTime.parse(row[4]); // Parse string ke DateTime
    } else {
      throw FormatException('Invalid format for jatuh_tempo');
    }

    return Tagihan(
      id: row[0] as int,
      name: row[1] as String,
      bulanTahun: row[2] as String,
      statusPembayaran: row[3] as String,
      jatuhTempo: jatuhTempo,
    );
  }

  // Fungsi untuk mengubah data Tagihan menjadi format JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bulan_tahun': bulanTahun,
        'status_pembayaran': statusPembayaran,
        'jatuh_tempo': jatuhTempo.toIso8601String(),  // Mengonversi DateTime ke string
      };
}
