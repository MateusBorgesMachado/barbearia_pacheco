import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/core/models/appointment_model.dart';
import 'package:barbearia_pacheco/core/appointments/data/appointment_repository.dart';
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
      emit(AppointmentError(error.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    emit(const AppointmentActionLoading());
    try {
      await _appointmentRepository.createAppointment(appointment);
      emit(const AppointmentCreationSuccess());
    } catch (error) {
      emit(AppointmentError(error.toString().replaceAll("Exception: ", "")));
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
      emit(AppointmentError(error.toString().replaceAll("Exception: ", "")));
    }
  }
}
