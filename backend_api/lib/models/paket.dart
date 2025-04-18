// lib/models/user.dart
class User {
  final String name;
  final int harga;
  final String deskripsi;

  User({required this.name, required this.harga, required this.deskripsi});

  factory User.fromRow(List<dynamic> row) {
    return User(
      name: row[0] as String,
      harga: row[1] as int,
      deskripsi: row[2] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'harga': harga,
    'deskripsi': deskripsi,
  };
}
