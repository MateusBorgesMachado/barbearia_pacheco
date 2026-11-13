import 'package:barbearia_pacheco/features/auth/widgets/modal_edit_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

void main() {
  testWidgets('valida o nome e devolve o texto salvo', (tester) async {
    String? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: ModalEditName(
                          currentName: 'Ana Costa',
                          onSave: (name) => saved = name,
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
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(fieldWithLabel('Nome completo'), '   ');
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('Por favor, insira um nome válido'), findsOneWidget);
    expect(saved, isNull);

    await tester.enterText(fieldWithLabel('Nome completo'), '  Ana Lima  ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(saved, 'Ana Lima');
    expect(find.text('abrir'), findsOneWidget);
  });
}
