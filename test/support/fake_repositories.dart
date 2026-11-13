import 'dart:async';

import 'package:barbearia_pacheco/features/appointments/data/appointment_repository.dart';
import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/models/user_model.dart';
import 'package:barbearia_pacheco/features/config/data/service_repository.dart';
import 'package:barbearia_pacheco/features/config/models/service_model.dart';

UserModel sampleUser({
  String id = 'user-1',
  String name = 'Ana Costa',
  String email = 'ana@example.com',
  String role = 'client',
  bool isActive = true,
}) {
  return UserModel(
    id: id,
    name: name,
    email: email,
    role: role,
    isActive: isActive,
  );
}

class FakeAuthRepository implements AuthRepository {
  UserModel user = sampleUser();
  UserModel? currentUser = sampleUser();
  Object? signInError;
  Object? signUpError;
  Object? resetError;
  Object? currentUserError;
  Completer<UserModel?>? currentUserGate;

  String? lastSignInEmail;
  String? lastSignInPassword;
  String? lastSignUpName;
  String? lastSignUpEmail;
  String? lastSignUpPassword;
  String? lastSignUpRole;
  String? lastResetEmail;
  String? updatedUserId;
  String? updatedName;
  bool? updatedActive;
  bool signedOut = false;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInError != null) throw signInError!;
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    lastSignUpName = name;
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    lastSignUpRole = role;
    if (signUpError != null) throw signUpError!;
    return user;
  }

  @override
  Future<void> resetPassword(String email) async {
    lastResetEmail = email;
    if (resetError != null) throw resetError!;
  }

  @override
  Future<UserModel?> getCurrentUser() {
    final gate = currentUserGate;
    if (gate != null) return gate.future;
    if (currentUserError != null) return Future.error(currentUserError!);
    return Future.value(currentUser);
  }

  @override
  Future<void> updateName({
    required String userId,
    required String newName,
  }) async {
    updatedUserId = userId;
    updatedName = newName;
  }

  @override
  Future<void> updateActiveStatus({
    required String userId,
    required bool isActive,
  }) async {
    updatedUserId = userId;
    updatedActive = isActive;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

class FakeAppointmentRepository implements AppointmentRepository {
  Object? actionError;
  Object? agendaError;
  String createdId = 'appt-1';
  List<Map<String, dynamic>> agenda = const [];
  List<Map<String, dynamic>> report = const [];

  AppointmentModel? lastCreated;
  String? lastCanceled;
  String? lastCompleted;
  String? lastAgendaBarberId;
  String? lastAgendaDate;
  String? blockedBarberId;
  String? blockedDate;
  String? blockedTime;
  String? walkInBarberId;
  String? walkInDate;
  String? walkInTime;
  List<String>? walkInServiceIds;
  String? walkInClientName;
  String? reportBarberId;
  DateTime? reportStart;
  DateTime? reportEnd;
  int agendaFetches = 0;

  @override
  Future<String> createAppointment(AppointmentModel appointment) async {
    if (actionError != null) throw actionError!;
    lastCreated = appointment;
    return createdId;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBarberAgenda(
    String barberId,
    String date,
  ) async {
    agendaFetches++;
    lastAgendaBarberId = barberId;
    lastAgendaDate = date;
    if (agendaError != null) throw agendaError!;
    return agenda;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    if (actionError != null) throw actionError!;
    lastCanceled = appointmentId;
  }

  @override
  Future<void> completeAppointment(String appointmentId) async {
    if (actionError != null) throw actionError!;
    lastCompleted = appointmentId;
  }

  @override
  Future<void> blockTimeSlot({
    required String barberId,
    required String date,
    required String time,
  }) async {
    if (actionError != null) throw actionError!;
    blockedBarberId = barberId;
    blockedDate = date;
    blockedTime = time;
  }

  @override
  Future<String> bookWalkInAppointment({
    required String barberId,
    required String date,
    required String time,
    required List<String> serviceIds,
    required String clientName,
  }) async {
    if (actionError != null) throw actionError!;
    walkInBarberId = barberId;
    walkInDate = date;
    walkInTime = time;
    walkInServiceIds = serviceIds;
    walkInClientName = clientName;
    return createdId;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelatorioPeriodo({
    required String barberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    reportBarberId = barberId;
    reportStart = startDate;
    reportEnd = endDate;
    if (actionError != null) throw actionError!;
    return report;
  }
}

class FakeServiceRepository implements ServiceRepository {
  Object? fetchError;
  Object? writeError;
  List<ServiceModel> services = const [];
  ServiceModel? lastCreated;
  ServiceModel? lastUpdated;
  String? lastDeleted;
  int fetchCalls = 0;

  @override
  Future<List<ServiceModel>> fetchServices() async {
    fetchCalls++;
    if (fetchError != null) throw fetchError!;
    return services;
  }

  @override
  Future<void> createService(ServiceModel service) async {
    if (writeError != null) throw writeError!;
    lastCreated = service;
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    if (writeError != null) throw writeError!;
    lastUpdated = service;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    if (writeError != null) throw writeError!;
    lastDeleted = serviceId;
  }
}
