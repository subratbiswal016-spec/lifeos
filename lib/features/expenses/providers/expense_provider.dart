import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/expense_model.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ExpensesNotifier(dioClient);
});

class ExpensesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final DioClient _dioClient;

  ExpensesNotifier(this._dioClient) : super(const AsyncValue.loading()) {
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      state = const AsyncValue.loading();
      final response = await _dioClient.dio.get('${ApiEndpoints.baseUrl}/expenses');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final expensesList = (data['expenses'] as List).map((e) => Expense.fromJson(e)).toList();
        final budget = (data['monthlyBudget'] as num).toDouble();
        
        state = AsyncValue.data({
          'expenses': expensesList,
          'monthlyBudget': budget,
        });
      } else {
        state = AsyncValue.error(response.data['message'] ?? 'Error fetching expenses', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<String?> addExpense(double amount, String category, String type, String? note) async {
    try {
      final response = await _dioClient.dio.post('${ApiEndpoints.baseUrl}/expenses', data: {
        'amount': amount,
        'category': category,
        'type': type,
        'note': note,
      });

      if (response.data['success'] == true) {
        // Refresh the list
        await fetchExpenses();
        // Return the limit message to show in a toast
        return response.data['data']['limitMessage'] as String?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _dioClient.dio.delete('${ApiEndpoints.baseUrl}/expenses/$id');
      if (response.data['success'] == true) {
        await fetchExpenses();
      }
    } catch (e) {
      rethrow;
    }
  }
}
