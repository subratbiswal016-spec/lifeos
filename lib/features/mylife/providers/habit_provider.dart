import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';

final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitModel>>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitsNotifier(repository);
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  final HabitRepository _repository;

  HabitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchHabits();
  }

  Future<void> fetchHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _repository.fetchTodayHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    try {
      final newHabit = await _repository.createHabit(habit);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newHabit]);
      }
    } catch (e) {
      // Could handle error via global provider or throw to UI
      rethrow;
    }
  }

  Future<void> toggleHabitCompletion(String id) async {
    // Optimistic update
    if (state.hasValue) {
      final previousState = state.value!;
      state = AsyncValue.data([
        for (final habit in previousState)
          if (habit.id == id)
            habit.copyWith(isCompletedToday: !habit.isCompletedToday)
          else
            habit
      ]);

      try {
        final updatedHabit = await _repository.toggleHabitCompletion(id);
        // Replace with server truth
        state = AsyncValue.data([
          for (final habit in state.value!)
            if (habit.id == id) updatedHabit else habit
        ]);
      } catch (e) {
        // Rollback on error
        state = AsyncValue.data(previousState);
        rethrow;
      }
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((h) => h.id != id).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
