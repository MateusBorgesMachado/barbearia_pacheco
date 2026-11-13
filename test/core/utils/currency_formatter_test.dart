import 'package:barbearia_pacheco/core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter = CurrencyInputFormatter();

  TextEditingValue format(String text, int offset) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: offset),
      ),
    );
  }

  test('cursor no início devolve o valor sem formatar', () {
    final result = format('1234', 0);
    expect(result.text, '1234');
  });

  test('converte centavos para real', () {
    final result = format('1234', 4);
    expect(result.text, r'R$ 12,34');
    expect(result.selection.baseOffset, result.text.length);
    expect(format('1', 1).text, r'R$ 0,01');
    expect(format('10', 2).text, r'R$ 0,10');
    expect(format('12a34', 5).text, r'R$ 12,34');
  });

  test('texto sem dígitos fica vazio', () {
    expect(format('abc', 3).text, isEmpty);
  });
}
