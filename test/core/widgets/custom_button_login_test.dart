import 'package:barbearia_pacheco/core/widgets/custom_button_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra o texto e dispara o toque', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(text: 'Entrar', onPressed: () => taps++),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    await tester.tap(find.text('Entrar'));
    expect(taps, 1);
  });
}
