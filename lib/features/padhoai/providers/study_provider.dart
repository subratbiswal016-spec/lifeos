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

  String? _sessionId;

  Future<void> startTracking(String subjectId, bool isPomodoroMode) async {
    state = state.copyWith(isTracking: true, activeSubject: subjectId, currentSessionDuration: 0);
    final response = await _repository.startSession({
      'subjectId': subjectId,
      'isPomodoroMode': isPomodoroMode,
    });
    if (response.success && response.data != null) {
      _sessionId = response.data['_id'];
    }
  }

  void updateDuration(int seconds) {
    if (state.isTracking) {
      state = state.copyWith(currentSessionDuration: seconds);
    }
  }

  Future<void> endTracking(String notes) async {
    if (state.isTracking && _sessionId != null) {
      await _repository.stopSession(_sessionId!, {
        'durationMinutes': state.currentSessionDuration ~/ 60,
        'note': notes,
        'mood': 4,
        'energyLevel': 4,
      });
      _sessionId = null;
      state = state.copyWith(isTracking: false, currentSessionDuration: 0, activeSubject: null);
    }
  }
}

final studyProvider = StateNotifierProvider<StudyProviderNotifier, StudyState>((ref) {
  return StudyProviderNotifier(ref.watch(padhoaiRepositoryProvider));
});

final todaySessionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(padhoaiRepositoryProvider);
  final response = await repo.getTodaySessions();
  if (response.success && response.data != null) {
    return response.data!;
  }
  return [];
});

final studyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(padhoaiRepositoryProvider);
  final response = await repo.getStudyStats();
  if (response.success && response.data != null) {
    return response.data!;
  }
  return {};
});
