import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';

final medicineProvider = StateNotifierProvider.family<MedicineNotifier, AsyncValue<List<MedicineModel>>, String>((ref, memberId) {
  final repository = ref.watch(medicineRepositoryProvider);
  return MedicineNotifier(repository, memberId);
});

class MedicineNotifier extends StateNotifier<AsyncValue<List<MedicineModel>>> {
  final MedicineRepository _repository;
  final String _memberId;

  MedicineNotifier(this._repository, this._memberId) : super(const AsyncValue.loading()) {
    fetchMedicines();
  }

  Future<void> fetchMedicines() async {
    state = const AsyncValue.loading();
    try {
      final medicines = await _repository.fetchMedicines(_memberId);
      state = AsyncValue.data(medicines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      final newMedicine = await _repository.addMedicine(medicine);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newMedicine]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleMedicineLog(String medicineId) async {
    try {
      final updatedMedicine = await _repository.toggleMedicineLog(medicineId);
      if (state.hasValue) {
        state = AsyncValue.data([
          for (final med in state.value!)
            if (med.id == medicineId) updatedMedicine else med
        ]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _repository.deleteMedicine(medicineId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((m) => m.id != medicineId).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
