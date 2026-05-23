import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';


class AiRepository {
  final DioClient _dioClient;

  AiRepository(this._dioClient);

  Future<ApiResponse<Map<String, dynamic>>> sendMessage(String message) async {
    try {
      final response = await _dioClient.dio.post(ApiEndpoints.aiChat, data: {
        'message': message,
      });
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data, 
        (data) => data as Map<String, dynamic>
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioClientProvider));
});
