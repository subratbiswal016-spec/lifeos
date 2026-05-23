import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({this.isLoading = false, this.error, this.isAuthenticated = false});

  AuthState copyWith({bool? isLoading, String? error, bool? isAuthenticated}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error is not retained unless explicitly passed null? Wait, if we pass null it clears. Actually we should clear error usually.
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.login(email, password);
      final token = response['data']?['accessToken'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Token missing from response');
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.response?.data['message'] ?? e.message ?? 'An error occurred'
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.register(name, email, password);
      final token = response['data']?['accessToken'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Token missing from response');
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.response?.data['message'] ?? e.message ?? 'An error occurred'
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _storage.delete(key: 'jwt_token');
    state = state.copyWith(isAuthenticated: false, error: null);
  }
}
