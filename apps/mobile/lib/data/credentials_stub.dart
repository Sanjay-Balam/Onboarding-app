import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

CookieJar? _jar;

// Native: persist cookies to disk so the auth cookie survives app restarts.
Future<void> initCookieJar() async {
  final dir = await getApplicationDocumentsDirectory();
  _jar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies'));
}

void applyCredentials(Dio dio) {
  dio.interceptors.add(CookieManager(_jar ?? CookieJar()));
}

// CSRF token is persisted in secure storage (see AuthController), not read here.
String? readCsrfCookie() => null;
