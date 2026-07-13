import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'auth.dart';

class AttendanceLog {
  AttendanceLog({required this.id, required this.date, required this.checkInAt});
  final String id;
  final DateTime date;
  final DateTime checkInAt;
  factory AttendanceLog.fromJson(Map<String, dynamic> j) => AttendanceLog(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        checkInAt: DateTime.parse(j['checkInAt'] as String),
      );
}

class AttendanceSummary {
  AttendanceSummary({
    required this.checkedInToday,
    required this.recent,
    this.canCheckIn = false,
    this.onboardingStatus = 'NOT_STARTED',
  });
  final bool checkedInToday;
  final List<AttendanceLog> recent;
  final bool canCheckIn; // APPROVED chefs only
  final String onboardingStatus;
  factory AttendanceSummary.fromJson(Map<String, dynamic> j) => AttendanceSummary(
        checkedInToday: j['checkedInToday'] == true,
        canCheckIn: j['canCheckIn'] == true,
        onboardingStatus: j['onboardingStatus'] as String? ?? 'NOT_STARTED',
        recent: (j['recent'] as List? ?? [])
            .map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ChefAttendanceNotifier extends AsyncNotifier<AttendanceSummary> {
  @override
  Future<AttendanceSummary> build() async {
    ref.watch(authProvider.select((s) => s.user?.id)); // refetch when the user changes
    final data = await ref.read(apiProvider).get<Map<String, dynamic>>('/chef/attendance');
    return AttendanceSummary.fromJson(data);
  }

  /// Marks attendance for today. Throws ApiException(409) if already checked in.
  /// Updates state from the POST response — no extra fetch.
  Future<void> checkIn() async {
    final created = AttendanceLog.fromJson(
        await ref.read(apiProvider).post<Map<String, dynamic>>('/chef/attendance/check-in'));
    final current = state.valueOrNull ?? AttendanceSummary(checkedInToday: false, recent: const []);
    state = AsyncData(AttendanceSummary(
      checkedInToday: true,
      recent: [created, ...current.recent],
      canCheckIn: current.canCheckIn,
      onboardingStatus: current.onboardingStatus,
    ));
  }
}

final chefAttendanceProvider =
    AsyncNotifierProvider<ChefAttendanceNotifier, AttendanceSummary>(ChefAttendanceNotifier.new);
