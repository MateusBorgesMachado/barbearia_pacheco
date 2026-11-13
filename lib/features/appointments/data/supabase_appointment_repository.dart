import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/utils/date_formatters.dart';
import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';
import 'appointment_repository.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final result = await _supabaseClient.rpc(
        'book_appointment',
        params: {
          'p_client_id': appointment.clientId,
          'p_barber_id': appointment.barberId,
          'p_date': appointment.appointmentDate,
          'p_time': DateFormatters.normalizeTime(appointment.appointmentTime),
          'p_service_ids': appointment.serviceIds,
        },
      );

      return result.toString();
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
            walk_in_name,
            users!appointments_client_id_fkey(name),
            appointment_services (
              services (
                id, name, price, duration_minutes
              )
            )
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

  @override
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _supabaseClient
          .from('appointments')
          .update({'status': 'completed'})
          .eq('id', appointmentId);
    } catch (error) {
      throw Exception("Erro ao concluir o agendamento: $error");
    }
  }

  @override
  Future<void> blockTimeSlot({
    required String barberId,
    required String date,
    required String time,
  }) async {
    try {
      await _supabaseClient.rpc(
        'block_time_slot',
        params: {
          'p_barber_id': barberId,
          'p_date': date,
          'p_time': DateFormatters.normalizeTime(time),
        },
      );
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  Future<String> bookWalkInAppointment({
    required String barberId,
    required String date,
    required String time,
    required List<String> serviceIds,
    required String clientName,
  }) async {
    try {
      final result = await _supabaseClient.rpc(
        'book_walk_in_appointment',
        params: {
          'p_barber_id': barberId,
          'p_date': date,
          'p_time': DateFormatters.normalizeTime(time),
          'p_service_ids': serviceIds,
          'p_client_name': clientName,
        },
      );
      return result.toString();
    } catch (error) {
      throw Exception("Erro ao marcar o horário: $error");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelatorioPeriodo({
    required String barberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = DateFormatters.ymd(startDate);
    final endStr = DateFormatters.ymd(endDate);

    return await _supabaseClient
        .from('appointments')
        .select('*, appointment_services(services(price, name))')
        .eq('barber_id', barberId)
        .gte('appointment_date', startStr)
        .lte('appointment_date', endStr)
        .order('appointment_date', ascending: true);
  }
}
