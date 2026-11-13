import 'package:barbearia_pacheco/features/config/controllers/service_cubit.dart';
import 'package:barbearia_pacheco/features/config/controllers/service_state.dart';
import 'package:barbearia_pacheco/features/config/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';
import '../../../support/record_states.dart';

void main() {
  late FakeServiceRepository repository;
  late ServiceCubit cubit;

  final service = ServiceModel(
    id: 'svc-1',
    name: 'Corte',
    durationMinutes: 30,
    price: 40,
  );

  setUp(() {
    repository = FakeServiceRepository();
    cubit = ServiceCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('começa em ServiceInitial', () {
    expect(cubit.state, isA<ServiceInitial>());
  });

  test('fetchServices emite a lista', () async {
    repository.services = [service];

    final states = await recordStates(cubit, cubit.fetchServices);

    expect(states[0], isA<ServiceLoading>());
    expect((states[1] as ServiceLoaded).services.single.name, 'Corte');
  });

  test('fetchServices remove o prefixo Exception', () async {
    repository.fetchError = Exception('Erro ao carregar serviços da nuvem');

    final states = await recordStates(cubit, cubit.fetchServices);

    expect(
      (states[1] as ServiceError).errorMessage,
      'Erro ao carregar serviços da nuvem',
    );
  });

  test('createService recarrega a lista', () async {
    repository.services = [service];

    final states = await recordStates(cubit, () => cubit.createService(service));

    expect(repository.lastCreated?.name, 'Corte');
    expect(repository.fetchCalls, 1);
    expect(states.last, isA<ServiceLoaded>());
  });

  test('createService emite erro sem recarregar', () async {
    repository.writeError = Exception('Erro ao cadastrar novo serviço');

    final states = await recordStates(cubit, () => cubit.createService(service));

    expect(repository.fetchCalls, 0);
    expect(
      (states.single as ServiceError).errorMessage,
      'Erro ao cadastrar novo serviço',
    );
  });

  test('updateService recarrega a lista', () async {
    final states = await recordStates(cubit, () => cubit.updateService(service));

    expect(repository.lastUpdated?.id, 'svc-1');
    expect(repository.fetchCalls, 1);
    expect(states[0], isA<ServiceLoading>());
  });

  test('updateService emite erro', () async {
    repository.writeError = Exception('Impossível atualizar um serviço sem ID.');

    final states = await recordStates(cubit, () => cubit.updateService(service));

    expect(
      (states.single as ServiceError).errorMessage,
      'Impossível atualizar um serviço sem ID.',
    );
  });

  test('deleteService recarrega a lista', () async {
    final states = await recordStates(
      cubit,
      () => cubit.deleteService('svc-1'),
    );

    expect(repository.lastDeleted, 'svc-1');
    expect(states.last, isA<ServiceLoaded>());
  });

  test('deleteService emite erro sem recarregar', () async {
    repository.writeError = Exception('Erro ao remover o serviço do sistema');

    final states = await recordStates(
      cubit,
      () => cubit.deleteService('svc-1'),
    );

    expect(repository.fetchCalls, 0);
    expect(
      (states.single as ServiceError).errorMessage,
      'Erro ao remover o serviço do sistema',
    );
  });

  test('falha no reload depois de criar vira erro de carregamento', () async {
    repository.fetchError = Exception('Erro ao carregar serviços da nuvem');

    final states = await recordStates(cubit, () => cubit.createService(service));

    expect(repository.lastCreated, isNotNull);
    expect(
      (states.last as ServiceError).errorMessage,
      'Erro ao carregar serviços da nuvem',
    );
  });
}
