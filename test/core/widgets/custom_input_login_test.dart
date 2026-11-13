import 'package:barbearia_pacheco/core/widgets/custom_input_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('esconde senha, aceita texto e valida o campo', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomInput(
              label: 'Senha',
              icon: Icons.lock_outline,
              isPassword: true,
              controller: controller,
              validator: (value) {
                if (value == null || value.length < 6) return 'curta';
                return null;
              },
            ),
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(fieldWithLabel('Senha'));
    expect(field.obscureText, isTrue);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('curta'), findsOneWidget);

    await tester.enterText(fieldWithLabel('Senha'), '123456');
    expect(formKey.currentState!.validate(), isTrue);
    expect(controller.text, '123456');
  });
}
