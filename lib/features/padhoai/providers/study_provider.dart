import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/padhoai_repository.dart';

class StudyState {
  final bool isTracking;
  final int currentSessionDuration; // in seconds
  final String? activeSubject;

  StudyState({
    this.isTracking = false, 
    this.currentSessionDuration = 0,
    this.activeSubject,
  });

  StudyState copyWith({bool? isTracking, int? currentSessionDuration, String? activeSubject}) {
    return StudyState(
      isTracking: isTracking ?? this.isTracking,
      currentSessionDuration: currentSessionDuration ?? this.currentSessionDuration,
      activeSubject: activeSubject ?? this.activeSubject,
    );
  }
}

class StudyProviderNotifier extends StateNotifier<StudyState> {
  final PadhoaiRepository _repository;

  StudyProviderNotifier(this._repository) : super(StudyState());

  void startTracking(String subject) {
    state = state.copyWith(isTracking: true, activeSubject: subject, currentSessionDuration: 0);
  }

  void updateDuration(int seconds) {
    if (state.isTracking) {
      state = state.copyWith(currentSessionDuration: seconds);
    }
  }

  Future<void> endTracking(String notes) async {
    if (state.isTracking && state.activeSubject != null) {
      await _repository.saveSession({
        'subject': state.activeSubject,
        'duration': state.currentSessionDuration,
        'notes': notes,
      });
      state = state.copyWith(isTracking: false, currentSessionDuration: 0, activeSubject: null);
    }
  }
}

final studyProvider = StateNotifierProvider<StudyProviderNotifier, StudyState>((ref) {
  return StudyProviderNotifier(ref.watch(padhoaiRepositoryProvider));
});
