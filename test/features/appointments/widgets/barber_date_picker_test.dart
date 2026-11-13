import 'package:barbearia_pacheco/features/appointments/widgets/barber_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openPicker(
    WidgetTester tester,
    void Function(DateTime?) onPicked,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  onPicked(await BarberDatePicker.show(context: context));
                },
                child: const Text('abrir'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('devolve o dia escolhido', (tester) async {
    DateTime? picked;
    await openPicker(tester, (value) => picked = value);

    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(picked?.year, DateTime.now().year);
    expect(picked?.month, DateTime.now().month);
    expect(picked?.day, 20);
  });

  testWidgets('cancelar devolve nulo', (tester) async {
    DateTime? picked = DateTime(2020);
    await openPicker(tester, (value) => picked = value);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(picked, isNull);
  });
}
