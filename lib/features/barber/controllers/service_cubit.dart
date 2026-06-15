import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/core/services/data/service_repository.dart';
import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository _serviceRepository;

  ServiceCubit(this._serviceRepository) : super(const ServiceInitial());

  Future<void> fetchServices() async {
    emit(const ServiceLoading());
    try {
      final services = await _serviceRepository.fetchServices();
      emit(ServiceLoaded(services));
    } catch (error) {
      emit(ServiceError(error.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> createService(ServiceModel service) async {
    try {
      await _serviceRepository.createService(service);
      await fetchServices();
    } catch (error) {
      emit(ServiceError(error.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await _serviceRepository.updateService(service);
      await fetchServices();
    } catch (error) {
      emit(ServiceError(error.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _serviceRepository.deleteService(serviceId);
      await fetchServices();
    } catch (error) {
      emit(ServiceError(error.toString().replaceAll("Exception: ", "")));
    }
  }
}
