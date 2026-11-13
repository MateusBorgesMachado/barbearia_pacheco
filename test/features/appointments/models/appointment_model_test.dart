import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson lê serviços aninhados e preenche faltantes', () {
    final appointment = AppointmentModel.fromJson({
      'id': 'appt-1',
      'client_id': 'client-1',
      'barber_id': 'barber-1',
      'appointment_date': '2026-11-11',
      'appointment_time': '10:30:00',
      'status': 'scheduled',
      'appointment_services': [
        {
          'services': {
            'id': 'svc-1',
            'name': 'Corte',
            'price': 35,
            'duration_minutes': 45,
          },
        },
        {'services': null},
        {
          'services': {'id': 'svc-2', 'price': 10.5},
        },
      ],
    });

    expect(appointment.id, 'appt-1');
    expect(appointment.serviceIds, ['svc-1', 'svc-2']);
    expect(appointment.services, hasLength(2));
    expect(appointment.services!.first.price, 35);
    expect(appointment.services!.first.durationMinutes, 45);
    expect(appointment.services!.last.name, 'Serviço');
    expect(appointment.services!.last.durationMinutes, 30);
    expect(appointment.services!.last.price, 10.5);
  });

  test('fromJson sem serviços deixa as listas vazias', () {
    final appointment = AppointmentModel.fromJson({
      'client_id': 'client-1',
      'barber_id': 'barber-1',
      'appointment_date': '2026-11-11',
      'appointment_time': '10:30:00',
      'status': 'scheduled',
    });

    expect(appointment.id, isNull);
    expect(appointment.serviceIds, isEmpty);
    expect(appointment.services, isEmpty);
  });

  test('toJson completa segundos e só inclui id quando existe', () {
    final draft = AppointmentModel(
      clientId: 'client-1',
      barberId: 'barber-1',
      serviceIds: const ['svc-1'],
      appointmentDate: '2026-11-11',
      appointmentTime: '10:30',
    );

    expect(draft.toJson(), {
      'client_id': 'client-1',
      'barber_id': 'barber-1',
      'appointment_date': '2026-11-11',
      'appointment_time': '10:30:00',
      'status': 'scheduled',
    });

    expect(
      AppointmentModel(
        id: 'appt-1',
        clientId: 'client-1',
        barberId: 'barber-1',
        serviceIds: const [],
        appointmentDate: '2026-11-11',
        appointmentTime: '10:30:00',
        status: 'completed',
      ).toJson()['id'],
      'appt-1',
    );
  });
}
