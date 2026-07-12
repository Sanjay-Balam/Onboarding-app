import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin.dart';
import '../../data/api_client.dart';
import '../../data/open_url_stub.dart' if (dart.library.html) '../../data/open_url_web.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

const _docLabels = {
  'AADHAAR_FRONT': 'Aadhaar (Front)',
  'AADHAAR_BACK': 'Aadhaar (Back)',
  'PAN': 'PAN Card',
};

PillTone _tone(String status) => switch (status) {
      'APPROVED' => PillTone.verified,
      'PENDING_APPROVAL' => PillTone.pending,
      'REJECTED' => PillTone.error,
      'IN_PROGRESS' => PillTone.warning,
      _ => PillTone.inactive,
    };

String _statusLabel(String s) => switch (s) {
      'PENDING_APPROVAL' => 'Pending',
      'IN_PROGRESS' => 'In Progress',
      'NOT_STARTED' => 'Not Started',
      _ => s[0] + s.substring(1).toLowerCase(),
    };

class VerificationQueueScreen extends ConsumerWidget {
  const VerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminChefsProvider);
    return AdminScaffold(
      currentRoute: '/admin/kyc',
      body: LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 1100 ? 3 : (c.maxWidth >= 720 ? 2 : 1);
        return RefreshIndicator(
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
                    Text('Verification Queue', style: AppText.displayLg),
                    const SizedBox(height: 4),
                    Text('Review and approve chef KYC documents.',
                        style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    async.when(
                      loading: () => const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                      error: (e, _) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Failed to load: $e', style: AppText.bodyMd)),
                      data: (chefs) {
                        // Queue = chefs who have started/submitted KYC.
                        final queue = chefs.where((c) => c.status != 'NOT_STARTED').toList();
                        if (queue.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text('No chefs awaiting verification.',
                                textAlign: TextAlign.center,
                                style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                          );
                        }
                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: 0.85,
                          children: [for (final chef in queue) _ChefCard(chef: chef)],
                        );
                      },
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
}

class _ChefCard extends StatelessWidget {
  const _ChefCard({required this.chef});
  final AdminChef chef;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(height: 80, color: AppColors.surfaceContainerHigh),
            Positioned(top: 12, right: 12, child: StatusPill(_statusLabel(chef.status), tone: _tone(chef.status))),
            Positioned(
              bottom: -36, left: 20,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
                ),
                child: const Icon(Icons.person, size: 34, color: AppColors.onSurfaceVariant),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(chef.name, style: AppText.headlineSm.copyWith(fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(chef.email, style: AppText.bodyMd.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 8),
              _row('Documents', '${chef.docCount}/3'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => _ReviewSheet(chef: chef),
                  ),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: Text('REVIEW PROFILE',
                      style: AppText.labelSm.copyWith(color: AppColors.clottedCream, letterSpacing: 1)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkGanache,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppText.bodyMd.copyWith(color: AppColors.outline)),
        Text(value, style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600)),
      ]);
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.chef});
  final AdminChef chef;
  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late Future<List<AdminDoc>> _docs;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _docs = ref.read(adminChefsProvider.notifier).docs(widget.chef.id);
  }

  Future<void> _view(String docId) async {
    try {
      final url = await ref.read(adminChefsProvider.notifier).docUrl(docId);
      openUrl(url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _decide(bool approve) async {
    setState(() => _acting = true);
    try {
      final n = ref.read(adminChefsProvider.notifier);
      approve ? await n.approve(widget.chef.id) : await n.reject(widget.chef.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(approve ? 'Approved ${widget.chef.name}' : 'Rejected ${widget.chef.name}')));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999))),
            ),
            const SizedBox(height: 16),
            Text(widget.chef.name, style: AppText.headlineSm),
            Text(widget.chef.email, style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            StatusPill(_statusLabel(widget.chef.status), tone: _tone(widget.chef.status)),
            const SizedBox(height: 16),
            Text('KYC DOCUMENTS', style: AppText.labelSm),
            const SizedBox(height: 8),
            Flexible(
              child: FutureBuilder<List<AdminDoc>>(
                future: _docs,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Padding(padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                  }
                  final docs = snap.data!;
                  if (docs.isEmpty) return Text('No documents.', style: AppText.bodyMd);
                  return ListView(shrinkWrap: true, children: [
                    for (final d in docs)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(children: [
                          Icon(d.mimeType == 'application/pdf' ? Icons.picture_as_pdf : Icons.image,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_docLabels[d.type] ?? d.type,
                                  style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                              if (d.verified) Text('Verified', style: AppText.labelSm.copyWith(color: AppColors.success)),
                            ]),
                          ),
                          TextButton.icon(
                            onPressed: () => _view(d.id),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('View'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          ),
                        ]),
                      ),
                  ]);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _acting ? null : () => _decide(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _acting ? null : () => _decide(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _acting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                      : const Text('Approve'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
