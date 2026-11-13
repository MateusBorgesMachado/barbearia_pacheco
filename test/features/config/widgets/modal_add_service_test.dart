import 'package:barbearia_pacheco/features/config/controllers/service_cubit.dart';
import 'package:barbearia_pacheco/features/config/widgets/modal_add_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';
import '../../../support/widget_harness.dart';

void main() {
  late FakeServiceRepository repository;
  late ServiceCubit cubit;

  setUp(() {
    repository = FakeServiceRepository();
    cubit = ServiceCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> openModal(
    WidgetTester tester, {
    Map<String, dynamic>? existing,
  }) async {
    await prepareFrame(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ServiceCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider<ServiceCubit>.value(
                          value: cubit,
                          child: Scaffold(
                            body: SingleChildScrollView(
                              child: ModalAddService(
                                servicoExistente: existing,
                                onSalvar: (_, _, _) {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('abrir'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('exige nome e preço', (tester) async {
    await openModal(tester);
    expect(find.text('Novo Serviço'), findsOneWidget);

    await tester.tap(find.text('Salvar Alterações'));
    await tester.pump();

    expect(find.text('Informe o nome'), findsOneWidget);
    expect(find.text('Informe o valor do serviço'), findsOneWidget);
    expect(repository.lastCreated, isNull);
  });

  testWidgets('cria serviço com duração escolhida e preço em centavos', (
    tester,
  ) async {
    await openModal(tester);

    await tester.enterText(fieldWithLabel('Nome do serviço'), 'Corte');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('45 minutos').last);
    await tester.pumpAndSettle();
    await tester.enterText(fieldWithLabel('Preço do serviço'), '4050');
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    expect(repository.lastCreated?.name, 'Corte');
    expect(repository.lastCreated?.durationMinutes, 45);
    expect(repository.lastCreated?.price, 40.5);
    expect(repository.lastCreated?.id, isNull);
    expect(repository.fetchCalls, 1);
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('edição atualiza o serviço existente', (tester) async {
    await openModal(
      tester,
      existing: {
        'id': 'svc-1',
        'nome': 'Barba',
        'tempo': 30,
        'valor': 25.0,
      },
    );

    expect(find.text('Editar Serviço'), findsOneWidget);
    expect(find.text('Barba'), findsOneWidget);
    expect(find.text(r'R$ 25,00'), findsOneWidget);

    await tester.enterText(fieldWithLabel('Nome do serviço'), 'Barba completa');
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdated?.id, 'svc-1');
    expect(repository.lastUpdated?.name, 'Barba completa');
    expect(repository.lastUpdated?.durationMinutes, 30);
    expect(repository.lastUpdated?.price, 25);
    expect(repository.lastCreated, isNull);
  });
}
