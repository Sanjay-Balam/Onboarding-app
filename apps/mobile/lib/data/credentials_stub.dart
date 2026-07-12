import 'package:dio/dio.dart';

// Mobile/native: cookies handled by a cookie jar (added later). No-op for now.
// ponytail: add dio_cookie_manager when the native build needs persisted cookies.
void applyCredentials(Dio dio) {}

// Native: CSRF token comes back in the login response and lives in AuthState.
String? readCsrfCookie() => null;
