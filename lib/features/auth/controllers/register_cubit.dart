import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

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
      emit(RegisterError(error.toString().replaceAll("Exception: ", "")));
    }
  }
}
