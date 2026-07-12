import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class _Application {
  const _Application(this.name, this.specialty, this.submitted, this.detailLabel, this.detailValue,
      {required this.incomplete});
  final String name, specialty, submitted, detailLabel, detailValue;
  final bool incomplete;
}

class VerificationQueueScreen extends StatelessWidget {
  const VerificationQueueScreen({super.key});

  static const _apps = [
    _Application('Rahul Verma', 'Vegan Patisserie', 'Oct 24, 2023', 'Experience', '6 Years', incomplete: false),
    _Application('Sneha Kapoor', 'French Entremets', 'Oct 26, 2023', 'Experience', '8 Years', incomplete: false),
    _Application('Ananya Desai', 'Artisan Gelato', 'Oct 28, 2023', 'Status', 'Missing ID Copy', incomplete: true),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/admin/kyc',
      body: LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 1100 ? 3 : (c.maxWidth >= 720 ? 2 : 1);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(c.maxWidth >= 720),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.82,
                    children: [for (final a in _apps) _ApplicationCard(app: a)],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text('LOAD MORE APPLICATIONS',
                          style: AppText.labelSm.copyWith(color: AppColors.primary, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _header(bool wide) {
    final title = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Verification Queue', style: AppText.displayLg),
      const SizedBox(height: 4),
      Text('Review and approve artisanal chef credentials to maintain our standard of indulgent precision.',
          style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
    ]);
    final actions = Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 240,
        child: TextField(
          style: AppText.bodyMd,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
            hintText: 'Search chefs...',
            hintStyle: AppText.bodyMd.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.clottedCream.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.filter_list, size: 18),
        label: const Text('FILTER'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    ]);
    if (!wide) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [title, const SizedBox(height: 16), actions]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [Expanded(child: title), actions],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.app});
  final _Application app;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner + status pill + overlapping avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(height: 96, color: AppColors.surfaceContainerHigh),
              Positioned(
                top: 12, right: 12,
                child: StatusPill(app.incomplete ? 'Incomplete' : 'Pending',
                    tone: app.incomplete ? PillTone.inactive : PillTone.pending,
                    icon: app.incomplete ? Icons.hourglass_empty : Icons.pending_actions),
              ),
              Positioned(
                bottom: -40, left: 24,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
                  ),
                  child: const Icon(Icons.person, size: 36, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.name, style: AppText.headlineSm.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text('Specialty: ${app.specialty}',
                  style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 8),
              _row('Submitted', app.submitted),
              const SizedBox(height: 6),
              _row(app.detailLabel, app.detailValue, valueColor: app.incomplete ? AppColors.error : null),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: Icon(app.incomplete ? Icons.mail_outline : Icons.fact_check_outlined, size: 18),
                  label: Text(app.incomplete ? 'SEND REMINDER' : 'REVIEW PROFILE',
                      style: AppText.labelSm.copyWith(
                          color: app.incomplete ? AppColors.onSurfaceVariant : AppColors.clottedCream,
                          letterSpacing: 1.2)),
                  style: FilledButton.styleFrom(
                    backgroundColor: app.incomplete ? AppColors.surfaceContainerHigh : AppColors.darkGanache,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppText.bodyMd.copyWith(color: AppColors.outline)),
      Text(value,
          style: AppText.bodyMd.copyWith(
              color: valueColor ?? AppColors.onSurface, fontWeight: FontWeight.w500)),
    ]);
  }
}
