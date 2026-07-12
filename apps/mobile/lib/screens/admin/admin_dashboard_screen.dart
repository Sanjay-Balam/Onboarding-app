import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/admin',
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Overview', style: AppText.displayLg),
                  const SizedBox(height: 24),
                  _metrics(wide),
                  const SizedBox(height: 32),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _recentActivity()),
                        const SizedBox(width: 16),
                        Expanded(child: Column(children: [_quickActions(context), const SizedBox(height: 16), _kycQueue()])),
                      ],
                    )
                  else ...[
                    _quickActions(context),
                    const SizedBox(height: 24),
                    _recentActivity(),
                    const SizedBox(height: 24),
                    _kycQueue(),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _metrics(bool wide) {
    final cards = [
      _MetricCard(label: 'Chefs Active', value: '24', icon: Icons.soup_kitchen_outlined, delta: '+3 from yesterday'),
      _MetricCard(label: 'Pending KYC', value: '3', icon: Icons.warning_amber_rounded, tone: _MetricTone.warning, delta: 'Requires attention'),
      _MetricCard(label: 'Total Shifts Today', value: '32', icon: Icons.schedule, tone: _MetricTone.primary, delta: '8 shifts pending start'),
    ];
    if (wide) {
      return Row(children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 16),
        ],
      ]);
    }
    return Column(children: [
      for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 16), child: card),
    ]);
  }

  Widget _recentActivity() {
    final items = [
      ('Rajeev Kumar', 'Marked attendance at Cart 4', '08:15 AM', Icons.person, false),
      ('System', 'New KYC document uploaded for Amit', '07:42 AM', Icons.upload_file_outlined, false),
      ('Suresh Singh', 'Completed shift at Cart 2', 'YESTERDAY', Icons.person, false),
      ('Alert', 'Cart 1 missing closing checklist', 'YESTERDAY', Icons.error_outline, true),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Recent Activity', style: AppText.headlineSm),
          Text('View All', style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: i < items.length - 1
                        ? const Border(bottom: BorderSide(color: AppColors.surfaceVariant))
                        : null,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: items[i].$5 ? AppColors.errorContainer : AppColors.surfaceVariant,
                      child: Icon(items[i].$4,
                          size: 20, color: items[i].$5 ? AppColors.onErrorContainer : AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(items[i].$1,
                            style: AppText.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: items[i].$5 ? AppColors.error : AppColors.onSurface)),
                        Text(items[i].$2,
                            style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
                      ]),
                    ),
                    Text(items[i].$3, style: AppText.labelSm.copyWith(color: AppColors.outline)),
                  ]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Quick Actions', style: AppText.headlineSm),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go('/admin/staff'),
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
          onPressed: () {},
          icon: const Icon(Icons.assignment_outlined, size: 20),
          label: const Text('Assign Shift'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  Widget _kycQueue() {
    final queue = [('Vikram K.', 'Aadhaar Card', 'V'), ('Manoj D.', 'Food Safety Cert', 'M')];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('KYC Queue', style: AppText.headlineSm),
          const StatusPill('3 Pending', tone: PillTone.warning),
        ]),
        const SizedBox(height: 16),
        for (final q in queue)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppColors.tertiaryFixed, borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child: Text(q.$3, style: AppText.bodyMd.copyWith(color: AppColors.onTertiaryFixed, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.$1, style: AppText.bodyMd.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(q.$2, style: AppText.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ]),
              ),
              const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
            ]),
          ),
      ]),
    );
  }
}

enum _MetricTone { normal, warning, primary }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.delta,
    this.tone = _MetricTone.normal,
  });
  final String label;
  final String value;
  final IconData icon;
  final String delta;
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
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CapsLabel(label, color: labelColor),
                const SizedBox(height: 4),
                Text(value, style: AppText.displayLg.copyWith(color: valueColor)),
              ]),
              CircleAvatar(radius: 20, backgroundColor: iconBg, child: Icon(icon, color: iconColor, size: 20)),
            ],
          ),
          Text(delta,
              style: AppText.bodyMd.copyWith(
                fontSize: 13,
                color: tone == _MetricTone.normal ? AppColors.success : labelColor,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
