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

  Future<ApiResponse<SubjectModel>> updateSubject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.put('${ApiEndpoints.subjects}/$id', data: data);
      return ApiResponse<SubjectModel>.fromJson(
        response.data, 
        (data) => SubjectModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> startSession(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post('${ApiEndpoints.study}/session/start', data: data);
      return ApiResponse<dynamic>.fromJson(
        response.data, 
        (data) => data
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> stopSession(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.put('${ApiEndpoints.study}/session/$id/stop', data: data);
      return ApiResponse<dynamic>.fromJson(
        response.data, 
        (data) => data
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<dynamic>>> getTodaySessions() async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.study}/sessions/today');
      return ApiResponse<List<dynamic>>.fromJson(
        response.data, 
        (data) => data as List<dynamic>
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getStudyStats() async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.study}/stats');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data, 
        (data) => data as Map<String, dynamic>
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
