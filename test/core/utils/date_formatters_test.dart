import 'package:barbearia_pacheco/core/utils/date_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ymd usa só a data', () {
    expect(DateFormatters.ymd(DateTime(2026, 1, 2, 23, 59)), '2026-01-02');
    expect(DateFormatters.ymd(DateTime(2026, 11, 9)).contains('T'), isFalse);
  });

  test('displayDay e displayMonth formatam em português', () {
    final date = DateTime(2026, 3, 7);
    expect(DateFormatters.displayDay(date), '07/03/2026');
    expect(DateFormatters.displayMonth(date), 'Março de 2026');
    expect(DateFormatters.monthNames, hasLength(12));
    expect(DateFormatters.displayMonth(DateTime(2026, 1, 1)), 'Janeiro de 2026');
    expect(
      DateFormatters.displayMonth(DateTime(2026, 12, 1)),
      'Dezembro de 2026',
    );
  });

  test('displayRange colapsa o mesmo dia e separa um intervalo', () {
    final day = DateTime(2026, 11, 11, 8);
    expect(
      DateFormatters.displayRange(day, DateTime(2026, 11, 11, 19)),
      '11/11/2026',
    );
    expect(
      DateFormatters.displayRange(DateTime(2026, 11, 1), DateTime(2026, 11, 7)),
      '01/11/2026 — 07/11/2026',
    );
  });

  test('normalizeTime e displayTime', () {
    expect(DateFormatters.normalizeTime('10:30'), '10:30:00');
    expect(DateFormatters.normalizeTime('10:30:00'), '10:30:00');
    expect(DateFormatters.normalizeTime('10:30:00.000'), '10:30:00');
    expect(DateFormatters.normalizeTime('9:00'), '9:00');
    expect(DateFormatters.displayTime('10:30:00'), '10:30');
    expect(DateFormatters.displayTime('9:00'), '9:00');
  });

  test('parseAppointment e isInThePast', () {
    expect(
      DateFormatters.parseAppointment('2026-11-09', '18:00:00'),
      DateTime(2026, 11, 9, 18),
    );
    expect(DateFormatters.parseAppointment('data', 'xx'), isNull);

    final now = DateTime(2026, 11, 9, 10);
    expect(DateFormatters.isInThePast('2020-01-01', '10:00', now: now), isTrue);
    expect(DateFormatters.isInThePast('2026-11-09', '18:00', now: now), isFalse);
    expect(DateFormatters.isInThePast('2026-11-09', '10:00', now: now), isFalse);
    expect(DateFormatters.isInThePast('invalida', 'xx', now: now), isFalse);
  });

  test('notificationId é estável e não negativo', () {
    const id = '684074ba-eab5-4c37-8baa-258fdf0163fe';
    final first = DateFormatters.notificationId(id);
    expect(first, DateFormatters.notificationId(id));
    expect(first, greaterThanOrEqualTo(0));
    expect(DateFormatters.notificationId(''), greaterThanOrEqualTo(0));
  });

  test('slotBlocks arredonda para cima em blocos de 15 minutos', () {
    expect(DateFormatters.slotBlocks(15), 1);
    expect(DateFormatters.slotBlocks(1), 1);
    expect(DateFormatters.slotBlocks(16), 2);
    expect(DateFormatters.slotBlocks(30), 2);
    expect(DateFormatters.slotBlocks(31), 3);
    expect(DateFormatters.slotBlocks(40), 3);
    expect(DateFormatters.slotBlocks(0), 2);
    expect(DateFormatters.slotBlocks(-10), 2);
  });
}
