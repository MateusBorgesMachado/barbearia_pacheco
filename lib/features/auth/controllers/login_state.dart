import 'package:barbearia_pacheco/features/auth/models/user_model.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserModel user;
  const LoginSuccess(this.user);
}

class LoginPasswordResetSent extends LoginState {
  const LoginPasswordResetSent();
}

class LoginError extends LoginState {
  final String errorMessage;
  const LoginError(this.errorMessage);
}
