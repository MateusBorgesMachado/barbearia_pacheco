class AppointmentModel {
  final String? id;
  final String clientId;
  final String barberId;
  final String serviceId;
  final String appointmentDate;
  final String appointmentTime;
  final String status;

  AppointmentModel({
    this.id,
    required this.clientId,
    required this.barberId,
    required this.serviceId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = 'scheduled',
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String?,
      clientId: json['client_id'] as String,
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      appointmentDate: json['appointment_date'] as String,
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'client_id': clientId,
      'barber_id': barberId,
      'service_id': serviceId,
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
