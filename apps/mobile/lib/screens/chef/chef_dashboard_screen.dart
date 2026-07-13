import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/api_client.dart';
import '../../data/attendance.dart';
import '../../data/auth.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class ChefDashboardScreen extends ConsumerWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chefAttendanceProvider);
    final summary = async.valueOrNull;
    final checkedIn = summary?.checkedInToday ?? false;
    final canCheckIn = summary?.canCheckIn ?? false;
    final user = ref.watch(authProvider).user;
    final firstName = (user?.name?.trim().isNotEmpty ?? false)
        ? user!.name!.trim().split(' ').first
        : 'Chef';

    return ChefScaffold(
      currentRoute: '/chef',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('${_greeting()}, $firstName', style: AppText.displayLg),
                const SizedBox(height: 8),
                Text(
                    checkedIn
                        ? "You're checked in for today's shift."
                        : "Ready for today's shift — mark your attendance.",
                    style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                _checkInCard(context, ref, checkedIn, async.isLoading, canCheckIn),
                const SizedBox(height: 24),
                _statusRow(checkedIn),
                const SizedBox(height: 24),
                _recentLogs(summary?.recent ?? const []),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _doCheckIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(chefAttendanceProvider.notifier).checkIn();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in ✓')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.status == 409 ? 'Already checked in today' : e.message)));
      }
    }
  }

  Widget _checkInCard(BuildContext context, WidgetRef ref, bool checkedIn, bool loading, bool canCheckIn) {
    // Not verified yet → block check-in, prompt to finish KYC.
    if (!canCheckIn) {
      return AppCard(
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.tertiaryFixed, shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline, size: 36, color: AppColors.onTertiaryFixed),
          ),
          const SizedBox(height: 16),
          Text('Attendance Locked', style: AppText.headlineLg, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Complete the verification process before you can mark attendance.',
              textAlign: TextAlign.center,
              style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => context.go('/chef/onboarding'),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Complete Verification'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
      );
    }
    return AppCard(
      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: checkedIn ? AppColors.success.withOpacity(0.15) : AppColors.secondaryFixedDim,
            shape: BoxShape.circle,
          ),
          child: Icon(checkedIn ? Icons.check_circle : Icons.schedule, size: 36,
              color: checkedIn ? AppColors.success : AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text('Mark Attendance', style: AppText.headlineLg),
        const SizedBox(height: 4),
        Text(_todayLabel(), style: AppText.labelSm),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: (checkedIn || loading) ? null : () => _doCheckIn(context, ref),
            icon: Icon(checkedIn ? Icons.check : Icons.fingerprint),
            label: Text(checkedIn ? 'Checked In' : 'Check In Now'),
            style: FilledButton.styleFrom(
              backgroundColor: checkedIn ? AppColors.surfaceContainerHigh : AppColors.secondaryFixed,
              foregroundColor: checkedIn ? AppColors.onSurfaceVariant : AppColors.onSecondaryContainer,
              disabledBackgroundColor: checkedIn ? AppColors.surfaceContainerHigh : null,
              disabledForegroundColor: checkedIn ? AppColors.onSurfaceVariant : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statusRow(bool checkedIn) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CapsLabel('Current Status'),
        const SizedBox(height: 8),
        Row(children: [
          Container(width: 12, height: 12,
              decoration: BoxDecoration(
                  color: checkedIn ? AppColors.success : AppColors.burntCaramel, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(checkedIn ? 'Present' : 'Pending Check-in',
                style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }

  Widget _recentLogs(List<AttendanceLog> logs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Logs', style: AppText.headlineSm),
        Text('VIEW ALL', style: AppText.labelSm.copyWith(color: AppColors.primary)),
      ]),
      const SizedBox(height: 16),
      AppCard(
        padding: EdgeInsets.zero,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        child: logs.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No attendance yet.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              )
            : Column(children: [
                for (var i = 0; i < logs.length; i++)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: i < logs.length - 1
                          ? const Border(bottom: BorderSide(color: AppColors.surfaceContainerLow))
                          : null,
                    ),
                    child: Row(children: [
                      const CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainer,
                          child: Icon(Icons.login, size: 20, color: AppColors.primary)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Checked In',
                              style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                          Text(_dateLabel(logs[i].date.toUtc()),
                              style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                        ]),
                      ),
                      Text(_timeLabel(logs[i].checkInAt.toLocal()),
                          style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _todayLabel() {
    final n = DateTime.now();
    return '${_time(n)} • ${_weekday(n)}, ${_months[n.month - 1].toUpperCase()} ${n.day}';
  }

  String _dateLabel(DateTime d) => '${_months[d.month - 1]} ${d.day}';
  String _timeLabel(DateTime d) => _time(d);

  String _time(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${h12.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  static const _weekdays = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
  String _weekday(DateTime d) => _weekdays[d.weekday - 1];
}
