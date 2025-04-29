import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await createConnection();
  try {
    switch (context.request.method) {
      // GET all pelanggan
      case HttpMethod.get:
        final results = await connection.query(
          '''
          SELECT p.id, p.user_id, p.paket_id,
                 u.name, u.email,
                 pk.nama_paket, p.status,
                 p.alamat, p.telepon,
                 p.tanggal_aktif, p.tanggal_langganan
          FROM pelanggans p
          JOIN users u ON p.user_id = u.id
          JOIN pakets pk ON p.paket_id = pk.id
          ORDER BY p.id;
          ''',
        );
        final list =
            results.map((row) => Pelanggan.fromRow(row).toJson()).toList();
        return Response.json(body: list);

      // POST create new pelanggan + user
      case HttpMethod.post:
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        // 1) insert into users
        final userResult = await connection.query(
          '''
          INSERT INTO users (name, email, password, role)
          VALUES (@name, @email, crypt(@password, gen_salt('bf')), 'pelanggan')
          RETURNING id;
          ''',
          substitutionValues: {
            'name': jsonMap['name'],
            'email': jsonMap['email'],
            'password': jsonMap['password'],
          },
        );
        final userId = userResult.first[0] as int;

        // 2) insert into pelanggans
        await connection.query(
          '''
          INSERT INTO pelanggans
            (user_id, paket_id, status, alamat, telepon, tanggal_aktif, tanggal_langganan)
          VALUES
            (@userId, @paketId, @status, @alamat, @telepon, @tanggalAktif, @tanggalLangganan);
          ''',
          substitutionValues: {
            'userId': userId,
            'paketId': jsonMap['paket_id'],
            'status': jsonMap['status'],
            'alamat': jsonMap['alamat'],
            'telepon': jsonMap['telepon'],
            'tanggalAktif': jsonMap['tanggal_aktif'],
            'tanggalLangganan': jsonMap['tanggal_langganan'],
          },
        );

        return Response.json(
          statusCode: 201,
          body: {'message': 'Pelanggan created', 'user_id': userId},
        );

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  } finally {
    await connection.close();
  }
}
