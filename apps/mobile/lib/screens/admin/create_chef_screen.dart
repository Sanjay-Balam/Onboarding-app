import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/admin.dart';
import '../../data/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class CreateChefScreen extends ConsumerStatefulWidget {
  const CreateChefScreen({super.key});
  @override
  ConsumerState<CreateChefScreen> createState() => _CreateChefScreenState();
}

class _CreateChefScreenState extends ConsumerState<CreateChefScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _enforce2fa = false;
  bool _showPw = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || !_email.text.contains('@') ||
        _phone.text.trim().length < 6 || _password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all fields (password ≥ 6 chars)')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminChefsProvider.notifier).createChef(
            name: _name.text.trim(), email: _email.text.trim(),
            phone: _phone.text.trim(), password: _password.text, is2faEnabled: _enforce2fa,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chef ${_name.text.trim()} created')));
        context.go('/admin/staff');
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/admin/staff',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('PERSONNEL MANAGEMENT',
                    style: AppText.labelSm.copyWith(color: AppColors.burntCaramel, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('Onboard New Chef', style: AppText.displayLg),
                const SizedBox(height: 8),
                Text('Grant access to the dashboard and set the chef’s login credentials.',
                    style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                AppCard(
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _field('FULL NAME', _name, hint: 'e.g. Julian Ganache'),
                    const SizedBox(height: 20),
                    _field('EMAIL ADDRESS', _email, hint: 'chef@whysocreamy.com', keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _field('PHONE NUMBER', _phone, hint: '+91 90000 00000', keyboard: TextInputType.phone),
                    const SizedBox(height: 20),
                    _field('INITIAL PASSWORD', _password, hint: '••••••••', obscure: !_showPw,
                        suffix: IconButton(
                          icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.outline),
                          onPressed: () => setState(() => _showPw = !_showPw),
                        )),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.outlineVariant),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Enforce 2FA', style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      subtitle: Text('Require OTP on login.', style: AppText.bodyMd.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant)),
                      value: _enforce2fa,
                      activeColor: AppColors.onPrimary,
                      activeTrackColor: AppColors.burntCaramel,
                      onChanged: (v) => setState(() => _enforce2fa = v),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: _busy
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.clottedCream))
                              : const Icon(Icons.person_add_alt, size: 18),
                          label: const Text('Create Account'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.darkGanache, foregroundColor: AppColors.clottedCream,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _busy ? null : () => context.go('/admin/staff'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.outlineVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {String? hint, bool obscure = false, TextInputType? keyboard, Widget? suffix}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
      const SizedBox(height: 6),
      TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: AppText.bodyMd.copyWith(color: AppColors.primary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.bodyMd.copyWith(color: AppColors.outlineVariant),
          isDense: true,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant, width: 2)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.burntCaramel, width: 2)),
        ),
      ),
    ]);
  }
}
