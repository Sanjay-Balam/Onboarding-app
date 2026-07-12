import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth.dart';

class ApiException implements Exception {
  ApiException(this.status, this.body, this.message);
  final int status;
  final dynamic body;
  final String message;
  @override
  String toString() => message;
}

/// Global API caller — the single entry point for every backend request.
/// Mirrors the web `PrismaAPI`: cookies sent automatically (withCredentials),
/// CSRF header on mutations, 401 → session cleared (router redirects to /login).
class Api {
  Api(this._dio, this._readCsrf, this._onUnauthorized);
  final Dio _dio;
  final String? Function() _readCsrf;
  final void Function() _onUnauthorized;

  // ignore: non_constant_identifier_names
  Future<T> PrismaAPI<T>(
    String method,
    String path, {
    Object? payload,
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'X-Portal': 'chef-onboarding',
      ...?headers,
    };
    // CSRF on every state-changing request (double-submit with the cookie).
    if (method != 'GET' && !skipAuth) {
      final csrf = _readCsrf();
      if (csrf != null) h['X-CSRF-Token'] = csrf;
    }

    final res = await _dio.request(
      path,
      data: method == 'GET' ? null : payload,
      options: Options(method: method, headers: h),
    );

    final status = res.statusCode ?? 0;

    if (status == 401 && !skipAuth) {
      _onUnauthorized(); // clears auth state → router sends user to /login
      throw ApiException(401, res.data, 'session_expired');
    }
    if (status >= 200 && status < 300) return res.data as T;

    final body = res.data;
    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'request_failed_$status';
    throw ApiException(status, body, message);
  }

  Future<T> get<T>(String path) => PrismaAPI<T>('GET', path);
  Future<T> post<T>(String path, [Object? payload]) => PrismaAPI<T>('POST', path, payload: payload);
  Future<T> patch<T>(String path, [Object? payload]) => PrismaAPI<T>('PATCH', path, payload: payload);
  Future<T> delete<T>(String path) => PrismaAPI<T>('DELETE', path);
}

final apiProvider = Provider<Api>((ref) {
  final dio = ref.watch(dioProvider);
  return Api(
    dio,
    () => ref.read(authProvider).csrfToken,
    () => ref.read(authProvider.notifier).clearSession(),
  );
});
