import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/models/user_model.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      final String? userId = response.user?.id;
      if (userId == null) {
        throw Exception("Falha ao gerar ID do usuário no cadastro.");
      }

      return UserModel(id: userId, name: name, email: email, role: role);
    } catch (error) {
      throw Exception("Erro no cadastro: $error");
    }
  }

  @override
  Future<void> updateName({
    required String userId,
    required String newName,
  }) async {
    try {
      await _supabaseClient
          .from('users')
          .update({'name': newName})
          .eq('id', userId);
    } catch (error) {
      throw Exception("Erro ao atualizar o nome no banco: $error");
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      final String? userId = response.user?.id;
      if (userId == null) {
        throw Exception("Usuário autenticado inválido.");
      }

      final Map<String, dynamic> userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userData);
    } catch (error) {
      throw Exception("Erro no login: $error");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (error) {
      throw Exception("Erro ao deslogar: $error");
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return null;

      final Map<String, dynamic> userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (error) {
      return null;
    }
  }
}
