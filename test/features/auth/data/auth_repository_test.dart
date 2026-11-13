import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthProfileException usa a mensagem padrão', () {
    expect(
      const AuthProfileException().toString(),
      'Não foi possível carregar seu perfil. Tente novamente.',
    );
  });

  test('AuthProfileException preserva uma mensagem própria', () {
    expect(const AuthProfileException('perfil indisponível').toString(), 'perfil indisponível');
  });
}
