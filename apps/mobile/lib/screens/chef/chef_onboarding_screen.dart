import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class ChefOnboardingScreen extends StatelessWidget {
  const ChefOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChefScaffold(
      currentRoute: '/chef/onboarding',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Complete Your KYC', style: AppText.displayLg),
                const SizedBox(height: 8),
                Text('Please upload clear images of your official documents to complete verification.',
                    style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                const _Stepper(),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, c) {
                  final row = c.maxWidth >= 600;
                  final cards = [
                    _AadhaarCard(),
                    _PanCard(),
                  ];
                  return row
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[1]),
                        ])
                      : Column(children: [cards[0], const SizedBox(height: 16), cards[1]]);
                }),
                const SizedBox(height: 24),
                const Divider(color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Documents submitted (mock)'))), // TODO: upload + submit
                    icon: const Text('Submit Documents'),
                    label: const Icon(Icons.arrow_forward, size: 18),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _Step(label: 'Identity', state: _StepState.done),
          _StepLine(active: true),
          _Step(label: 'Documents', state: _StepState.active, index: '2'),
          _StepLine(active: false),
          _Step(label: 'Verification', state: _StepState.pending, index: '3'),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.state, this.index});
  final String label;
  final _StepState state;
  final String? index;
  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;
    final filled = done || active;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: active ? Border.all(color: AppColors.primaryFixed, width: 4) : null,
        ),
        alignment: Alignment.center,
        child: done
            ? const Icon(Icons.check, size: 18, color: AppColors.onPrimary)
            : Text(index ?? '',
                style: AppText.bodyMd.copyWith(
                    color: filled ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 8),
      Text(label.toUpperCase(),
          style: AppText.labelSm.copyWith(
              color: filled ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: filled ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );
}

class _AadhaarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.badge_outlined, color: AppColors.tertiaryFixedDim),
                const SizedBox(width: 8),
                Text('Aadhaar Card', style: AppText.headlineSm),
              ]),
              const SizedBox(height: 4),
              Text('Upload front and back images.',
                  style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
            ]),
          ),
          const StatusPill('Pending', tone: PillTone.warning),
        ]),
        const SizedBox(height: 16),
        const _UploadZone(label: 'Upload Front'),
        const SizedBox(height: 16),
        const _UploadZone(label: 'Upload Back'),
      ]),
    );
  }
}

class _PanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.credit_card_outlined, color: AppColors.tertiaryFixedDim),
                const SizedBox(width: 8),
                Text('PAN Card', style: AppText.headlineSm),
              ]),
              const SizedBox(height: 4),
              Text('Upload front image only.',
                  style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
            ]),
          ),
          const StatusPill('Pending', tone: PillTone.warning),
        ]),
        const SizedBox(height: 16),
        // Uploaded state example
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Stack(children: [
            const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.outline)),
            Positioned(
              bottom: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, size: 18, color: AppColors.success),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text('pan_front_scan.jpg (2.4MB)',
            textAlign: TextAlign.center,
            style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
      ]),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // TODO: image picker + upload
      borderRadius: BorderRadius.circular(8),
      child: DottedBorderBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_a_photo_outlined, size: 30, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(label,
              style: AppText.bodyMd.copyWith(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// Dashed-border upload area (CustomPaint — no extra dependency).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(),
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(8));
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
