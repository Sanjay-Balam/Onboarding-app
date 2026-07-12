import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class _Chef {
  _Chef(this.name, this.id, this.active, this.kyc, this.lastActive, this.twoFa);
  final String name, id, lastActive;
  final bool active;
  final PillTone kyc; // verified / pending
  bool twoFa;
}

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});
  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  // Mock data — replaced by GET /admin/chefs at integration.
  final _chefs = [
    _Chef('Ramesh Kumar', 'C-8842', true, PillTone.verified, 'Today, 09:42 AM', true),
    _Chef('Sunita Sharma', 'C-8845', false, PillTone.pending, 'Oct 12, 2023', false),
    _Chef('Vikram Singh', 'C-8850', true, PillTone.verified, 'Yesterday, 06:15 PM', true),
  ];

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(wide),
                    const SizedBox(height: 24),
                    _filters(),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: cols == 1 ? 1.35 : 1.55,
                      children: [for (final chef in _chefs) _card(chef)],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _header(bool wide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add New Chef'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }

  Widget _filters() {
    return AppCard(
      child: Column(children: [
        TextField(
          style: AppText.bodyMd,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppColors.outline),
            hintText: 'Search chefs by name or ID...',
            hintStyle: AppText.bodyMd.copyWith(color: AppColors.outlineVariant),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          for (final f in ['Status', 'KYC', 'Location'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(f, style: AppText.labelSm.copyWith(color: AppColors.onSurface)),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }

  Widget _card(_Chef chef) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(radius: 28, backgroundColor: AppColors.surfaceVariant,
                child: Icon(Icons.person, color: AppColors.onSurfaceVariant)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chef.name, style: AppText.headlineSm),
                const SizedBox(height: 4),
                Text('ID: ${chef.id}', style: AppText.labelSm.copyWith(color: AppColors.outline)),
              ]),
            ),
            StatusPill(chef.active ? 'Active' : 'Inactive',
                tone: chef.active ? PillTone.active : PillTone.inactive),
          ]),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CapsLabel('KYC Status', color: AppColors.outline),
                const SizedBox(height: 6),
                StatusPill(chef.kyc == PillTone.verified ? 'Verified' : 'Pending',
                    tone: chef.kyc,
                    icon: chef.kyc == PillTone.verified ? Icons.check_circle : Icons.pending_actions),
              ]),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CapsLabel('Last Active', color: AppColors.outline),
                const SizedBox(height: 6),
                Text(chef.lastActive, style: AppText.bodyMd.copyWith(fontSize: 14)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('2FA Required',
                      style: AppText.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('Enforce two-factor auth for logins',
                      style: AppText.labelSm.copyWith(color: AppColors.outline)),
                ]),
              ),
              Switch(
                value: chef.twoFa,
                activeColor: AppColors.onPrimary,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => setState(() => chef.twoFa = v), // TODO: PATCH /admin/chefs/:id/2fa
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
