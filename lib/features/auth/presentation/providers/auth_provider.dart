import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_api.dart';
import '../../domain/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _api = AuthApi();

  AuthNotifier() : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.login(email, password);

      final bool success = data['success'] ?? false;
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Error desconocido',
        );
        return false;
      }

      final String? token = data['token'];
      final Map<String, dynamic>? userJson = data['user'];

      if (token == null || userJson == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Respuesta inválida del servidor',
        );
        return false;
      }

      final user = UserModel.fromJson(userJson);
      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUser(jsonEncode(user.toJson()));

      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.register(data);
      final bool success = response['success'] ?? false;

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Error al registrar',
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearAll();
    state = AuthState();
  }

  Future<void> loadSession() async {
    try {
      final token = await SecureStorageService.getToken();
      final userJson = await SecureStorageService.getUser();
      if (token != null && userJson != null) {
        state = AuthState(
          user: UserModel.fromJson(jsonDecode(userJson)),
          isAuthenticated: true,
        );
      }
    } catch (e) {
      await SecureStorageService.clearAll();
    }
  }

  String _extractError(dynamic e) {
    final str = e.toString();
    if (str.contains('401')) return 'Credenciales inválidas';
    if (str.contains('400')) return 'Datos inválidos';
    if (str.contains('SocketException')) return 'Sin conexión al servidor';
    if (str.contains('Connection refused')) return 'Servidor no disponible';
    return 'Error: ${str.split(':').last.trim()}';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});