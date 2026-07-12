import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});
  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _nodes = List.generate(6, (_) => FocusNode());
  final _ctrls = List.generate(6, (_) => TextEditingController());
  int _seconds = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { t.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final n in _nodes) n.dispose();
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => context.go('/login')),
        title: Text('Why So Creamy', style: AppText.headlineSm.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.clottedCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Icon(Icons.gpp_good, size: 30, color: AppColors.burntCaramel),
                ),
                const SizedBox(height: 24),
                Text('Two-Factor Authentication', textAlign: TextAlign.center, style: AppText.headlineSm),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    children: const [
                      TextSpan(text: 'Please enter the 6-digit verification code sent to '),
                      TextSpan(text: 'u***@example.com', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [for (var i = 0; i < 6; i++) _otpBox(i)],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () { // TODO: verify OTP via API
                      final user = ref.read(authProvider).user;
                      context.go(user?.isAdmin == true ? '/admin' : '/chef');
                    },
                    icon: const Text('Verify Code'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkGanache,
                      foregroundColor: AppColors.clottedCream,
                      textStyle: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text("Didn't receive a code?", style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                TextButton.icon(
                  onPressed: _seconds == 0 ? () => setState(() => _seconds = 59) : null,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Resend Code'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.burntCaramel),
                ),
                Text.rich(
                  TextSpan(
                    style: AppText.labelSm.copyWith(color: AppColors.outline),
                    children: [
                      const TextSpan(text: 'Wait '),
                      TextSpan(
                          text: '00:${_seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' before resending.'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int i) {
    return Container(
      width: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _ctrls[i],
        focusNode: _nodes[i],
        autofocus: i == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppText.headlineSm.copyWith(fontSize: 24),
        onChanged: (v) => _onChanged(i, v),
        decoration: const InputDecoration(
          counterText: '',
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whey, width: 2)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.burntCaramel, width: 2)),
        ),
      ),
    );
  }
}
