import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'auth.dart';

class AdminDoc {
  AdminDoc({required this.id, required this.type, required this.mimeType, required this.verified});
  final String id, type, mimeType;
  final bool verified;
  factory AdminDoc.fromJson(Map<String, dynamic> j) => AdminDoc(
        id: j['id'] as String,
        type: j['type'] as String,
        mimeType: j['mimeType'] as String,
        verified: j['verified'] == true,
      );
}

class AdminChef {
  AdminChef({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.docCount,
    required this.isActive,
    required this.is2faEnabled,
  });
  final String id; // chefProfileId
  final String name, email;
  final String? phone;
  final String status; // onboardingStatus
  final int docCount;
  final bool isActive;
  final bool is2faEnabled;

  factory AdminChef.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>;
    return AdminChef(
      id: j['id'] as String,
      name: (user['name'] as String?)?.trim().isNotEmpty == true ? user['name'] as String : user['email'] as String,
      email: user['email'] as String,
      phone: user['phone'] as String?,
      status: j['onboardingStatus'] as String,
      docCount: (j['_count']?['documents'] as int?) ?? 0,
      isActive: user['isActive'] == true,
      is2faEnabled: user['is2faEnabled'] == true,
    );
  }

  AdminChef copyWith({bool? is2faEnabled, String? status}) => AdminChef(
        id: id, name: name, email: email, phone: phone, status: status ?? this.status,
        docCount: docCount, isActive: isActive, is2faEnabled: is2faEnabled ?? this.is2faEnabled,
      );
}

class AdminChefsNotifier extends AsyncNotifier<List<AdminChef>> {
  @override
  Future<List<AdminChef>> build() async {
    ref.watch(authProvider.select((s) => s.user?.id)); // refetch when the user changes
    final data = await ref.read(apiProvider).get<List<dynamic>>('/admin/chefs');
    return data.map((e) => AdminChef.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AdminDoc>> docs(String chefProfileId) async {
    final data = await ref.read(apiProvider).get<List<dynamic>>('/admin/chefs/$chefProfileId/documents');
    return data.map((e) => AdminDoc.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> docUrl(String docId) async {
    final res = await ref.read(apiProvider).get<Map<String, dynamic>>('/admin/documents/$docId/url');
    return res['url'] as String;
  }

  void _setStatus(String chefProfileId, String status) {
    final list = state.valueOrNull;
    if (list != null) {
      state = AsyncData([
        for (final c in list) c.id == chefProfileId ? c.copyWith(status: status) : c,
      ]);
    }
  }

  Future<void> approve(String chefProfileId) async {
    await ref.read(apiProvider).patch('/admin/chefs/$chefProfileId/approve');
    _setStatus(chefProfileId, 'APPROVED'); // update state, no refetch
  }

  Future<void> reject(String chefProfileId) async {
    await ref.read(apiProvider).patch('/admin/chefs/$chefProfileId/reject');
    _setStatus(chefProfileId, 'REJECTED');
  }

  /// Toggle login 2FA for a chef. Updates state in place (no refetch).
  Future<void> setTwoFactor(String chefProfileId, bool enabled) async {
    await ref.read(apiProvider).patch('/admin/chefs/$chefProfileId/2fa', {'enabled': enabled});
    final list = state.valueOrNull;
    if (list != null) {
      state = AsyncData([
        for (final c in list) c.id == chefProfileId ? c.copyWith(is2faEnabled: enabled) : c,
      ]);
    }
  }

  /// Onboard a new chef with admin-entered credentials. Prepends to state, no refetch.
  Future<void> createChef({
    required String name,
    required String email,
    required String phone,
    required String password,
    required bool is2faEnabled,
  }) async {
    final res = await ref.read(apiProvider).post<Map<String, dynamic>>('/admin/chefs', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'is2faEnabled': is2faEnabled,
    });
    final created = AdminChef(
      id: res['chefProfileId'] as String,
      name: (res['name'] as String?)?.trim().isNotEmpty == true ? res['name'] as String : email,
      email: res['email'] as String? ?? email,
      phone: phone,
      status: 'NOT_STARTED',
      docCount: 0,
      isActive: true,
      is2faEnabled: is2faEnabled,
    );
    state = AsyncData([created, ...(state.valueOrNull ?? const <AdminChef>[])]);
  }
}

final adminChefsProvider =
    AsyncNotifierProvider<AdminChefsNotifier, List<AdminChef>>(AdminChefsNotifier.new);

class AdminAttendance {
  AdminAttendance({required this.name, required this.email, required this.date, required this.checkInAt});
  final String name, email;
  final DateTime date, checkInAt;
  factory AdminAttendance.fromJson(Map<String, dynamic> j) {
    final user = (j['chef']?['user'] ?? {}) as Map<String, dynamic>;
    return AdminAttendance(
      name: (user['name'] as String?)?.trim().isNotEmpty == true ? user['name'] as String : (user['email'] as String? ?? 'Chef'),
      email: user['email'] as String? ?? '',
      date: DateTime.parse(j['date'] as String),
      checkInAt: DateTime.parse(j['checkInAt'] as String),
    );
  }
}

// All chefs' attendance logs (newest first) for the admin dashboard.
final adminAttendanceProvider = FutureProvider<List<AdminAttendance>>((ref) async {
  ref.watch(authProvider.select((s) => s.user?.id));
  final data = await ref.read(apiProvider).get<List<dynamic>>('/admin/attendance');
  return data.map((e) => AdminAttendance.fromJson(e as Map<String, dynamic>)).toList();
});
