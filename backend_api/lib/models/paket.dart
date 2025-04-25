class Paket {
  final int? id;
  final String namaPaket;
  final String deskripsi;
  final int harga;

  Paket({ this.id, required this.namaPaket, required this.deskripsi, required this.harga });

  factory Paket.fromRow(List<dynamic> row) => Paket(
    id: row[0] as int,
    namaPaket: row[1] as String,
    deskripsi: row[2] as String,
    harga: row[3] as int,
  );

  factory Paket.fromJson(Map<String, dynamic> json) => Paket(
    id: json['id'] as int?,
    namaPaket: json['nama_paket'] as String,
    deskripsi: json['deskripsi'] as String,
    harga: json['harga'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nama_paket': namaPaket,
    'deskripsi': deskripsi,
    'harga': harga,
  };
}
