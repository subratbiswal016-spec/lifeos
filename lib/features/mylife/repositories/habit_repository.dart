import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/habit_model.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HabitRepository(dioClient);
});

class HabitRepository {
  final DioClient _dioClient;

  HabitRepository(this._dioClient);

  Future<List<HabitModel>> fetchHabits() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.habits);
      final List data = response.data['data'] ?? [];
      return data.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HabitModel>> fetchTodayHabits() async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.habits}/today');
      final List data = response.data['data'] ?? [];
      return data.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.habits,
        data: habit.toJson(),
      );
      return HabitModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitModel> toggleHabitCompletion(String habitId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.toggleHabit(habitId),
      );
      return HabitModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _dioClient.dio.delete('${ApiEndpoints.habits}/$habitId');
    } catch (e) {
      rethrow;
    }
  }
}
