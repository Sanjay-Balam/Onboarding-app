import 'package:dio/dio.dart';
import 'credentials_stub.dart' if (dart.library.html) 'credentials_web.dart';

// Backend base URL. Defaults to the deployed API; override for local dev with
// --dart-define=API_URL=http://localhost:8002
const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://onboardapi.buildnweb.in');

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    validateStatus: (s) => s != null && s < 500,
  ));
  applyCredentials(dio); // web: withCredentials for cookies
  return dio;
}
