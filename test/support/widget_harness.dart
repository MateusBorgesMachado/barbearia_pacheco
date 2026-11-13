import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> prepareFrame(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Finder fieldWithLabel(String label) {
  return find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration?.labelText == label;
  });
}

Future<void> settleSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
}
