import 'package:barbearia_pacheco/features/auth/controllers/login_cubit.dart';
import 'package:barbearia_pacheco/features/auth/controllers/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/auth_error_cases.dart';
import '../../../support/fake_repositories.dart';
import '../../../support/record_states.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = LoginCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('começa em LoginInitial', () {
    expect(cubit.state, isA<LoginInitial>());
  });

  test('traduzirErroSupabase cobre as mensagens de autenticação', () {
    expectSupabaseAuthTranslations(cubit.traduzirErroSupabase);
  });

  test('signIn emite loading e sucesso', () async {
    repository.user = sampleUser(role: 'barber');

    final states = await recordStates(
      cubit,
      () => cubit.signInWithEmailAndPassword(
        email: 'ana@example.com',
        password: '123456',
      ),
    );

    expect(states[0], isA<LoginLoading>());
    final success = states[1] as LoginSuccess;
    expect(success.user.role, 'barber');
    expect(repository.lastSignInEmail, 'ana@example.com');
    expect(repository.lastSignInPassword, '123456');
  });

  test('signIn emite o erro traduzido', () async {
    repository.signInError = Exception('AuthException: invalid login credentials');

    final states = await recordStates(
      cubit,
      () => cubit.signInWithEmailAndPassword(
        email: 'ana@example.com',
        password: 'errada',
      ),
    );

    expect(states[0], isA<LoginLoading>());
    expect(
      (states[1] as LoginError).errorMessage,
      'E-mail ou senha incorretos. Tente novamente.',
    );
  });

  test('sendPasswordReset emite confirmação', () async {
    final states = await recordStates(
      cubit,
      () => cubit.sendPasswordReset('ana@example.com'),
    );

    expect(states[0], isA<LoginLoading>());
    expect(states[1], isA<LoginPasswordResetSent>());
    expect(repository.lastResetEmail, 'ana@example.com');
  });

  test('sendPasswordReset emite erro de conexão', () async {
    repository.resetError = Exception('timeout');

    final states = await recordStates(
      cubit,
      () => cubit.sendPasswordReset('ana@example.com'),
    );

    expect(
      (states[1] as LoginError).errorMessage,
      'Ocorreu um erro inesperado. Verifique sua conexão e tente novamente.',
    );
  });
}
