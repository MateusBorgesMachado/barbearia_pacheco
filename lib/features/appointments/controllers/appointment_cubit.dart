import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/core/utils/error_messages.dart';
import 'package:barbearia_pacheco/features/appointments/models/appointment_model.dart';
import 'package:barbearia_pacheco/features/appointments/data/appointment_repository.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _appointmentRepository;

  AppointmentCubit(this._appointmentRepository)
    : super(const AppointmentInitial());

  Future<void> fetchBarberAgenda({
    required String barberId,
    required String date,
  }) async {
    emit(const AppointmentAgendaLoading());
    try {
      final agenda = await _appointmentRepository.fetchBarberAgenda(
        barberId,
        date,
      );
      emit(AppointmentAgendaLoaded(agenda));
    } catch (error) {
      emit(AppointmentError(userFacingError(error)));
    }
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    emit(const AppointmentActionLoading());
    try {
      final appointmentId = await _appointmentRepository.createAppointment(
        appointment,
      );
      emit(AppointmentCreationSuccess(appointmentId));
    } catch (error) {
      emit(AppointmentError(userFacingError(error)));
    }
  }

  Future<void> createWalkInAppointment({
    required String barberId,
    required String date,
    required String time,
    required List<String> serviceIds,
    required String clientName,
  }) async {
    emit(const AppointmentActionLoading());
    try {
      final appointmentId = await _appointmentRepository.bookWalkInAppointment(
        barberId: barberId,
        date: date,
        time: time,
        serviceIds: serviceIds,
        clientName: clientName,
      );
      emit(AppointmentCreationSuccess(appointmentId));
      await fetchBarberAgenda(barberId: barberId, date: date);
    } catch (error) {
      emit(AppointmentError(userFacingError(error)));
    }
  }

  Future<void> cancelAppointment({
    required String appointmentId,
    required String barberId,
    required String date,
  }) async {
    emit(const AppointmentActionLoading());
    try {
      await _appointmentRepository.cancelAppointment(appointmentId);
      emit(const AppointmentCancelSuccess());

      await fetchBarberAgenda(barberId: barberId, date: date);
    } catch (error) {
      emit(AppointmentError(userFacingError(error)));
    }
  }

  Future<void> completeAppointment({
    required String appointmentId,
    required String barberId,
    required String date,
  }) async {
    emit(const AppointmentActionLoading());
    try {
      await _appointmentRepository.completeAppointment(appointmentId);
      emit(const AppointmentCompleteSuccess());
      await fetchBarberAgenda(barberId: barberId, date: date);
    } catch (error) {
      emit(AppointmentError(userFacingError(error)));
    }
  }
}
