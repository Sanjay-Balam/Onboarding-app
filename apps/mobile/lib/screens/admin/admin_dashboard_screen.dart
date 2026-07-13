import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/admin.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chefsAsync = ref.watch(adminChefsProvider);
    final attAsync = ref.watch(adminAttendanceProvider);
    final chefs = chefsAsync.valueOrNull ?? const <AdminChef>[];
    final att = attAsync.valueOrNull ?? const <AdminAttendance>[];

    final activeCount = chefs.where((c) => c.isActive).length;
    final pendingKyc = chefs.where((c) => c.status == 'PENDING_APPROVAL').length;
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final todayCheckins = att.where((a) => a.date.toUtc() == today).length;
    final pendingChefs = chefs.where((c) => c.status == 'PENDING_APPROVAL').toList();

    return AdminScaffold(
      currentRoute: '/admin',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminChefsProvider);
          ref.invalidate(adminAttendanceProvider);
        },
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 840;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Overview', style: AppText.displayLg),
                    const SizedBox(height: 24),
                    _metrics(wide, activeCount, pendingKyc, todayCheckins),
                    const SizedBox(height: 32),
                    if (wide)
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 2, child: _recentActivity(att)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(children: [
                          _quickActions(context), const SizedBox(height: 16), _kycQueue(context, pendingChefs),
                        ])),
                      ])
                    else ...[
                      _quickActions(context),
                      const SizedBox(height: 24),
                      _recentActivity(att),
                      const SizedBox(height: 24),
                      _kycQueue(context, pendingChefs),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _metrics(bool wide, int active, int pending, int shifts) {
    final cards = [
      _MetricCard(label: 'Chefs Active', value: '$active', icon: Icons.soup_kitchen_outlined),
      _MetricCard(label: 'Pending KYC', value: '$pending', icon: Icons.warning_amber_rounded,
          tone: _MetricTone.warning, delta: pending > 0 ? 'Requires attention' : 'All clear'),
      _MetricCard(label: 'Check-ins Today', value: '$shifts', icon: Icons.schedule, tone: _MetricTone.primary),
    ];
    if (wide) {
      return Row(children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 16),
        ],
      ]);
    }
    return Column(children: [for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 16), child: card)]);
  }

  Widget _recentActivity(List<AdminAttendance> att) {
    final items = att.take(6).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Recent Activity', style: AppText.headlineSm),
      const SizedBox(height: 16),
      AppCard(
        padding: EdgeInsets.zero,
        child: items.isEmpty
            ? Padding(padding: const EdgeInsets.all(24),
                child: Text('No activity yet.', textAlign: TextAlign.center,
                    style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)))
            : Column(children: [
                for (var i = 0; i < items.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i < items.length - 1 ? const Border(bottom: BorderSide(color: AppColors.surfaceVariant)) : null,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceVariant,
                          child: Icon(Icons.login, size: 20, color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(items[i].name, style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                          Text('Marked attendance', style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
                        ]),
                      ),
                      Text(_time(items[i].checkInAt.toLocal()), style: AppText.labelSm.copyWith(color: AppColors.outline)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }

  Widget _quickActions(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Quick Actions', style: AppText.headlineSm),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go('/admin/chefs/new'),
          icon: const Icon(Icons.person_add_alt, size: 20),
          label: const Text('Onboard New Chef'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/admin/kyc'),
          icon: const Icon(Icons.verified_user_outlined, size: 20),
          label: const Text('Review KYC Queue'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  Widget _kycQueue(BuildContext context, List<AdminChef> pending) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('KYC Queue', style: AppText.headlineSm),
          StatusPill('${pending.length} Pending', tone: PillTone.warning),
        ]),
        const SizedBox(height: 16),
        if (pending.isEmpty)
          Text('Nothing to review.', style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant))
        else
          for (final q in pending.take(3))
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.tertiaryFixed, borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  child: Text(q.name.isNotEmpty ? q.name[0].toUpperCase() : '?',
                      style: AppText.bodyMd.copyWith(color: AppColors.onTertiaryFixed, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.name, style: AppText.bodyMd.copyWith(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${q.docCount}/3 docs', style: AppText.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ]),
                ),
                const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
              ]),
            ),
        TextButton(onPressed: () => context.go('/admin/kyc'), child: const Text('View Full Queue')),
      ]),
    );
  }

  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ap';
  }
}

enum _MetricTone { normal, warning, primary }

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, this.delta, this.tone = _MetricTone.normal});
  final String label;
  final String value;
  final IconData icon;
  final String? delta;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final onPrimary = tone == _MetricTone.primary;
    final bg = onPrimary ? AppColors.primary : AppColors.surfaceContainerLowest;
    final labelColor = onPrimary ? AppColors.primaryFixedDim : AppColors.onSurfaceVariant;
    final valueColor = onPrimary ? AppColors.onPrimary : AppColors.primary;
    final iconBg = switch (tone) {
      _MetricTone.warning => AppColors.tertiaryFixed,
      _MetricTone.primary => Colors.white24,
      _MetricTone.normal => AppColors.surfaceContainerLow,
    };
    final iconColor = switch (tone) {
      _MetricTone.warning => AppColors.onTertiaryFixed,
      _MetricTone.primary => Colors.white,
      _MetricTone.normal => AppColors.primary,
    };
    return Container(
      height: 150,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CapsLabel(label, color: labelColor),
              const SizedBox(height: 4),
              Text(value, style: AppText.displayLg.copyWith(color: valueColor)),
            ]),
            CircleAvatar(radius: 20, backgroundColor: iconBg, child: Icon(icon, color: iconColor, size: 20)),
          ]),
          if (delta != null)
            Text(delta!, style: AppText.bodyMd.copyWith(fontSize: 13, color: labelColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
