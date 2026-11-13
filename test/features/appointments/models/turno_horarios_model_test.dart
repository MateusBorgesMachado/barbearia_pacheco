import 'package:barbearia_pacheco/features/appointments/models/turno_horarios_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gera a grade de 15 minutos incluindo o fim', () {
    final slots = TurnoHorarios(
      titulo: 'Manhã',
      horaInicio: 9,
      horaFim: 9,
      minutoFim: 30,
    ).gerarIntervalos();
    expect(slots, ['09:00', '09:15', '09:30']);
  });

  test('vira a hora quando o minuto passa de 60', () {
    final slots = TurnoHorarios(
      titulo: 'Manhã',
      horaInicio: 9,
      minutoInicio: 45,
      horaFim: 10,
    ).gerarIntervalos();
    expect(slots, ['09:45', '10:00']);
  });

  test('intervalo invertido não gera horários', () {
    final slots = TurnoHorarios(
      titulo: 'Vazio',
      horaInicio: 10,
      horaFim: 9,
    ).gerarIntervalos();
    expect(slots, isEmpty);
  });
}
