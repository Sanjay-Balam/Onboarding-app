import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'auth.dart';

class KycDoc {
  KycDoc({required this.id, required this.type, required this.mimeType, required this.verified});
  final String id;
  final String type; // AADHAAR_FRONT | AADHAAR_BACK | PAN
  final String mimeType;
  final bool verified;
  factory KycDoc.fromJson(Map<String, dynamic> j) => KycDoc(
        id: j['id'] as String,
        type: j['type'] as String,
        mimeType: j['mimeType'] as String,
        verified: j['verified'] == true,
      );
}

class ChefKyc {
  ChefKyc({required this.status, required this.docs});
  final String status; // onboardingStatus
  final List<KycDoc> docs;

  bool get approved => status == 'APPROVED';
  bool get pendingReview => status == 'PENDING_APPROVAL';
  bool get rejected => status == 'REJECTED';
  KycDoc? forType(String type) => docs.where((d) => d.type == type).cast<KycDoc?>().firstOrNull;

  factory ChefKyc.fromJson(Map<String, dynamic> j) => ChefKyc(
        status: j['onboardingStatus'] as String? ?? 'NOT_STARTED',
        docs: (j['documents'] as List? ?? [])
            .map((e) => KycDoc.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ChefDocumentsNotifier extends AsyncNotifier<ChefKyc> {
  @override
  Future<ChefKyc> build() async {
    final data = await ref.read(apiProvider).get<Map<String, dynamic>>('/chef/documents');
    return ChefKyc.fromJson(data);
  }

  /// Upload a KYC file (multipart). Updates state from the response — no refetch.
  Future<void> upload(String type, Uint8List bytes, String filename, String mime) async {
    final dio = ref.read(dioProvider);
    final csrf = ref.read(authProvider).csrfToken;
    final form = FormData.fromMap({
      'type': type,
      'file': MultipartFile.fromBytes(bytes, filename: filename, contentType: DioMediaType.parse(mime)),
    });
    final res = await dio.post('/chef/documents',
        data: form, options: Options(headers: {if (csrf != null) 'x-csrf-token': csrf}));
    final status = res.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      final msg = (res.data is Map && res.data['message'] != null) ? res.data['message'].toString() : 'upload_failed';
      throw ApiException(status, res.data, msg);
    }
    final doc = KycDoc.fromJson(res.data as Map<String, dynamic>);
    final current = state.valueOrNull ?? ChefKyc(status: 'NOT_STARTED', docs: const []);
    final docs = [...current.docs]..removeWhere((d) => d.type == type)..add(doc);
    // Admin owns APPROVED/REJECTED; locally reflect PENDING vs IN_PROGRESS.
    final allIn = {'AADHAAR_FRONT', 'AADHAAR_BACK', 'PAN'}.every((t) => docs.any((d) => d.type == t));
    final newStatus = current.approved || current.rejected
        ? current.status
        : (allIn ? 'PENDING_APPROVAL' : 'IN_PROGRESS');
    state = AsyncData(ChefKyc(status: newStatus, docs: docs));
  }
}

final chefDocumentsProvider =
    AsyncNotifierProvider<ChefDocumentsNotifier, ChefKyc>(ChefDocumentsNotifier.new);
