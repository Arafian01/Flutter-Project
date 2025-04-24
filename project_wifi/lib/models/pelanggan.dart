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

  // Factory method untuk membuat objek Pelanggan dari row hasil query
  factory Pelanggan.fromRow(Map<String, dynamic> row) {
    return Pelanggan(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      paket: row['paket'] as String,
      status: row['status'] as String,
      alamat: row['alamat'] as String,
      telepon: row['telepon'] as String,
    );
  }

  // Fungsi untuk mengubah objek Pelanggan menjadi format JSON
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
