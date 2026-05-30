import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

final dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    final response = await dioClient.dio.get(ApiEndpoints.dashboard);
    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load dashboard data');
    }
  } catch (e) {
    throw Exception('Failed to load dashboard data: $e');
  }
});
