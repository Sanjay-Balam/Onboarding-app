import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NavItem {
  const NavItem(this.icon, this.label, this.route, {this.badge});
  final IconData icon;
  final String label;
  final String? route;
  final String? badge;
}

const _adminItems = [
  NavItem(Icons.dashboard_outlined, 'Dashboard', '/admin'),
  NavItem(Icons.group_outlined, 'Chefs', '/admin/staff'),
  NavItem(Icons.verified_user_outlined, 'KYC Queue', '/admin/kyc', badge: '3'),
  NavItem(Icons.analytics_outlined, 'Reports', null),
  NavItem(Icons.settings_outlined, 'Settings', '/admin/profile'),
];

const _adminMobileItems = [
  NavItem(Icons.home_outlined, 'Home', '/admin'),
  NavItem(Icons.group_outlined, 'Chefs', '/admin/staff'),
  NavItem(Icons.fact_check_outlined, 'Verify', '/admin/kyc'),
  NavItem(Icons.person_outline, 'Profile', '/admin/profile'),
];

const _chefItems = [
  NavItem(Icons.home_outlined, 'Home', '/chef'),
  NavItem(Icons.fingerprint, 'Attendance', null),
  NavItem(Icons.fact_check_outlined, 'Verify', '/chef/onboarding'),
  NavItem(Icons.person_outline, 'Profile', null),
];

void _go(BuildContext context, NavItem item) {
  if (item.route != null) {
    context.go(item.route!);
  } else {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${item.label} — coming soon')));
  }
}

/// Admin shell: sidebar drawer on wide screens, top bar + bottom nav on mobile.
class AdminScaffold extends StatelessWidget {
  const AdminScaffold({super.key, required this.body, required this.currentRoute});
  final Widget body;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(currentRoute: currentRoute),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: _mobileBar(context),
      body: body,
      bottomNavigationBar: _BottomNav(items: _adminMobileItems, currentRoute: currentRoute),
    );
  }

  PreferredSizeWidget _mobileBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        titleSpacing: 16,
        title: Row(children: [
          const _Avatar(size: 32),
          const SizedBox(width: 12),
          Text('Why So Creamy',
              style: AppText.headlineSm.copyWith(fontWeight: FontWeight.w700)),
        ]),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.settings_outlined)),
        ],
      );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              const _Avatar(size: 48),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Portal', style: AppText.headlineMd),
                Text('Operations Manager', style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ]),
            ]),
          ),
          const SizedBox(height: 32),
          for (final item in _adminItems) _SidebarTile(item: item, active: item.route == currentRoute),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('v1.0.4', style: AppText.labelSm.copyWith(color: AppColors.outline)),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.active});
  final NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 8),
      child: Material(
        color: active ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
        child: InkWell(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
          onTap: () => _go(context, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              Icon(item.icon, color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
              const SizedBox(width: 16),
              Text(item.label,
                  style: AppText.bodyMd.copyWith(
                    color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  )),
              if (item.badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.tertiaryFixed, borderRadius: BorderRadius.circular(999)),
                  child: Text(item.badge!,
                      style: AppText.labelSm.copyWith(color: AppColors.onTertiaryFixed, fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Chef shell: mobile top bar + bottom nav.
class ChefScaffold extends StatelessWidget {
  const ChefScaffold({super.key, required this.body, required this.currentRoute});
  final Widget body;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        titleSpacing: 16,
        title: Row(children: [
          const _Avatar(size: 32, color: AppColors.secondaryContainer),
          const SizedBox(width: 12),
          Text('Why So Creamy', style: AppText.headlineSm),
        ]),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.settings_outlined)),
        ],
      ),
      body: body,
      bottomNavigationBar: _BottomNav(items: _chefItems, currentRoute: currentRoute),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.items, required this.currentRoute});
  final List<NavItem> items;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Color(0x0A0F172A), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items) _BottomTab(item: item, active: item.route == currentRoute),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({required this.item, required this.active});
  final NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final content = Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(item.icon,
          color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant, size: 24),
      const SizedBox(height: 4),
      Text(item.label,
          style: AppText.labelSm.copyWith(
              color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)),
    ]);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _go(context, item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 8, vertical: 4),
        decoration: active
            ? BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(999))
            : null,
        child: content,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Icon(Icons.person, size: size * 0.6, color: AppColors.onSurfaceVariant),
      );
}
