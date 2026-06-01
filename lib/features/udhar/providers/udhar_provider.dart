import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/udhar_model.dart';

final udharProvider = FutureProvider.autoDispose<List<UdharModel>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  try {
    final response = await dioClient.dio.get(ApiEndpoints.udhar);
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => UdharModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load udhar transactions');
  } catch (e) {
    throw Exception('Error loading udhar transactions: $e');
  }
});

class UdharNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UdharNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addUdhar(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.dio.post(ApiEndpoints.udhar, data: data);
      ref.invalidate(udharProvider);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateUdhar(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.dio.put('${ApiEndpoints.udhar}/$id', data: data);
      ref.invalidate(udharProvider);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleSettled(String id, bool currentStatus) async {
    await updateUdhar(id, {'isSettled': !currentStatus});
  }

  Future<void> deleteUdhar(String id) async {
    state = const AsyncValue.loading();
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.dio.delete('${ApiEndpoints.udhar}/$id');
      ref.invalidate(udharProvider);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final udharNotifierProvider = StateNotifierProvider<UdharNotifier, AsyncValue<void>>((ref) {
  return UdharNotifier(ref);
});
