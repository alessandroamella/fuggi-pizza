import 'package:http/http.dart' as http;
import 'package:orderer_app/misc/connection_info.dart';

class APIRoute {
  static const String order = '/order';
  static const String dish = '/dish';
  static const String table = '/table';
  static const String category = '/category';
}

class ApiService {
  final ConnectionInfo info;

  final http.Client _httpClient = http.Client();

  ApiService({required this.info});

  http.Client get client => _httpClient;
  Uri uri(String path) =>
      Uri.http('${info.serverAddress}:${info.serverPort}', '/api/v1$path');
}
