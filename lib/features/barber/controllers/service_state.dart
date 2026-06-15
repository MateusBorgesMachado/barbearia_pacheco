import 'package:barbearia_pacheco/core/models/service_model.dart';

abstract class ServiceState {
  const ServiceState();
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  const ServiceLoaded(this.services);
}

class ServiceError extends ServiceState {
  final String errorMessage;
  const ServiceError(this.errorMessage);
}
