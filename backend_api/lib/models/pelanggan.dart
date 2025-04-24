class Pelanggan {
  final int id;
  final String name;
  final String email;
  final String paket;
  final String status;
  final String alamat;
  final String telepon;

  Pelanggan({
    required this.id,
    required this.name,
    required this.email,
    required this.paket,
    required this.status,
    required this.alamat,
    required this.telepon,
  });

  factory Pelanggan.fromRow(List<dynamic> row) {
    return Pelanggan(
      id: row[0] as int,
      name: row[1] as String,
      email: row[2] as String,
      paket: row[3] as String,
      status: row[4] as String,
      alamat: row[5] as String,
      telepon: row[6] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'paket': paket,
        'status': status,
        'alamat': alamat,
        'telepon': telepon,
      };
}
