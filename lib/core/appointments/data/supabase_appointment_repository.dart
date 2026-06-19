import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/models/appointment_model.dart';
import 'appointment_repository.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _supabaseClient.from('appointments').insert(appointment.toJson());
    } catch (error) {
      throw Exception("Erro ao salvar o agendamento no sistema: $error");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBarberAgenda(
    String barberId,
    String date,
  ) async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('appointments')
          .select('''
            id,
            appointment_date,
            appointment_time,
            status,
            client_id,
            users!appointments_client_id_fkey(name),
            services(name, price, duration_minutes),
            service_price:services(price) 
          ''')
          .eq('barber_id', barberId)
          .eq('appointment_date', date)
          .order('appointment_time', ascending: true);

      return response;
    } catch (error) {
      throw Exception("Erro ao buscar a agenda do profissional: $error");
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _supabaseClient
          .from('appointments')
          .update({'status': 'canceled'})
          .eq('id', appointmentId);
    } catch (error) {
      throw Exception("Erro ao cancelar o agendamento: $error");
    }
  }

  Future<void> blockTimeSlot({
    required String barberId,
    required String date,
    required String time,
    required String serviceId,
  }) async {
    try {
      await _supabaseClient.from('appointments').insert({
        'barber_id': barberId,
        'client_id': barberId,
        'appointment_date': date,
        'appointment_time': time,
        'service_id': serviceId,
        'status': 'blocked',
      });
    } catch (error) {
      throw Exception("Erro ao bloquear o horário: $error");
    }
  }
}
