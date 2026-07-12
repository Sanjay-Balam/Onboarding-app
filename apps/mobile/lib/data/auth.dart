import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api.dart';
import 'credentials_stub.dart' if (dart.library.html) 'credentials_web.dart';

class AuthUser {
  AuthUser({required this.id, required this.email, this.name, required this.roles});
  final String id;
  final String email;
  final String? name;
  final List<String> roles;

  bool get isAdmin => roles.contains('ADMIN');

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String?,
        roles: (j['roles'] as List).cast<String>(),
      );
}

class LoginResult {
  LoginResult({required this.requires2fa, required this.user});
  final bool requires2fa;
  final AuthUser user;
}

class AuthState {
  const AuthState({this.user, this.csrfToken});
  final AuthUser? user;
  final String? csrfToken;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._dio) : super(const AuthState());
  final Dio _dio;

  Future<LoginResult> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Invalid email or password');
    }
    final data = res.data as Map<String, dynamic>;
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    // csrfToken echoed on mutating requests (double-submit).
    state = AuthState(user: user, csrfToken: data['csrfToken'] as String?);
    return LoginResult(requires2fa: data['requires2fa'] == true, user: user);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout',
          options: Options(headers: {if (state.csrfToken != null) 'x-csrf-token': state.csrfToken}));
    } catch (_) {}
    clearSession();
  }

  /// Drop local auth state (called on 401 or logout). Router redirects to /login.
  void clearSession() => state = const AuthState();

  /// Restore session on app start from the httpOnly cookie (survives refresh).
  Future<void> restore() async {
    try {
      final res = await _dio.get('/auth/me');
      if (res.statusCode == 200 && res.data?['user'] != null) {
        state = AuthState(
          user: AuthUser.fromJson(res.data['user'] as Map<String, dynamic>),
          csrfToken: readCsrfCookie(),
        );
      }
    } catch (_) {
      // no valid session → stay logged out
    }
  }
}

final dioProvider = Provider<Dio>((_) => createDio());
final authProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref.watch(dioProvider)));

/// Runs once at startup to rehydrate the session from the cookie.
final sessionRestoreProvider = FutureProvider<void>((ref) => ref.read(authProvider.notifier).restore());
