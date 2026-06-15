import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

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
      emit(LoginError(error.toString().replaceAll("Exception: ", "")));
    }
  }
}
