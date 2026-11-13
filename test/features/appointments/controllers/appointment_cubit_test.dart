import 'package:barbearia_pacheco/features/appointments/controllers/appointment_cubit.dart';
import 'package:barbearia_pacheco/features/appointments/controllers/appointment_state.dart';
import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';
import '../../../support/record_states.dart';

void main() {
  late FakeAppointmentRepository repository;
  late AppointmentCubit cubit;

  final appointment = AppointmentModel(
    clientId: 'client-1',
    barberId: 'barber-1',
    serviceIds: const ['svc-1'],
    appointmentDate: '2026-11-11',
    appointmentTime: '10:30',
  );

  setUp(() {
    repository = FakeAppointmentRepository();
    cubit = AppointmentCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('começa em AppointmentInitial', () {
    expect(cubit.state, isA<AppointmentInitial>());
  });

  test('fetchBarberAgenda emite a agenda', () async {
    repository.agenda = const [
      {'id': 'appt-1'},
    ];

    final states = await recordStates(
      cubit,
      () => cubit.fetchBarberAgenda(barberId: 'barber-1', date: '2026-11-11'),
    );

    expect(states[0], isA<AppointmentAgendaLoading>());
    expect((states[1] as AppointmentAgendaLoaded).agendaItems, hasLength(1));
    expect(repository.lastAgendaBarberId, 'barber-1');
    expect(repository.lastAgendaDate, '2026-11-11');
  });

  test('fetchBarberAgenda traduz horário ocupado', () async {
    repository.agendaError = Exception('duplicate key');

    final states = await recordStates(
      cubit,
      () => cubit.fetchBarberAgenda(barberId: 'barber-1', date: '2026-11-11'),
    );

    expect(
      (states[1] as AppointmentError).errorMessage,
      'Este horário já está ocupado. Escolha outro.',
    );
  });

  test('createAppointment devolve o id', () async {
    repository.createdId = 'appt-9';

    final states = await recordStates(
      cubit,
      () => cubit.createAppointment(appointment),
    );

    expect(states[0], isA<AppointmentActionLoading>());
    expect((states[1] as AppointmentCreationSuccess).appointmentId, 'appt-9');
    expect(repository.lastCreated?.clientId, 'client-1');
  });

  test('createWalkIn recarrega a agenda do dia', () async {
    repository.createdId = 'walk-1';
    repository.agenda = const [
      {'id': 'walk-1'},
    ];

    final states = await recordStates(
      cubit,
      () => cubit.createWalkInAppointment(
        barberId: 'barber-1',
        date: '2026-11-11',
        time: '14:00',
        serviceIds: const ['svc-1', 'svc-2'],
        clientName: 'João',
      ),
    );

    expect(states[0], isA<AppointmentActionLoading>());
    expect((states[1] as AppointmentCreationSuccess).appointmentId, 'walk-1');
    expect(states[2], isA<AppointmentAgendaLoading>());
    expect((states[3] as AppointmentAgendaLoaded).agendaItems, hasLength(1));
    expect(repository.walkInClientName, 'João');
    expect(repository.walkInServiceIds, ['svc-1', 'svc-2']);
    expect(repository.agendaFetches, 1);
  });

  test('createWalkIn não recarrega a agenda quando a marcação falha', () async {
    repository.actionError = Exception('Informe o nome do cliente');

    final states = await recordStates(
      cubit,
      () => cubit.createWalkInAppointment(
        barberId: 'barber-1',
        date: '2026-11-11',
        time: '14:00',
        serviceIds: const ['svc-1'],
        clientName: ' ',
      ),
    );

    expect(
      (states[1] as AppointmentError).errorMessage,
      'Informe o nome do cliente.',
    );
    expect(repository.agendaFetches, 0);
  });

  test('cancelAppointment confirma e atualiza a agenda', () async {
    final states = await recordStates(
      cubit,
      () => cubit.cancelAppointment(
        appointmentId: 'appt-1',
        barberId: 'barber-1',
        date: '2026-11-11',
      ),
    );

    expect(states[1], isA<AppointmentCancelSuccess>());
    expect(states.last, isA<AppointmentAgendaLoaded>());
    expect(repository.lastCanceled, 'appt-1');
  });

  test('cancelAppointment traduz a regra das 5 horas', () async {
    repository.actionError = Exception('exige 5 horas de antecedência');

    final states = await recordStates(
      cubit,
      () => cubit.cancelAppointment(
        appointmentId: 'appt-1',
        barberId: 'barber-1',
        date: '2026-11-11',
      ),
    );

    expect(
      (states[1] as AppointmentError).errorMessage,
      'Cancelamento só é permitido com 5 horas de antecedência.',
    );
    expect(repository.agendaFetches, 0);
  });

  test('falha ao recarregar depois do cancelamento vira erro', () async {
    repository.agendaError = Exception('Não autorizado');

    final states = await recordStates(
      cubit,
      () => cubit.cancelAppointment(
        appointmentId: 'appt-1',
        barberId: 'barber-1',
        date: '2026-11-11',
      ),
    );

    expect(states[1], isA<AppointmentCancelSuccess>());
    expect(
      (states.last as AppointmentError).errorMessage,
      'Você não tem permissão para essa ação.',
    );
  });

  test('completeAppointment confirma e atualiza a agenda', () async {
    final states = await recordStates(
      cubit,
      () => cubit.completeAppointment(
        appointmentId: 'appt-1',
        barberId: 'barber-1',
        date: '2026-11-11',
      ),
    );

    expect(states[1], isA<AppointmentCompleteSuccess>());
    expect(states.last, isA<AppointmentAgendaLoaded>());
    expect(repository.lastCompleted, 'appt-1');
  });

  test('completeAppointment traduz erro de permissão', () async {
    repository.actionError = Exception('permission denied');

    final states = await recordStates(
      cubit,
      () => cubit.completeAppointment(
        appointmentId: 'appt-1',
        barberId: 'barber-1',
        date: '2026-11-11',
      ),
    );

    expect(
      (states[1] as AppointmentError).errorMessage,
      'Você não tem permissão para essa ação.',
    );
  });
}
