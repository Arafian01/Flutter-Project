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

  /// untuk parsing response list/detail
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
