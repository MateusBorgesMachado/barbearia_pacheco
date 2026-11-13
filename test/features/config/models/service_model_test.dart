import 'package:barbearia_pacheco/features/config/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson e toJson', () {
    final service = ServiceModel.fromJson({
      'id': 'svc-1',
      'name': 'Barba',
      'duration_minutes': 30,
      'price': 25,
    });

    expect(service.price, 25);
    expect(service.toJson(), {
      'id': 'svc-1',
      'name': 'Barba',
      'duration_minutes': 30,
      'price': 25,
    });
  });

  test('toJson omite id de um serviço novo', () {
    final service = ServiceModel(
      name: 'Corte',
      durationMinutes: 45,
      price: 40,
    );

    expect(service.toJson().containsKey('id'), isFalse);
  });

  test('igualdade usa somente o id', () {
    final first = ServiceModel(
      id: 'svc-1',
      name: 'Corte',
      durationMinutes: 30,
      price: 40,
    );
    final renamed = ServiceModel(
      id: 'svc-1',
      name: 'Barba',
      durationMinutes: 15,
      price: 20,
    );
    final other = ServiceModel(
      id: 'svc-2',
      name: 'Corte',
      durationMinutes: 30,
      price: 40,
    );

    expect(first, renamed);
    expect(first, isNot(other));
    expect(
      ServiceModel(name: 'A', durationMinutes: 15, price: 10),
      ServiceModel(name: 'B', durationMinutes: 30, price: 20),
    );
  });
}
