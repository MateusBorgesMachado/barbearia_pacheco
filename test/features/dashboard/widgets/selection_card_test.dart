import 'package:barbearia_pacheco/features/dashboard/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra o título e responde ao toque', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectionCard(
            icon: Icons.content_cut,
            title: 'Serviço',
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Serviço'), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);

    await tester.tap(find.text('Serviço'));
    expect(taps, 1);
  });

  testWidgets('card desabilitado fica semitransparente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectionCard(
            icon: Icons.calendar_month,
            title: 'Data',
            enabled: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.45);
  });
}
