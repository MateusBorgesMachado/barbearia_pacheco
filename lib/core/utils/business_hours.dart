import 'package:barbearia_pacheco/features/appointments/models/turno_horarios_model.dart';

class BusinessHours {
  BusinessHours._();

  static bool isClosed(DateTime date) {
    return date.weekday == DateTime.sunday || date.weekday == DateTime.monday;
  }

  static List<TurnoHorarios> shiftsFor(DateTime date) {
    if (isClosed(date)) return [];

    if (date.weekday == DateTime.saturday) {
      return [
        TurnoHorarios(
          titulo: 'Manhã',
          horaInicio: 8,
          minutoInicio: 30,
          horaFim: 12,
          minutoFim: 0,
        ),
        TurnoHorarios(
          titulo: 'Tarde',
          horaInicio: 13,
          minutoInicio: 30,
          horaFim: 16,
          minutoFim: 30,
        ),
      ];
    }

    if (date.weekday == DateTime.friday) {
      return [
        TurnoHorarios(
          titulo: 'Manhã',
          horaInicio: 9,
          minutoInicio: 0,
          horaFim: 12,
          minutoFim: 0,
        ),
        TurnoHorarios(
          titulo: 'Tarde/Noite',
          horaInicio: 14,
          minutoInicio: 0,
          horaFim: 19,
          minutoFim: 30,
        ),
      ];
    }

    return [
      TurnoHorarios(
        titulo: 'Manhã',
        horaInicio: 9,
        minutoInicio: 0,
        horaFim: 12,
        minutoFim: 0,
      ),
      TurnoHorarios(
        titulo: 'Tarde/Noite',
        horaInicio: 14,
        minutoInicio: 0,
        horaFim: 19,
        minutoFim: 0,
      ),
    ];
  }

  static List<String> slotsFor(DateTime date) {
    return [for (final shift in shiftsFor(date)) ...shift.gerarIntervalos()];
  }
}
