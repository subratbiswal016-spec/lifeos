import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

final dailyTipProvider = FutureProvider.autoDispose<String>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    final response = await dioClient.dio.get('${ApiEndpoints.ai}/daily-tip');
    if (response.data['success'] == true) {
      return response.data['data']['tip'] as String;
    } else {
      return "Keep pushing forward! Even small steps count. (Tip currently unavailable)";
    }
  } catch (e) {
    return "Keep pushing forward! Even small steps count. (Tip currently unavailable)";
  }
});
