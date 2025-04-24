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

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      paket: json['paket'],
      status: json['status'],
      alamat: json['alamat'],
      telepon: json['telepon'],
    );
  }
}
