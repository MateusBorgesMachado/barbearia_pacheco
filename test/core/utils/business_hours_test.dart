import 'package:barbearia_pacheco/core/utils/business_hours.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domingo e segunda estão fechados', () {
    expect(BusinessHours.isClosed(DateTime(2026, 11, 8)), isTrue);
    expect(BusinessHours.isClosed(DateTime(2026, 11, 9)), isTrue);
    for (var day = 10; day <= 14; day++) {
      expect(BusinessHours.isClosed(DateTime(2026, 11, day)), isFalse);
    }
  });

  test('dia fechado não gera turnos nem horários', () {
    final monday = DateTime(2026, 11, 9);
    expect(BusinessHours.shiftsFor(monday), isEmpty);
    expect(BusinessHours.slotsFor(monday), isEmpty);
  });

  test('terça a quinta vão até 19:00', () {
    final shifts = BusinessHours.shiftsFor(DateTime(2026, 11, 10));
    expect(shifts.map((shift) => shift.titulo), ['Manhã', 'Tarde/Noite']);
    expect(shifts.last.horaFim, 19);
    expect(shifts.last.minutoFim, 0);

    final slots = BusinessHours.slotsFor(DateTime(2026, 11, 11));
    expect(slots.first, '09:00');
    expect(slots, contains('12:00'));
    expect(slots, contains('14:00'));
    expect(slots.last, '19:00');
    expect(slots, isNot(contains('13:00')));
    expect(slots, isNot(contains('19:15')));
  });

  test('sexta estende a noite até 19:30', () {
    final friday = DateTime(2026, 11, 13);
    final shifts = BusinessHours.shiftsFor(friday);
    expect(shifts.last.titulo, 'Tarde/Noite');
    expect(shifts.last.horaFim, 19);
    expect(shifts.last.minutoFim, 30);
    expect(BusinessHours.slotsFor(friday).last, '19:30');
  });

  test('sábado abre 08:30 e fecha 16:30', () {
    final saturday = DateTime(2026, 11, 7);
    final shifts = BusinessHours.shiftsFor(saturday);
    expect(shifts.map((shift) => shift.titulo), ['Manhã', 'Tarde']);
    expect(shifts.first.horaInicio, 8);
    expect(shifts.first.minutoInicio, 30);
    expect(shifts.last.horaFim, 16);
    expect(shifts.last.minutoFim, 30);

    final slots = BusinessHours.slotsFor(saturday);
    expect(slots.first, '08:30');
    expect(slots, contains('12:00'));
    expect(slots, contains('13:30'));
    expect(slots.last, '16:30');
    expect(slots, isNot(contains('12:15')));
    expect(slots, isNot(contains('13:15')));
  });
}
