import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// White card with the design's soft ambient shadow.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.color, this.border});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
        border: border,
      ),
      child: child,
    );
  }
}

enum PillTone { verified, pending, active, inactive, warning, error }

/// Small rounded status label (KYC / account status).
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, required this.tone, this.icon});
  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    late final Color bg, fg;
    switch (tone) {
      case PillTone.verified:
        bg = AppColors.surfaceContainerHigh; fg = AppColors.onSurface;
      case PillTone.pending:
        bg = AppColors.secondaryContainer; fg = AppColors.onSecondaryContainer;
      case PillTone.active:
        bg = AppColors.surfaceVariant; fg = AppColors.onSurface;
      case PillTone.inactive:
        bg = AppColors.surfaceContainerHighest; fg = AppColors.onSurfaceVariant;
      case PillTone.warning:
        bg = AppColors.tertiaryFixed; fg = AppColors.onTertiaryFixed;
      case PillTone.error:
        bg = AppColors.errorContainer; fg = AppColors.onErrorContainer;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label.toUpperCase(),
              style: AppText.labelSm.copyWith(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// "SECTION LABEL" small caps used above stat numbers.
class CapsLabel extends StatelessWidget {
  const CapsLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppText.labelSm.copyWith(
            color: color ?? AppColors.onSurfaceVariant, letterSpacing: 0.8),
      );
}
