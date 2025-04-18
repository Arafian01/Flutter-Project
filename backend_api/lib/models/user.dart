// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({required this.id, required this.name, required this.email, required this.role});

  factory User.fromRow(List<dynamic> row) {
    return User(
      id: row[0] as int,
      name: row[1] as String,
      email: row[2] as String,
      role: row[3] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}
