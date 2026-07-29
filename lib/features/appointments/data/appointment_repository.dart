import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment(AppointmentModel appointment);

  Future<List<Map<String, dynamic>>> fetchBarberAgenda(
    String barberId,
    String date,
  );

  Future<void> cancelAppointment(String appointmentId);
}
