import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/padhoai_repository.dart';

class SubjectState {
  final bool isLoading;
  final List<dynamic> subjects;
  final String? error;

  SubjectState({this.isLoading = false, this.subjects = const [], this.error});

  SubjectState copyWith({bool? isLoading, List<dynamic>? subjects, String? error}) {
    return SubjectState(
      isLoading: isLoading ?? this.isLoading,
      subjects: subjects ?? this.subjects,
      error: error ?? this.error,
    );
  }
}

class SubjectProviderNotifier extends StateNotifier<SubjectState> {
  final PadhoaiRepository _repository;

  SubjectProviderNotifier(this._repository) : super(SubjectState());

  Future<void> fetchSubjects() async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repository.getSubjects();
    
    if (response.success) {
      state = state.copyWith(isLoading: false, subjects: response.data ?? []);
    } else {
      state = state.copyWith(isLoading: false, error: response.error ?? 'Failed to load subjects');
    }
  }
}

final subjectProvider = StateNotifierProvider<SubjectProviderNotifier, SubjectState>((ref) {
  return SubjectProviderNotifier(ref.watch(padhoaiRepositoryProvider));
});
