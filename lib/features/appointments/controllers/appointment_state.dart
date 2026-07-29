abstract class AppointmentState {
  const AppointmentState();
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentAgendaLoading extends AppointmentState {
  const AppointmentAgendaLoading();
}

class AppointmentAgendaLoaded extends AppointmentState {
  final List<Map<String, dynamic>> agendaItems;
  const AppointmentAgendaLoaded(this.agendaItems);
}

class AppointmentActionLoading extends AppointmentState {
  const AppointmentActionLoading();
}

class AppointmentCreationSuccess extends AppointmentState {
  const AppointmentCreationSuccess();
}

class AppointmentCancelSuccess extends AppointmentState {
  const AppointmentCancelSuccess();
}

class AppointmentError extends AppointmentState {
  final String errorMessage;
  const AppointmentError(this.errorMessage);
}
