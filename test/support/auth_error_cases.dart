import 'package:flutter_test/flutter_test.dart';

void expectSupabaseAuthTranslations(String Function(Object error) translate) {
  expect(
    translate(Exception('AuthException: invalid login credentials')),
    'E-mail ou senha incorretos. Tente novamente.',
  );
  expect(
    translate(Exception('AuthApiException: invalid_credentials')),
    'E-mail ou senha incorretos. Tente novamente.',
  );
  expect(
    translate(Exception('AuthException: email not confirmed')),
    'Por favor, confirme seu e-mail antes de fazer login.',
  );
  expect(
    translate(Exception('AuthException: user not found')),
    'Nenhuma conta encontrada com este e-mail.',
  );
  expect(
    translate(Exception('AuthException: invalid email')),
    'O formato do e-mail é inválido.',
  );
  expect(
    translate(Exception('AuthException: over request rate limit')),
    'Erro de autenticação. Verifique seus dados e tente novamente.',
  );
  expect(
    translate(Exception('SocketException: failed host lookup')),
    'Ocorreu um erro inesperado. Verifique sua conexão e tente novamente.',
  );
}
