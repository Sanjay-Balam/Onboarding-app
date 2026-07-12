import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api_client.dart';
import '../../data/documents.dart';
import '../../data/file_pick_stub.dart' if (dart.library.html) '../../data/file_pick_web.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

class ChefOnboardingScreen extends ConsumerWidget {
  const ChefOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kyc = ref.watch(chefDocumentsProvider).valueOrNull;
    final docs = kyc?.docs ?? const <KycDoc>[];
    final uploaded = docs.map((d) => d.type).toSet();
    final aadhaarDone = uploaded.contains('AADHAAR_FRONT') && uploaded.contains('AADHAAR_BACK');
    final panDone = uploaded.contains('PAN');
    final approved = kyc?.approved ?? false;

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
                Text('Upload clear images of your official documents to complete verification.',
                    style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                if (kyc != null) _StatusBanner(status: kyc.status),
                const SizedBox(height: 8),
                _Stepper(documentsDone: aadhaarDone && panDone, verified: approved),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, c) {
                  final row = c.maxWidth >= 600;
                  final aadhaar = _DocCard(
                    icon: Icons.badge_outlined,
                    title: 'Aadhaar Card',
                    subtitle: 'Upload front and back images.',
                    done: aadhaarDone,
                    slots: const [
                      _SlotSpec('AADHAAR_FRONT', 'Upload Front'),
                      _SlotSpec('AADHAAR_BACK', 'Upload Back'),
                    ],
                  );
                  final pan = _DocCard(
                    icon: Icons.credit_card_outlined,
                    title: 'PAN Card',
                    subtitle: 'Upload front image only.',
                    done: panDone,
                    slots: const [_SlotSpec('PAN', 'Upload PAN')],
                  );
                  return row
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: aadhaar),
                          const SizedBox(width: 16),
                          Expanded(child: pan),
                        ])
                      : Column(children: [aadhaar, const SizedBox(height: 16), pan]);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotSpec {
  const _SlotSpec(this.type, this.label);
  final String type;
  final String label;
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.icon, required this.title, required this.subtitle, required this.done, required this.slots});
  final IconData icon;
  final String title, subtitle;
  final bool done;
  final List<_SlotSpec> slots;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: AppColors.tertiaryFixedDim),
                const SizedBox(width: 8),
                Text(title, style: AppText.headlineSm),
              ]),
              const SizedBox(height: 4),
              Text(subtitle, style: AppText.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant)),
            ]),
          ),
          StatusPill(done ? 'Uploaded' : 'Pending',
              tone: done ? PillTone.verified : PillTone.warning),
        ]),
        const SizedBox(height: 16),
        for (final s in slots) ...[_UploadSlot(type: s.type, label: s.label), const SizedBox(height: 12)],
      ]),
    );
  }
}

class _UploadSlot extends ConsumerStatefulWidget {
  const _UploadSlot({required this.type, required this.label});
  final String type;
  final String label;
  @override
  ConsumerState<_UploadSlot> createState() => _UploadSlotState();
}

class _UploadSlotState extends ConsumerState<_UploadSlot> {
  bool _busy = false;

  String _mime(String ext) {
    switch (ext.toLowerCase()) {
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'pdf': return 'application/pdf';
      default: return 'application/octet-stream';
    }
  }

  Future<void> _pick() async {
    try {
      final picked = await pickFile(); // web: <input type=file>, mobile: file_picker
      if (picked == null) return;
      setState(() => _busy = true);
      final ext = picked.name.contains('.') ? picked.name.split('.').last : '';
      await ref.read(chefDocumentsProvider.notifier)
          .upload(widget.type, picked.bytes, picked.name, _mime(ext));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.label} uploaded ✓')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kyc = ref.watch(chefDocumentsProvider).valueOrNull;
    final doc = kyc?.forType(widget.type);
    final uploaded = doc != null;
    final locked = kyc?.approved ?? false; // no replacing after approval
    final name = widget.label.replaceFirst('Upload ', '');

    // One consistent dashed camera box for every slot; whole box is tappable.
    return InkWell(
      onTap: (_busy || locked) ? null : _pick,
      borderRadius: BorderRadius.circular(8),
      child: DottedBorderBox(
        child: _busy
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  uploaded ? (doc.verified ? Icons.verified : Icons.check_circle) : Icons.add_a_photo_outlined,
                  size: 30,
                  color: uploaded
                      ? (doc.verified ? AppColors.success : AppColors.burntCaramel)
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(uploaded ? '$name ${doc.verified ? "verified" : "uploaded"}' : widget.label,
                    style: AppText.bodyMd.copyWith(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                if (uploaded && !locked) ...[
                  const SizedBox(height: 2),
                  Text('Tap to replace', style: AppText.labelSm.copyWith(color: AppColors.primary)),
                ],
              ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.documentsDone, required this.verified});
  final bool documentsDone;
  final bool verified;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _Step(label: 'Identity', state: _StepState.done),
          _StepLine(active: true),
          _Step(label: 'Documents', state: documentsDone ? _StepState.done : _StepState.active, index: '2'),
          _StepLine(active: documentsDone),
          _Step(
            label: 'Verification',
            state: verified ? _StepState.done : (documentsDone ? _StepState.active : _StepState.pending),
            index: '3',
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    late final Color bg, fg;
    late final IconData icon;
    late final String text;
    switch (status) {
      case 'APPROVED':
        bg = AppColors.success.withOpacity(0.12); fg = AppColors.success;
        icon = Icons.verified; text = 'KYC Approved — you are verified.';
      case 'PENDING_APPROVAL':
        bg = AppColors.tertiaryFixed; fg = AppColors.onTertiaryFixed;
        icon = Icons.hourglass_top; text = 'Submitted — under admin review.';
      case 'REJECTED':
        bg = AppColors.errorContainer; fg = AppColors.onErrorContainer;
        icon = Icons.cancel; text = 'Rejected — please re-upload your documents.';
      default:
        bg = AppColors.surfaceContainerHigh; fg = AppColors.onSurfaceVariant;
        icon = Icons.info_outline; text = 'Upload all documents to submit for verification.';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icon, color: fg, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.bodyMd.copyWith(color: fg, fontWeight: FontWeight.w600))),
      ]),
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
                    color: filled ? AppColors.onPrimary : AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
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

/// Dashed-border upload area (CustomPaint — no extra dependency).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(),
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
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
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8));
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
