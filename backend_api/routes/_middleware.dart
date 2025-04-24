import 'package:dart_frog/dart_frog.dart';
import '../lib/middlewares/cors.dart';

Handler middleware(Handler handler) => handler.use(cors);
