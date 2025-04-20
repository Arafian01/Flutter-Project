class User {
  final String judul;
  final String pesan;
  final String created_at;

  User({required this.judul, required this.pesan, required this.created_at});

  factory User.fromRow(List<dynamic> row) {
    return User(
      judul: row[0] as String,
      pesan: row[1] as String,
      created_at: row[2] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'judul': judul,
    'pesan': pesan,
    'created_at': created_at,
  };
}
