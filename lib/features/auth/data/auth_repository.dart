import 'package:barbearia_pacheco/core/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> updateName({required String userId, required String newName});

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}
