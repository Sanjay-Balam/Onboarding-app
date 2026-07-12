import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});
  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/admin/profile',
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileBento(wide),
                  const SizedBox(height: 24),
                  if (wide)
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: _accountSettings()),
                      const SizedBox(width: 24),
                      Expanded(child: _appPreferences()),
                    ])
                  else ...[
                    _accountSettings(),
                    const SizedBox(height: 24),
                    _appPreferences(),
                  ],
                  const SizedBox(height: 32),
                  Center(child: _logout(context)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _profileBento(bool wide) {
    final card = Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.clottedCream,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Ananya Sharma',
                    style: AppText.headlineLg.copyWith(color: AppColors.darkGanache), softWrap: true),
                const SizedBox(height: 8),
                const StatusPill('Operations Manager', tone: PillTone.inactive),
              ]),
            ),
          ]),
        ],
      ),
    );

    final level = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.verified_user, size: 40, color: AppColors.onPrimaryContainer),
        const SizedBox(height: 8),
        Text('Admin Level', style: AppText.headlineSm.copyWith(color: AppColors.onPrimaryContainer)),
        const SizedBox(height: 4),
        Text('Full Access Rights',
            style: AppText.bodyMd.copyWith(color: AppColors.onPrimaryContainer.withOpacity(0.8))),
      ]),
    );

    if (!wide) {
      return Column(children: [card, const SizedBox(height: 16), level]);
    }
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 2, child: card),
        const SizedBox(width: 24),
        Expanded(child: level),
      ]),
    );
  }

  Widget _accountSettings() {
    return _SettingsCard(
      icon: Icons.manage_accounts_outlined,
      title: 'Account Settings',
      children: [
        _NavRow(icon: Icons.person, iconBg: AppColors.secondaryFixed, iconColor: AppColors.onSecondaryContainer,
            title: 'Personal Info', subtitle: 'Update your details'),
        _NavRow(icon: Icons.lock_outline, iconBg: AppColors.secondaryFixed, iconColor: AppColors.onSecondaryContainer,
            title: 'Change Password', subtitle: 'Manage security', last: true),
      ],
    );
  }

  Widget _appPreferences() {
    return _SettingsCard(
      icon: Icons.tune,
      title: 'App Preferences',
      children: [
        _ToggleRow(
          icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Alerts & summaries',
          value: _notifications, onChanged: (v) => setState(() => _notifications = v),
        ),
        _ToggleRow(
          icon: Icons.dark_mode_outlined, title: 'Dark Mode', subtitle: 'Theme toggle', last: true,
          value: _darkMode, onChanged: (v) => setState(() => _darkMode = v),
        ),
      ],
    );
  }

  Widget _logout(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.go('/login'),
      icon: const Icon(Icons.logout),
      label: Text('LOG OUT', style: AppText.labelSm.copyWith(color: AppColors.primary, letterSpacing: 1.2)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.icon, required this.title, required this.children});
  final IconData icon;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.whey),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppText.headlineSm),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, this.last = false,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.whey)),
      ),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: iconBg, child: Icon(icon, size: 20, color: iconColor)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.bodyLg),
            Text(subtitle, style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.outline),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon, required this.title, required this.subtitle,
    required this.value, required this.onChanged, this.last = false,
  });
  final IconData icon;
  final String title, subtitle;
  final bool value, last;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.whey)),
      ),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.tertiaryFixed,
            child: Icon(icon, size: 20, color: AppColors.onTertiaryFixed)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.bodyLg),
            Text(subtitle, style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.burntCaramel,
        ),
      ]),
    );
  }
}
