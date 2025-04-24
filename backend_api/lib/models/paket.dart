class Paket {
  final int id;
  final String namaPaket;
  final String deskripsi;
  final int harga;

  Paket({
    required this.id,
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
  });

  // Fungsi untuk membuat instance Paket dari row hasil query
  factory Paket.fromRow(List<dynamic> row) {
    return Paket(
      id: row[0] as int,
      namaPaket: row[1] as String,
      deskripsi: row[2] as String,
      harga: row[3] as int,
    );
  }

  // Fungsi untuk mengubah data Paket menjadi format JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_paket': namaPaket,
        'deskripsi': deskripsi,
        'harga': harga,
      };
}
