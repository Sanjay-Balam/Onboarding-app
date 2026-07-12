import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});
  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(authProvider.notifier).login(_email.text.trim(), _password.text);
      if (!mounted) return;
      if (result.requires2fa) {
        context.go('/2fa');
      } else {
        context.go(result.user.isAdmin ? '/admin' : '/chef');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 860;
        final panel = _brandPanel();
        final form = _loginCard();
        if (wide) {
          return Row(children: [
            Expanded(child: panel),
            Expanded(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(64), child: form))),
          ]);
        }
        return SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 180, child: panel),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: form,
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _brandPanel() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.clottedCream, AppColors.surfaceContainerHighest],
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Why So Creamy', textAlign: TextAlign.center, style: AppText.displayLg),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text('The art of indulgent precision. Authenticate your craft.',
                textAlign: TextAlign.center,
                style: AppText.bodyLg.copyWith(color: AppColors.primary.withOpacity(0.9))),
          ),
        ]),
      );

  Widget _loginCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.clottedCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.whey),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(color: AppColors.whey, shape: BoxShape.circle),
                child: const Icon(Icons.cookie, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text('Login', style: AppText.headlineLg),
              const SizedBox(height: 4),
              Text('Enter your artisan credentials to access the portal',
                  style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
              Text('EMAIL ADDRESS', style: AppText.labelSm.copyWith(color: AppColors.primary, letterSpacing: 1)),
              const SizedBox(height: 8),
              _field(controller: _email, hint: 'artisan@whysocreamy.com', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              Text('PASSWORD', style: AppText.labelSm.copyWith(color: AppColors.primary, letterSpacing: 1)),
              const SizedBox(height: 8),
              _field(controller: _password, hint: '••••••••', obscure: true, onSubmit: _signIn),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _signIn,
                  icon: _loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.clottedCream))
                      : Text('SIGN IN', style: AppText.labelSm.copyWith(color: AppColors.clottedCream, letterSpacing: 1.5)),
                  label: _loading ? const SizedBox.shrink() : const Icon(Icons.arrow_forward, size: 16),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkGanache,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('CONFIDENTIAL SYSTEM ACCESS',
            style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.7), letterSpacing: 2)),
      ]),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboard,
    VoidCallback? onSubmit,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      onSubmitted: onSubmit == null ? null : (_) => onSubmit(),
      style: AppText.bodyMd.copyWith(color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.bodyMd.copyWith(color: AppColors.outline),
        filled: true,
        fillColor: AppColors.surfaceBright,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _b(AppColors.whey),
        enabledBorder: _b(AppColors.whey),
        focusedBorder: _b(AppColors.burntCaramel, 1.5),
      ),
    );
  }

  OutlineInputBorder _b(Color col, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: col, width: w),
      );
}
