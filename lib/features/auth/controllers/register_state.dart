import 'package:barbearia_pacheco/core/models/user_model.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserModel user;
  const RegisterSuccess(this.user);
}

class RegisterError extends RegisterState {
  final String errorMessage;
  const RegisterError(this.errorMessage);
}
