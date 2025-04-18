import 'package:postgres/postgres.dart';

final connection = PostgreSQLConnection(
  'localhost', 
  5432,
  'db_strongnet',
  username: 'postgres',
  password: '99',
);

Future<void> connect() async {
  await connection.open();
}
