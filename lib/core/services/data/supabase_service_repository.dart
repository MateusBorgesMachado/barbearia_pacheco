import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'service_repository.dart';

class SupabaseServiceRepository implements ServiceRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<ServiceModel>> fetchServices() async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('services')
          .select()
          .order('name', ascending: true);

      return response.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (error) {
      throw Exception("Erro ao carregar serviços da nuvem: $error");
    }
  }

  @override
  Future<void> createService(ServiceModel service) async {
    try {
      await _supabaseClient.from('services').insert(service.toJson());
    } catch (error) {
      throw Exception("Erro ao cadastrar novo serviço: $error");
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      if (service.id == null) {
        throw Exception("Impossível atualizar um serviço sem ID.");
      }

      await _supabaseClient
          .from('services')
          .update(service.toJson())
          .eq('id', service.id!);
    } catch (error) {
      throw Exception("Erro ao atualizar o serviço: $error");
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _supabaseClient.from('services').delete().eq('id', serviceId);
    } catch (error) {
      throw Exception("Erro ao remover o serviço do sistema: $error");
    }
  }
}
