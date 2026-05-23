import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/checkin_repository.dart';

class CheckinState {
  final bool isLoading;
  final List<dynamic> history;
  final String? error;

  CheckinState({this.isLoading = false, this.history = const [], this.error});

  CheckinState copyWith({bool? isLoading, List<dynamic>? history, String? error}) {
    return CheckinState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      error: error ?? this.error,
    );
  }
}

class CheckinProviderNotifier extends StateNotifier<CheckinState> {
  final CheckinRepository _repository;

  CheckinProviderNotifier(this._repository) : super(CheckinState()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repository.getCheckins();
    
    if (response.success) {
      state = state.copyWith(isLoading: false, history: response.data ?? []);
    } else {
      state = state.copyWith(isLoading: false, error: response.error ?? 'Failed to load history');
    }
  }

  Future<bool> submit(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repository.submitCheckin(data);
    
    if (response.success) {
      await fetchHistory(); // Fetch latest history immediately so the UI is updated
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.error ?? 'Failed to submit check-in');
      return false;
    }
  }
}

final checkinProvider = StateNotifierProvider<CheckinProviderNotifier, CheckinState>((ref) {
  return CheckinProviderNotifier(ref.watch(checkinRepositoryProvider));
});
