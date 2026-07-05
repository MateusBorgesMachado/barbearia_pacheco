import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;
  String traduzirErroSupabase(dynamic erro) {
    final erroString = erro.toString().toLowerCase();

    if (erroString.contains('authexception') ||
        erroString.contains('authapiexception')) {
      if (erroString.contains('invalid login credentials') ||
          erroString.contains('invalid_credentials')) {
        return 'E-mail ou senha incorretos. Tente novamente.';
      }
      if (erroString.contains('email not confirmed')) {
        return 'Por favor, confirme seu e-mail antes de fazer login.';
      }
      if (erroString.contains('user not found')) {
        return 'Nenhuma conta encontrada com este e-mail.';
      }
      if (erroString.contains('invalid email')) {
        return 'O formato do e-mail é inválido.';
      }

      return 'Erro de autenticação. Verifique seus dados e tente novamente.';
    }

    return 'Ocorreu um erro inesperado. Verifique sua conexão e tente novamente.';
  }

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  Future<void> registerNewUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(const RegisterLoading());

    try {
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      emit(RegisterSuccess(user));
    } catch (error) {
      emit(RegisterError(traduzirErroSupabase(error)));
    }
  }
}
