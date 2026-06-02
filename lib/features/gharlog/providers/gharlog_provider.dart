import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member_model.dart';
import '../models/symptom_log_model.dart';
import '../repositories/gharlog_repository.dart';

final gharLogMembersProvider = StateNotifierProvider<GharLogMembersNotifier, AsyncValue<List<FamilyMemberModel>>>((ref) {
  final repository = ref.watch(gharLogRepositoryProvider);
  return GharLogMembersNotifier(repository);
});

class GharLogMembersNotifier extends StateNotifier<AsyncValue<List<FamilyMemberModel>>> {
  final GharLogRepository _repository;

  GharLogMembersNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    state = const AsyncValue.loading();
    try {
      final members = await _repository.fetchMembers();
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMember(FamilyMemberModel member) async {
    try {
      final newMember = await _repository.addMember(member);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newMember]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMember(String memberId, FamilyMemberModel member) async {
    try {
      final updatedMember = await _repository.updateMember(memberId, member);
      if (state.hasValue) {
        state = AsyncValue.data([
          for (final m in state.value!)
            if (m.id == memberId) updatedMember else m
        ]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await _repository.deleteMember(memberId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((m) => m.id != memberId).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for symptoms of a specific member
final symptomsProvider = StateNotifierProvider.family<SymptomsNotifier, AsyncValue<List<SymptomLogModel>>, String>((ref, memberId) {
  final repository = ref.watch(gharLogRepositoryProvider);
  return SymptomsNotifier(repository, memberId);
});

class SymptomsNotifier extends StateNotifier<AsyncValue<List<SymptomLogModel>>> {
  final GharLogRepository _repository;
  final String _memberId;

  SymptomsNotifier(this._repository, this._memberId) : super(const AsyncValue.loading()) {
    fetchSymptoms();
  }

  Future<void> fetchSymptoms() async {
    state = const AsyncValue.loading();
    try {
      final symptoms = await _repository.fetchSymptoms(_memberId);
      state = AsyncValue.data(symptoms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSymptom(SymptomLogModel symptom) async {
    try {
      final newSymptom = await _repository.logSymptom(symptom);
      if (state.hasValue) {
        state = AsyncValue.data([newSymptom, ...state.value!]); // Add to top
      }
    } catch (e) {
      rethrow;
    }
  }
}
