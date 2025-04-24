import 'package:postgres/postgres.dart';

Future<PostgreSQLConnection> createConnection() async {
  final connection = PostgreSQLConnection(
    'localhost',  // Host
    5432,  // Port PostgreSQL
    'db_strongnet',  // Nama database
    username: 'postgres',  // Username DB
    password: '99',  // Password DB
  );
  await connection.open();  // Membuka koneksi ke database
  return connection;
}
