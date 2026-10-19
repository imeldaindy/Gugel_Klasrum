import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  /// Token Sanctum dari /login. Diisi AuthProvider untuk akun yang aktif.
  static String? token;

  /// Id user yang sedang aktif (untuk menentukan peran di kelas).
  static int? userId;

  static Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if ((token ?? ApiService.token) != null)
      'Authorization': 'Bearer ${token ?? ApiService.token}',
  };

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Future<dynamic> get(String path, {String? token}) =>
      _send(() => http.get(_uri(path), headers: _headers(token)));

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) => _send(
    () => http.post(_uri(path), headers: _headers(token), body: jsonEncode(body)),
  );

  static Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) => _send(
    () => http.put(_uri(path), headers: _headers(token), body: jsonEncode(body)),
  );

  static Future<dynamic> delete(String path, {String? token}) =>
      _send(() => http.delete(_uri(path), headers: _headers(token)));

  static Future<dynamic> _send(Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call();
    } catch (_) {
      throw ApiException(
        'Tidak dapat terhubung ke server. Pastikan "php artisan serve" berjalan.',
      );
    }
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    var msg = 'Request gagal (${res.statusCode})';
    if (body is Map && body['message'] is String) msg = body['message'];
    throw ApiException(msg);
  }
}
