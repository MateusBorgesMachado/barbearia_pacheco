import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<String> createAppointment(AppointmentModel appointment);

  Future<List<Map<String, dynamic>>> fetchBarberAgenda(
    String barberId,
    String date,
  );

  Future<void> cancelAppointment(String appointmentId);

  Future<void> completeAppointment(String appointmentId);

  Future<void> blockTimeSlot({
    required String barberId,
    required String date,
    required String time,
  });

  Future<String> bookWalkInAppointment({
    required String barberId,
    required String date,
    required String time,
    required List<String> serviceIds,
    required String clientName,
  });

  Future<List<Map<String, dynamic>>> fetchRelatorioPeriodo({
    required String barberId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
