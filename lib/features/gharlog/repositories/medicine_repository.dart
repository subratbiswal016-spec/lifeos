import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/medicine_model.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MedicineRepository(dioClient);
});

class MedicineRepository {
  final DioClient _dioClient;

  MedicineRepository(this._dioClient);

  Future<List<MedicineModel>> fetchMedicines(String memberId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.medicines(memberId));
      final List data = response.data['data'] ?? [];
      return data.map((json) => MedicineModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MedicineModel> addMedicine(MedicineModel medicine) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.addMedicine,
        data: medicine.toJson(),
      );
      return MedicineModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<MedicineModel> toggleMedicineLog(String medicineId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.toggleMedicine(medicineId),
      );
      return MedicineModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _dioClient.dio.delete('${ApiEndpoints.addMedicine}/$medicineId');
    } catch (e) {
      rethrow;
    }
  }
}
