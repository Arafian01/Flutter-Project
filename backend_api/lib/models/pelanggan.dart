class Pelanggan {
  final int? id;
  final int userId;
  final int paketId;
  final String name;
  final String email;
  final String namaPaket;
  final String status;
  final String alamat;
  final String telepon;
  final DateTime? tanggalAktif;
  final DateTime tanggalLangganan;

  Pelanggan({
    this.id,
    required this.userId,
    required this.paketId,
    required this.name,
    required this.email,
    required this.namaPaket,
    required this.status,
    required this.alamat,
    required this.telepon,
    this.tanggalAktif,
    required this.tanggalLangganan,
  });

  /// Build from a SQL row. Handles both String and DateTime for date columns.
  factory Pelanggan.fromRow(List<dynamic> row) {
    dynamic parseDate(dynamic v) =>
        v is DateTime ? v : DateTime.parse(v as String);
    dynamic parseNullableDate(dynamic v) =>
        v == null ? null : (v is DateTime ? v : DateTime.parse(v as String));

    return Pelanggan(
      id: row[0] as int?,
      userId: row[1] as int,
      paketId: row[2] as int,
      name: row[3] as String,
      email: row[4] as String,
      namaPaket: row[5] as String,
      status: row[6] as String,
      alamat: row[7] as String,
      telepon: row[8] as String,
      tanggalAktif: parseNullableDate(row[9]),
      tanggalLangganan: parseDate(row[10]),
    );
  }

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
        id: json['id'] as int?,
        userId: json['user_id'] as int,
        paketId: json['paket_id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        namaPaket: json['nama_paket'] as String? ?? '',
        status: json['status'] as String,
        alamat: json['alamat'] as String,
        telepon: json['telepon'] as String,
        tanggalAktif: json['tanggal_aktif'] != null
            ? DateTime.parse(json['tanggal_aktif'] as String)
            : null,
        tanggalLangganan:
            DateTime.parse(json['tanggal_langganan'] as String),
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      if (id != null) 'id': id,
      'user_id': userId,
      'paket_id': paketId,
      'name': name,
      'email': email,
      'nama_paket': namaPaket,
      'status': status,
      'alamat': alamat,
      'telepon': telepon,
      'tanggal_langganan': tanggalLangganan.toIso8601String(),
    };
    if (tanggalAktif != null) {
      m['tanggal_aktif'] = tanggalAktif!.toIso8601String();
    }
    return m;
  }
}
