import 'package:barbearia_pacheco/features/config/models/service_model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> fetchServices();

  Future<void> createService(ServiceModel service);

  Future<void> updateService(ServiceModel service);

  Future<void> deleteService(String serviceId);
}
