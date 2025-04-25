class Pelanggan {
  final int? id;
  final int userId;
  final String name;
  final String email;
  final int paketId;
  final String status;
  final String? tanggalAktif;
  final String tanggalLangganan;
  final String alamat;
  final String telepon;

  Pelanggan({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.paketId,
    required this.status,
    this.tanggalAktif,
    required this.tanggalLangganan,
    required this.alamat,
    required this.telepon,
  });

  /// Dari row JOIN pelanggan–user–paket
  factory Pelanggan.fromRow(List<dynamic> row) {
    return Pelanggan(
      id: row[0] as int,
      name: row[1] as String,
      email: row[2] as String,
      paketId: 0,             // paketId tidak dipakai di response list
      status: row[4] as String,
      alamat: row[5] as String,
      telepon: row[6] as String,
      userId: 0,
      tanggalLangganan: '',
      tanggalAktif: null,
    );
  }

  /// Dari JSON body POST/PUT
  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      paketId: json['paket_id'] as int,
      status: json['status'] as String,
      tanggalAktif: json['tanggal_aktif'] as String?,
      tanggalLangganan: json['tanggal_langganan'] as String,
      alamat: json['alamat'] as String,
      telepon: json['telepon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'paket_id': paketId,
      'status': status,
      'tanggal_aktif': tanggalAktif,
      'tanggal_langganan': tanggalLangganan,
      'alamat': alamat,
      'telepon': telepon,
    };
  }
}
