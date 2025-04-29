class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromRow(List<dynamic> row) => User(
        id: row[0] as int,
        name: row[1] as String,
        email: row[2] as String,
        password: row[3] as String,
        role: row[4] as String,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
}
