import 'package:dio/dio.dart';
import 'credentials_stub.dart' if (dart.library.html) 'credentials_web.dart';

// Backend base URL. TODO: move to build config for prod.
const apiBaseUrl = 'http://localhost:8002';

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    validateStatus: (s) => s != null && s < 500,
  ));
  applyCredentials(dio); // web: withCredentials for cookies
  return dio;
}
