// lib/models/user.dart
class User {
  final String name;
  final String paket;
  final String status;

  User({required this.name, required this.paket, required this.status});

  factory User.fromRow(List<dynamic> row) {
    return User(
      name: row[0] as String,
      paket: row[1] as String,
      status: row[2] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'paket': paket,
    'status': status,
  };
}
