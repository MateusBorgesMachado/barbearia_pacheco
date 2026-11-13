import 'package:barbearia_pacheco/features/auth/models/user_model.dart';

class AuthProfileException implements Exception {
  final String message;
  const AuthProfileException([
    this.message = 'Não foi possível carregar seu perfil. Tente novamente.',
  ]);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> updateName({required String userId, required String newName});

  Future<void> updateActiveStatus({
    required String userId,
    required bool isActive,
  });

  Future<void> resetPassword(String email);

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}
