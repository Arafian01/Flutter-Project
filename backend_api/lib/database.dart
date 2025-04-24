// lib/database.dart
import 'package:postgres/postgres.dart';

Future<PostgreSQLConnection> createConnection() async {
  final connection = PostgreSQLConnection(
    'localhost',
    5432,
    'db_strongnet',
    username: 'postgres',
    password: '99',
  );
  await connection.open();
  return connection;
}
