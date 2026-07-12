import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

class Profile {
  Profile({
    required this.email,
    this.name,
    this.phone,
    required this.roles,
    this.onboardingStatus,
    this.is2faEnabled = false,
    this.createdAt,
    this.avatarUrl,
  });
  final String email;
  final String? name;
  final String? phone;
  final List<String> roles;
  final String? onboardingStatus;
  final bool is2faEnabled;
  final DateTime? createdAt;
  final String? avatarUrl;

  bool get isChef => roles.contains('CHEF');
  bool get verified => onboardingStatus == 'APPROVED';

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        email: j['email'] as String,
        name: j['name'] as String?,
        phone: j['phone'] as String?,
        roles: (j['roles'] as List? ?? []).cast<String>(),
        onboardingStatus: j['onboardingStatus'] as String?,
        is2faEnabled: j['is2faEnabled'] == true,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'] as String) : null,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

final profileProvider = FutureProvider<Profile>((ref) async {
  final data = await ref.read(apiProvider).get<Map<String, dynamic>>('/auth/profile');
  return Profile.fromJson(data);
});
