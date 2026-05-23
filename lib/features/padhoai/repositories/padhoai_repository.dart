import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';

class PadhoaiRepository {
  final DioClient _dioClient;

  PadhoaiRepository(this._dioClient);

  Future<ApiResponse<List<dynamic>>> getSubjects() async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.study}/subjects');
      return ApiResponse<List<dynamic>>.fromJson(
        response.data, 
        (data) => data as List<dynamic>
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
}

final padhoaiRepositoryProvider = Provider<PadhoaiRepository>((ref) {
  return PadhoaiRepository(ref.watch(dioClientProvider));
});
