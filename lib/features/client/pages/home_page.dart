import 'package:barbearia_pacheco/core/appointments/controllers/appointment_cubit.dart';
import 'package:barbearia_pacheco/core/appointments/controllers/appointment_state.dart';
import 'package:barbearia_pacheco/core/appointments/data/supabase_appointment_repository.dart';
import 'package:barbearia_pacheco/core/models/appointment_model.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/core/services/notification_service.dart';
import 'package:barbearia_pacheco/features/client/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/modal_barber.dart';
import '../widgets/modal_date_time.dart';
import '../widgets/modal_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _clientId = Supabase.instance.client.auth.currentUser?.id ?? "";

  String? _selectedBarberId;
  String? _selectedBarberName;

  ServiceModel? _selectedService;

  String? _selectedDate; // Formato YYYY-MM-DD
  String? _selectedTime; // Formato HH:MM

  void _openPopup(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(height: 2, width: 30, color: Colors.white24),
                const SizedBox(height: 20),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  void _triggerBooking(BuildContext context) {
    if (_selectedBarberId == null ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, preencha todos os campos do agendamento."),
          backgroundColor: Colors.orangeAccent,
        ),
      );

      return;
    }

    final appointment = AppointmentModel(
      clientId: _clientId,
      barberId: _selectedBarberId!,
      serviceId: _selectedService!.id!,
      appointmentDate: _selectedDate!,
      appointmentTime: _selectedTime!,
    );

    context.read<AppointmentCubit>().createAppointment(appointment);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScale = MediaQuery.textScaleFactorOf(context);

    final double logoHeight = (screenHeight * 0.24).clamp(110.0, 190.0);
    final double topSpacing = (screenHeight * 0.04).clamp(16.0, 40.0);
    final double elementSpacing = (screenHeight * 0.03).clamp(12.0, 30.0);

    return BlocProvider(
      create: (context) => AppointmentCubit(SupabaseAppointmentRepository()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: BlocConsumer<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentCreationSuccess) {
              NotificationService.scheduleAppointmentNotification(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                serviceName: _selectedService?.name ?? "Serviço",
                dateStr: _selectedDate!,
                timeStr: _selectedTime!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Horário agendado com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _selectedBarberId = null;
                _selectedBarberName = null;
                _selectedService = null;
                _selectedDate = null;
                _selectedTime = null;
              });
            } else if (state is AppointmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * 0.45,
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/barbearia_bg.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              const Color(0xFF0D0D0D),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/barbearia_logo.png',
                        height: logoHeight,
                      ),
                      SizedBox(height: topSpacing),
                      Text(
                        "Agende seu horário",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (24.0 / textScale).clamp(20.0, 26.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          "Escolha os serviços que deseja e agende no horário que preferir.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: (14.0 / textScale).clamp(12.0, 16.0),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(height: elementSpacing),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              SelectionCard(
                                icon: Icons.person_outline,
                                title:
                                    _selectedBarberName ??
                                    "Selecionar barbeiro",
                                onTap: () => _openPopup(
                                  context,
                                  title: "Escolha o Barbeiro",
                                  content: ModalBarbeiro(
                                    onSelect: (id, name) {
                                      setState(() {
                                        _selectedBarberId = id;
                                        _selectedBarberName = name;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SelectionCard(
                                icon: Icons.content_cut_outlined,
                                title: _selectedService != null
                                    ? "${_selectedService!.name} (R\$ ${_selectedService!.price.toStringAsFixed(2)})"
                                    : "Selecionar serviço",
                                onTap: () => _openPopup(
                                  context,
                                  title: "Escolha o Serviço",
                                  content: ModalService(
                                    onSelect: (service) {
                                      setState(() {
                                        _selectedService = service;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SelectionCard(
                                icon: Icons.calendar_today_outlined,
                                title:
                                    (_selectedDate != null &&
                                        _selectedTime != null)
                                    ? "${_selectedDate!.split('-').reversed.join('/')} às $_selectedTime"
                                    : "Selecionar data e hora",
                                onTap: () => _openPopup(
                                  context,
                                  title: "Data e Horário",
                                  content: ModalDataHora(
                                    selectedService: _selectedService,
                                    selectedBarberId: _selectedBarberId,
                                    onSelect: (date, time) {
                                      setState(() {
                                        _selectedDate = date;
                                        _selectedTime = time;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: state is AppointmentActionLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () =>
                                            _triggerBooking(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFC5C9D0,
                                          ),
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          "Agendar",
                                          style: TextStyle(
                                            fontSize: (18.0 / textScale).clamp(
                                              16.0,
                                              20.0,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
