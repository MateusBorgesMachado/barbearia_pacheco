import 'package:barbearia_pacheco/core/models/service_model.dart';

class AppointmentModel {
  final String? id;
  final String clientId;
  final String barberId;
  final List<String> serviceIds;
  final List<ServiceModel>? services;
  final String appointmentDate;
  final String appointmentTime;
  final String status;

  AppointmentModel({
    this.id,
    required this.clientId,
    required this.barberId,
    required this.serviceIds,
    this.services,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = 'scheduled',
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedServiceIds = [];
    List<ServiceModel> parsedServices = [];

    if (json['appointment_services'] != null) {
      final apptServices = json['appointment_services'] as List<dynamic>;
      for (var item in apptServices) {
        if (item['services'] != null) {
          final s = item['services'];

          parsedServiceIds.add(s['id'].toString());

          parsedServices.add(
            ServiceModel(
              id: s['id'].toString(),
              name: s['name'] ?? 'Serviço',
              price: (s['price'] ?? 0).toDouble(),
              durationMinutes: s['duration_minutes'] ?? 30,
            ),
          );
        }
      }
    }

    return AppointmentModel(
      id: json['id'] as String?,
      clientId: json['client_id'] as String,
      barberId: json['barber_id'] as String,
      serviceIds: parsedServiceIds,
      services: parsedServices,
      appointmentDate: json['appointment_date'] as String,
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'client_id': clientId,
      'barber_id': barberId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
