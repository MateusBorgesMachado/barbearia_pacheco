import 'package:barbearia_pacheco/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson assume conta ativa quando o campo falta', () {
    final user = UserModel.fromJson({
      'id': 'user-1',
      'name': 'Ana Costa',
      'email': 'ana@example.com',
      'role': 'barber',
    });

    expect(user.isActive, isTrue);
    expect(user.toJson(), {
      'id': 'user-1',
      'name': 'Ana Costa',
      'email': 'ana@example.com',
      'role': 'barber',
      'is_active': true,
    });
  });

  test('fromJson lê is_active falso', () {
    final user = UserModel.fromJson({
      'id': 'user-1',
      'name': 'Ana Costa',
      'email': 'ana@example.com',
      'role': 'client',
      'is_active': false,
    });

    expect(user.isActive, isFalse);
  });

  test('copyWith troca só os campos informados', () {
    final user = UserModel(
      id: 'user-1',
      name: 'Ana Costa',
      email: 'ana@example.com',
      role: 'client',
    );

    final renamed = user.copyWith(name: 'Ana Lima', isActive: false);
    expect(renamed.id, 'user-1');
    expect(renamed.name, 'Ana Lima');
    expect(renamed.email, user.email);
    expect(renamed.role, 'client');
    expect(renamed.isActive, isFalse);
  });
}
