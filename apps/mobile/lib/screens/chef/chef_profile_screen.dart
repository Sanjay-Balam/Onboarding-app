import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/api_client.dart';
import '../../data/auth.dart';
import '../../data/file_pick_stub.dart' if (dart.library.html) '../../data/file_pick_web.dart';
import '../../data/profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_scaffold.dart';

const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

class ChefProfileScreen extends ConsumerWidget {
  const ChefProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return ChefScaffold(
      currentRoute: '/chef/profile',
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load: $e', style: AppText.bodyMd)),
        data: (p) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text('Profile', style: AppText.displayLg),
                  const SizedBox(height: 16),
                  _header(p),
                  const SizedBox(height: 16),
                  _personalDetails(p),
                  const SizedBox(height: 16),
                  _account(p),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(Profile p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.clottedCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whey),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: [
        _AvatarUploader(avatarUrl: p.avatarUrl),
        const SizedBox(height: 12),
        if (p.verified)
          const StatusPill('Verified Chef', tone: PillTone.verified, icon: Icons.verified),
        const SizedBox(height: 8),
        Text(p.name?.trim().isNotEmpty == true ? p.name! : p.email,
            style: AppText.headlineSm, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(p.roles.join(' · '),
            style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _personalDetails(Profile p) {
    return _card('Personal Details', Icons.contact_mail_outlined, [
      _row('Email Address', p.email),
      if (p.phone != null && p.phone!.isNotEmpty) _row('Phone Number', p.phone!),
      if (p.createdAt != null)
        _row('Date of Joining',
            '${p.createdAt!.day} ${_months[p.createdAt!.month - 1]}, ${p.createdAt!.year}'),
    ]);
  }

  Widget _account(Profile p) {
    return _card('Account', Icons.shield_outlined, [
      if (p.onboardingStatus != null)
        _row('KYC Status', _statusText(p.onboardingStatus!)),
      _row('Two-Factor Auth', p.is2faEnabled ? 'Enabled' : 'Disabled'),
    ]);
  }

  String _statusText(String s) => switch (s) {
        'APPROVED' => 'Approved',
        'PENDING_APPROVAL' => 'Pending Approval',
        'IN_PROGRESS' => 'In Progress',
        'REJECTED' => 'Rejected',
        _ => 'Not Started',
      };

  Widget _card(String title, IconData icon, List<Widget> rows) {
    return AppCard(
      border: Border.all(color: AppColors.surfaceVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppText.headlineSm.copyWith(fontSize: 18)),
        ]),
        const SizedBox(height: 12),
        const Divider(color: AppColors.surfaceVariant),
        const SizedBox(height: 4),
        ...rows,
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CapsLabel(label),
          const SizedBox(height: 2),
          Text(value, style: AppText.bodyMd.copyWith(color: AppColors.onSurface)),
        ]),
      );
}

class _AvatarUploader extends ConsumerStatefulWidget {
  const _AvatarUploader({this.avatarUrl});
  final String? avatarUrl;
  @override
  ConsumerState<_AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends ConsumerState<_AvatarUploader> {
  bool _busy = false;

  String? _mime(String ext) => switch (ext.toLowerCase()) {
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        _ => null,
      };

  void _snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pick() async {
    try {
      final picked = await pickFile(); // gallery/files
      if (picked == null) return;
      final ext = picked.name.contains('.') ? picked.name.split('.').last : '';
      final mime = _mime(ext);
      if (mime == null) return _snack('Choose a JPG or PNG image');
      setState(() => _busy = true);
      final dio = ref.read(dioProvider);
      final csrf = ref.read(authProvider).csrfToken;
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(picked.bytes, filename: picked.name, contentType: DioMediaType.parse(mime)),
      });
      final res = await dio.post('/auth/avatar',
          data: form, options: Options(headers: {if (csrf != null) 'x-csrf-token': csrf}));
      final status = res.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ApiException(status, res.data,
            (res.data is Map && res.data['message'] != null) ? res.data['message'].toString() : 'upload_failed');
      }
      ref.invalidate(profileProvider);
      _snack('Profile photo updated ✓');
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _pick,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant, shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 4),
            ),
            clipBehavior: Clip.antiAlias,
            child: _busy
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : (widget.avatarUrl != null
                    ? Image.network(widget.avatarUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant))
                    : const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant)),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle,
                border: Border.all(color: AppColors.clottedCream, width: 2),
              ),
              child: const Icon(Icons.photo_camera, size: 16, color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
