import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';

class CheckinRepository {
  final DioClient _dioClient;

  CheckinRepository(this._dioClient);

  Future<ApiResponse<List<dynamic>>> getCheckins() async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.checkins}/month');
      return ApiResponse<List<dynamic>>.fromJson(
        response.data, 
        (data) => data as List<dynamic>
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> submitCheckin(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(ApiEndpoints.checkins, data: data);
      return ApiResponse<dynamic>.fromJson(
        response.data, 
        (data) => data
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}

final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  return CheckinRepository(ref.watch(dioClientProvider));
});
