import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
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

  LoginCubit(this._authRepository) : super(const LoginInitial());

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const LoginLoading());

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      emit(LoginSuccess(user));
    } catch (error) {
      emit(LoginError(traduzirErroSupabase(error)));
    }
  }
}
