import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_visit_model.dart';
import '../repositories/gharlog_repository.dart';

final doctorVisitsProvider = StateNotifierProvider<DoctorVisitsNotifier, AsyncValue<List<DoctorVisitModel>>>((ref) {
  final repository = ref.watch(gharLogRepositoryProvider);
  return DoctorVisitsNotifier(repository);
});

class DoctorVisitsNotifier extends StateNotifier<AsyncValue<List<DoctorVisitModel>>> {
  final GharLogRepository _repository;

  DoctorVisitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    state = const AsyncValue.loading();
    try {
      final visits = await _repository.fetchAllVisits();
      state = AsyncValue.data(visits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVisit(DoctorVisitModel visit) async {
    try {
      final newVisit = await _repository.addDoctorVisit(visit);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newVisit]);
      }
    } catch (e) {
      rethrow;
    }
  }
}
