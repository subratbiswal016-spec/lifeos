import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/padhoai_repository.dart';
import '../models/subject_model.dart';

class SubjectState {
  final bool isLoading;
  final List<SubjectModel> subjects;
  final String? error;

  SubjectState({this.isLoading = false, this.subjects = const [], this.error});

  SubjectState copyWith({bool? isLoading, List<SubjectModel>? subjects, String? error}) {
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

  Future<bool> addSubject(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repository.addSubject(data);
    
    if (response.success) {
      // Re-fetch subjects to ensure we have the latest list
      await fetchSubjects();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.error ?? 'Failed to add subject');
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repository.deleteSubject(id);
    
    if (response.success) {
      await fetchSubjects();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.error ?? 'Failed to delete subject');
      return false;
    }
  }
}

final subjectProvider = StateNotifierProvider<SubjectProviderNotifier, SubjectState>((ref) {
  return SubjectProviderNotifier(ref.watch(padhoaiRepositoryProvider));
});
