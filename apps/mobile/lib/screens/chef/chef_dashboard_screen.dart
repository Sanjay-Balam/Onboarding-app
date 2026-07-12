import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('Good Morning, Chef', style: AppText.displayLg),
                const SizedBox(height: 8),
                Text("Ready for today's shift at Downtown Station.",
                    style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                _checkInCard(context),
                const SizedBox(height: 24),
                _statusRow(),
                const SizedBox(height: 24),
                _recentLogs(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkInCard(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: AppColors.secondaryFixedDim, shape: BoxShape.circle),
          child: const Icon(Icons.schedule, size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text('Mark Attendance', style: AppText.headlineLg),
        const SizedBox(height: 4),
        Text('08:45 AM • THU, OCT 26', style: AppText.labelSm),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checked in (mock)'))), // TODO: POST attendance
            icon: const Icon(Icons.fingerprint),
            label: const Text('Check In Now'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryFixed,
              foregroundColor: AppColors.onSecondaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statusRow() {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CapsLabel('Current Status'),
            const SizedBox(height: 8),
            Row(children: [
              Container(width: 12, height: 12,
                  decoration: const BoxDecoration(color: AppColors.burntCaramel, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Pending Check-in',
                    style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ]),
          ]),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CapsLabel('Upcoming Shift'),
            const SizedBox(height: 8),
            Text('09:00 AM - 05:00 PM',
                style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
            Text('Downtown Cart #4',
                style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
          ]),
        ),
      ),
    ]);
  }

  Widget _recentLogs() {
    final logs = [
      ('Checked Out', 'Yesterday', '05:15 PM', Icons.logout),
      ('Checked In', 'Yesterday', '08:55 AM', Icons.login),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Logs', style: AppText.headlineSm),
        Text('VIEW ALL', style: AppText.labelSm.copyWith(color: AppColors.primary)),
      ]),
      const SizedBox(height: 16),
      AppCard(
        padding: EdgeInsets.zero,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        child: Column(children: [
          for (var i = 0; i < logs.length; i++)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: i < logs.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.surfaceContainerLow))
                    : null,
              ),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainer,
                    child: Icon(logs[i].$4, size: 20, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(logs[i].$1, style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    Text(logs[i].$2, style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                  ]),
                ),
                Text(logs[i].$3, style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
              ]),
            ),
        ]),
      ),
    ]);
  }
}
