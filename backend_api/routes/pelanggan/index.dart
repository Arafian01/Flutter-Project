import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/pelanggan.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = await createConnection();
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        // GET /pelanggan
        final results = await conn.query('''
          SELECT pelanggans.id, users.name, users.email,
                 pakets.nama_paket, pelanggans.status,
                 pelanggans.alamat, pelanggans.telepon
          FROM pelanggans
          JOIN users ON pelanggans.user_id = users.id
          JOIN pakets ON pelanggans.paket_id = pakets.id
        ''');
        final list = results.map((r) => Pelanggan.fromRow(r).toJson()).toList();
        return Response.json(body: list);

      case HttpMethod.post:
        // POST /pelanggan
        final body = await context.request.body();
        final jsonMap = json.decode(body) as Map<String, dynamic>;

        // 1) insert user
        final userResult = await conn.query('''
          INSERT INTO users (name, email, password, role)
          VALUES (@name, @email, @password, 'pelanggan')
          RETURNING id
        ''', substitutionValues: {
          'name': jsonMap['name'],
          'email': jsonMap['email'],
          'password': jsonMap['password'], // harap sudah di-hash di client atau server
        });
        final userId = userResult.first[0] as int;

        // 2) tentukan tanggal_aktif
        String? tAktif;
        final status = jsonMap['status'] as String;
        if (status == 'aktif') {
          tAktif = DateTime.now().toIso8601String().split('T').first;
        }

        // 3) insert pelanggan
        await conn.query('''
          INSERT INTO pelanggans
            (user_id, paket_id, alamat, telepon, status, tanggal_aktif, tanggal_langganan)
          VALUES
            (@uid, @pid, @alamat, @telp, @status, @taktif, @tlanggan)
        ''', substitutionValues: {
          'uid': userId,
          'pid': jsonMap['paket_id'],
          'alamat': jsonMap['alamat'],
          'telp': jsonMap['telepon'],
          'status': status,
          'taktif': tAktif,
          'tlanggan': jsonMap['tanggal_langganan'],
        });

        return Response.json(body: {'message': 'Pelanggan created'}, statusCode: 201);

      default:
        return Response(statusCode: 405);
    }
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 500);
  } finally {
    await conn.close();
  }
}
