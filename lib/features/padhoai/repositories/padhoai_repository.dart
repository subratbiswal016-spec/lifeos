import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/subject_model.dart';

class PadhoaiRepository {
  final DioClient _dioClient;

  PadhoaiRepository(this._dioClient);

  Future<ApiResponse<List<SubjectModel>>> getSubjects() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.subjects);
      return ApiResponse<List<SubjectModel>>.fromJson(
        response.data, 
        (data) => (data as List<dynamic>)
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<SubjectModel>> addSubject(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(ApiEndpoints.subjects, data: data);
      return ApiResponse<SubjectModel>.fromJson(
        response.data, 
        (data) => SubjectModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> saveSession(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post('${ApiEndpoints.study}/sessions', data: data);
      return ApiResponse<dynamic>.fromJson(
        response.data, 
        (data) => data
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> deleteSubject(String id) async {
    try {
      final response = await _dioClient.dio.delete('${ApiEndpoints.subjects}/$id');
      return ApiResponse<dynamic>.fromJson(
        response.data, 
        (data) => data
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}

final padhoaiRepositoryProvider = Provider<PadhoaiRepository>((ref) {
  return PadhoaiRepository(ref.watch(dioClientProvider));
});
