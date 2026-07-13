import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/admin.dart';
import '../../data/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

PillTone _kycTone(String s) => switch (s) {
      'APPROVED' => PillTone.verified,
      'PENDING_APPROVAL' => PillTone.pending,
      'REJECTED' => PillTone.error,
      'IN_PROGRESS' => PillTone.warning,
      _ => PillTone.inactive,
    };
String _kycLabel(String s) => switch (s) {
      'APPROVED' => 'Verified',
      'PENDING_APPROVAL' => 'Pending',
      'IN_PROGRESS' => 'In Progress',
      'REJECTED' => 'Rejected',
      _ => 'Not Started',
    };

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});
  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminChefsProvider);
    return AdminScaffold(
      currentRoute: '/admin/staff',
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        final cols = c.maxWidth >= 1100 ? 2 : 1;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: wide
              ? null
              : FloatingActionButton(
                  backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => context.go('/admin/chefs/new'),
                  child: const Icon(Icons.add),
                ),
          body: RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminChefsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(wide),
                      const SizedBox(height: 24),
                      _search(),
                      const SizedBox(height: 24),
                      async.when(
                        loading: () => const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                        error: (e, _) => Padding(padding: const EdgeInsets.all(24),
                            child: Text('Failed to load: $e', style: AppText.bodyMd)),
                        data: (chefs) {
                          final list = chefs.where((c) {
                            final q = _q.toLowerCase();
                            return q.isEmpty || c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q);
                          }).toList();
                          if (list.isEmpty) {
                            return Padding(padding: const EdgeInsets.all(32),
                                child: Text('No chefs found.', textAlign: TextAlign.center,
                                    style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)));
                          }
                          return GridView.count(
                            crossAxisCount: cols, shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16, crossAxisSpacing: 16,
                            childAspectRatio: cols == 1 ? 1.5 : 1.7,
                            children: [for (final chef in list) _card(chef)],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _header(bool wide) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Staff Management', style: AppText.displayLg),
          const SizedBox(height: 4),
          Text('Manage chef profiles, access, and compliance status.',
              style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        ]),
      ),
      if (wide)
        FilledButton.icon(
          onPressed: () => context.go('/admin/chefs/new'),
          icon: const Icon(Icons.add),
          label: const Text('Add New Chef'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
    ]);
  }

  Widget _search() {
    return AppCard(
      child: TextField(
        onChanged: (v) => setState(() => _q = v),
        style: AppText.bodyMd,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.outline),
          hintText: 'Search chefs by name or email...',
          hintStyle: AppText.bodyMd.copyWith(color: AppColors.outlineVariant),
          filled: true, fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.outlineVariant)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.outlineVariant)),
        ),
      ),
    );
  }

  Widget _card(AdminChef chef) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(radius: 28, backgroundColor: AppColors.surfaceVariant,
              child: Icon(Icons.person, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(chef.name, style: AppText.headlineSm, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(chef.email, style: AppText.labelSm.copyWith(color: AppColors.outline),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          StatusPill(chef.isActive ? 'Active' : 'Inactive',
              tone: chef.isActive ? PillTone.active : PillTone.inactive),
        ]),
        const SizedBox(height: 16),
        const Divider(color: AppColors.surfaceContainerHigh),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CapsLabel('KYC Status', color: AppColors.outline),
              const SizedBox(height: 6),
              StatusPill(_kycLabel(chef.status), tone: _kycTone(chef.status),
                  icon: chef.status == 'APPROVED' ? Icons.check_circle : Icons.pending_actions),
            ]),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CapsLabel('Documents', color: AppColors.outline),
              const SizedBox(height: 6),
              Text('${chef.docCount}/3', style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('2FA Required',
                    style: AppText.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('OTP on login', style: AppText.labelSm.copyWith(color: AppColors.outline)),
              ]),
            ),
            Switch(
              value: chef.is2faEnabled,
              activeColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
              onChanged: (v) async {
                try {
                  await ref.read(adminChefsProvider.notifier).setTwoFactor(chef.id, v);
                } on ApiException catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
