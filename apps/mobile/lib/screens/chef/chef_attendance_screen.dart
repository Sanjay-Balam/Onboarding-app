import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api_client.dart';
import '../../data/attendance.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class ChefAttendanceScreen extends ConsumerWidget {
  const ChefAttendanceScreen({super.key});

  static const _months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chefAttendanceProvider);
    final summary = async.valueOrNull;
    final now = DateTime.now();

    // Days (this month) the chef has checked in — drives the calendar ticks.
    final checkedDays = <int>{
      for (final log in summary?.recent ?? const [])
        if (log.date.toUtc().year == now.year && log.date.toUtc().month == now.month) log.date.toUtc().day,
    };
    final checkedIn = summary?.checkedInToday ?? false;

    return ChefScaffold(
      currentRoute: '/chef/attendance',
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context, ref, wide, checkedIn, async.isLoading, now),
                  const SizedBox(height: 24),
                  if (wide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: _calendar(now, checkedDays)),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: _overview(checkedDays.length)),
                        ],
                      ),
                    )
                  else ...[
                    _calendar(now, checkedDays),
                    const SizedBox(height: 24),
                    _overview(checkedDays.length),
                  ],
                  const SizedBox(height: 24),
                  _recentCheckins(summary?.recent ?? const []),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(chefAttendanceProvider.notifier).checkIn();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in ✓')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.status == 409 ? 'Already checked in today' : e.message)));
      }
    }
  }

  Widget _header(BuildContext context, WidgetRef ref, bool wide, bool checkedIn, bool loading, DateTime now) {
    final title = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Shift Attendance', style: AppText.headlineLg),
      const SizedBox(height: 8),
      Text('${_months[now.month - 1]} ${now.year}',
          style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
    ]);
    final button = FilledButton.icon(
      onPressed: (checkedIn || loading) ? null : () => _checkIn(context, ref),
      icon: Icon(checkedIn ? Icons.check : Icons.fingerprint),
      label: Text(checkedIn ? 'MARKED TODAY' : 'MARK ATTENDANCE',
          style: AppText.labelSm.copyWith(color: AppColors.clottedCream, letterSpacing: 1)),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.darkGanache,
        disabledBackgroundColor: AppColors.outline,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    if (!wide) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [title, const SizedBox(height: 16), button]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: title), button]);
  }

  Widget _calendar(DateTime now, Set<int> checkedDays) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // Mon=1..Sun=7
    final leadingEmpty = firstWeekday - 1;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Schedule', style: AppText.headlineSm.copyWith(fontSize: 20)),
            Row(children: const [
              Icon(Icons.chevron_left, color: AppColors.onSurfaceVariant),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ]),
          ]),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (final d in const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'])
                Center(child: Text(d, style: AppText.labelSm)),
              for (var i = 0; i < leadingEmpty; i++) const SizedBox(),
              for (var day = 1; day <= daysInMonth; day++)
                _dayCell(day, isToday: day == now.day, checked: checkedDays.contains(day)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceVariant),
          const SizedBox(height: 8),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _legendDot(AppColors.primaryContainer, 'TODAY'),
            _legendIcon('CHECKED-IN'),
            _legendDot(AppColors.surfaceVariant, 'NO SHIFT'),
          ]),
        ],
      ),
    );
  }

  Widget _dayCell(int day, {required bool isToday, required bool checked}) {
    final bg = isToday ? AppColors.primaryContainer : AppColors.surfaceContainer;
    final fg = isToday ? AppColors.clottedCream : AppColors.onSurface;
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('$day', style: AppText.bodyMd.copyWith(color: fg, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
          if (checked)
            Positioned(
              top: 2, right: 2,
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, size: 14, color: AppColors.success),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppText.labelSm),
      ]);

  Widget _legendIcon(String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
        const SizedBox(width: 8),
        Text(label, style: AppText.labelSm),
      ]);

  Widget _overview(int checkedCount) {
    return AppCard(
      color: AppColors.clottedCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Monthly Overview', style: AppText.headlineSm.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          // Only DB-backed metric: days the chef checked in this month.
          _statTile('DAYS PRESENT', '$checkedCount', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CapsLabel(label),
            const SizedBox(height: 4),
            Text(value, style: AppText.headlineSm.copyWith(fontSize: 24)),
          ]),
        ),
        CircleAvatar(radius: 24, backgroundColor: AppColors.surfaceVariant,
            child: Icon(icon, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _recentCheckins(List<AttendanceLog> logs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Recent Check-ins', style: AppText.headlineSm.copyWith(fontSize: 20)),
      const SizedBox(height: 16),
      AppCard(
        padding: EdgeInsets.zero,
        child: logs.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No check-ins yet.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              )
            : Column(children: [
                for (var i = 0; i < logs.length; i++)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: i < logs.length - 1
                          ? const Border(bottom: BorderSide(color: AppColors.surfaceVariant))
                          : null,
                    ),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.login, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Checked In', style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          Text(_fmtDate(logs[i].date.toUtc()), style: AppText.labelSm),
                        ]),
                      ),
                      Text(_fmtTime(logs[i].checkInAt.toLocal()),
                          style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }

  static const _mon3 = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  String _fmtDate(DateTime d) => '${_mon3[d.month - 1]} ${d.day}, ${d.year}';
  String _fmtTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ap';
  }
}
