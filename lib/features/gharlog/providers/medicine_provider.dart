import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineState {
  final List<dynamic> dueMedicines;
  
  MedicineState({this.dueMedicines = const []});
}

class MedicineProviderNotifier extends StateNotifier<MedicineState> {
  MedicineProviderNotifier() : super(MedicineState());

  void loadDueMedicines() {
    // Usually aggregates all medicines from the family tree locally
    // Or fetches a specific /api/medicines/due endpoint
    state = MedicineState(dueMedicines: [
      {'name': 'Dolo 650', 'for': 'Papa', 'time': '14:00', 'status': 'pending'}
    ]);
  }

  void markAsTaken(String medicineId) {
    // Update local state and sync to backend
  }
}

final medicineProvider = StateNotifierProvider<MedicineProviderNotifier, MedicineState>((ref) {
  return MedicineProviderNotifier();
});
