import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/family_member_model.dart';
import '../models/medicine_log_model.dart';
import '../models/symptom_log_model.dart';

final gharLogRepositoryProvider = Provider<GharLogRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GharLogRepository(dioClient);
});

class GharLogRepository {
  final DioClient _dioClient;

  GharLogRepository(this._dioClient);

  Future<List<FamilyMemberModel>> fetchMembers() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.members);
      final List data = response.data['data'] ?? [];
      return data.map((json) => FamilyMemberModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<FamilyMemberModel> addMember(FamilyMemberModel member) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.members,
        data: member.toJson(),
      );
      return FamilyMemberModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SymptomLogModel>> fetchSymptoms(String memberId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.symptoms(memberId));
      final List data = response.data['data'] ?? [];
      return data.map((json) => SymptomLogModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SymptomLogModel> logSymptom(SymptomLogModel log) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.addSymptom,
        data: log.toJson(),
      );
      return SymptomLogModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await _dioClient.dio.delete('${ApiEndpoints.members}/$memberId');
    } catch (e) {
      rethrow;
    }
  }
}
