import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

// Web: browser stores the httpOnly cookie; withCredentials sends/receives it.
Future<void> initCookieJar() async {}

void applyCredentials(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}

// csrf_token is a non-httpOnly cookie → readable to re-hydrate CSRF after reload.
String? readCsrfCookie() {
  for (final part in html.document.cookie?.split(';') ?? const []) {
    final kv = part.trim().split('=');
    if (kv.length == 2 && kv[0] == 'csrf_token') return Uri.decodeComponent(kv[1]);
  }
  return null;
}
