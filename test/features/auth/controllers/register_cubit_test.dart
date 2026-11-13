import 'package:barbearia_pacheco/features/auth/controllers/register_cubit.dart';
import 'package:barbearia_pacheco/features/auth/controllers/register_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/auth_error_cases.dart';
import '../../../support/fake_repositories.dart';
import '../../../support/record_states.dart';

void main() {
  late FakeAuthRepository repository;
  late RegisterCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = RegisterCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('começa em RegisterInitial', () {
    expect(cubit.state, isA<RegisterInitial>());
  });

  test('traduzirErroSupabase cobre as mensagens de autenticação', () {
    expectSupabaseAuthTranslations(cubit.traduzirErroSupabase);
  });

  test('registerNewUser emite loading e sucesso', () async {
    repository.user = sampleUser();

    final states = await recordStates(
      cubit,
      () => cubit.registerNewUser(
        name: 'Ana Costa',
        email: 'ana@example.com',
        password: '123456',
        role: 'client',
      ),
    );

    expect(states[0], isA<RegisterLoading>());
    expect((states[1] as RegisterSuccess).user.email, 'ana@example.com');
    expect(repository.lastSignUpName, 'Ana Costa');
    expect(repository.lastSignUpRole, 'client');
  });

  test('registerNewUser emite erro de e-mail inválido', () async {
    repository.signUpError = Exception('AuthException: invalid email');

    final states = await recordStates(
      cubit,
      () => cubit.registerNewUser(
        name: 'Ana Costa',
        email: 'ana',
        password: '123456',
        role: 'client',
      ),
    );

    expect(
      (states[1] as RegisterError).errorMessage,
      'O formato do e-mail é inválido.',
    );
  });
}
