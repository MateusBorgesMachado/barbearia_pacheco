import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/models/appointment_model.dart';
import 'appointment_repository.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      final response = await _supabaseClient
          .from('appointments')
          .insert(appointment.toJson())
          .select('id')
          .single();

      final String newAppointmentId = response['id'];

      final List<Map<String, dynamic>> servicesToInsert = appointment.serviceIds
          .map((serviceId) {
            return {
              'appointment_id': newAppointmentId,
              'service_id': serviceId,
            };
          })
          .toList();

      if (servicesToInsert.isNotEmpty) {
        await _supabaseClient
            .from('appointment_services')
            .insert(servicesToInsert);
      }
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
            appointment_services (
              services (
                id, name, price, duration_minutes
              )
            )
          ''') // 🌟 O SEGREDO ESTÁ AQUI: Navegando pelas tabelas
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
    required List<String> serviceIds,
  }) async {
    try {
      final Map<String, dynamic> dadosAgendamento = {
        'barber_id': barberId,
        'client_id':
            barberId, // Preenchemos com o próprio ID do barbeiro por causa da regra do banco
        'appointment_date': date,
        'appointment_time': time,
        'status': 'blocked',
      };

      // Insere direto, sem esperar dados de volta para não cair em bloqueio de leitura (RLS)
      await _supabaseClient.from('appointments').insert(dadosAgendamento);

      if (serviceIds.isEmpty) return;

      // O restante do código de serviços normais fica aqui (se houver)...
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchRelatorioPeriodo({
    required String barberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    return await Supabase.instance.client
        .from('appointments')
        .select('*, appointment_services(services(price, name))')
        .eq('barber_id', barberId)
        .gte('appointment_date', startStr)
        .lte('appointment_date', endStr)
        .order('appointment_date', ascending: true);
  }
}
