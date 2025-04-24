class Paket {
  final String namaPaket;
  final String deskripsi;
  final int harga;

  Paket({
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
  });

  // Factory method untuk membuat objek Paket dari row hasil query
  factory Paket.fromRow(Map<String, dynamic> row) {
    return Paket(
      namaPaket: row['nama_paket'] as String,
      deskripsi: row['deskripsi'] as String,
      harga: row['harga'] as int,
    );
  }

  // Fungsi untuk mengubah objek Paket menjadi JSON
  Map<String, dynamic> toJson() => {
    'nama_paket': namaPaket,
    'deskripsi': deskripsi,
    'harga': harga,
  };
}
