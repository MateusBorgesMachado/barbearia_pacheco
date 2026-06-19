import 'package:barbearia_pacheco/core/appointments/data/supabase_appointment_repository.dart';
import 'package:barbearia_pacheco/core/appointments/controllers/appointment_cubit.dart';
import 'package:barbearia_pacheco/core/appointments/controllers/appointment_state.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/features/barber/widgets/barber_date_picker.dart';
import 'package:barbearia_pacheco/features/client/widgets/modal_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarBarber extends StatefulWidget {
  const CalendarBarber({super.key});

  @override
  State<CalendarBarber> createState() => _CalendarBarberState();
}

class _CalendarBarberState extends State<CalendarBarber> {
  DateTime _selectedDate = DateTime.now();
  final String _barberId = Supabase.instance.client.auth.currentUser?.id ?? "";
  final _appointmentRepository = SupabaseAppointmentRepository();

  void _abrirModalBloqueio(
    BuildContext contextWithCubit,
    String dataSelecionadaStr,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => ModalDataHora(
        selectedService: ServiceModel(
          id: '',
          name: 'Bloqueio',
          durationMinutes: 15,
          price: 0.0,
        ),
        selectedBarberId: _barberId,
        barberId: _barberId,
        onSelect: (dataEscolhida, horaEscohida) async {
          Navigator.pop(modalContext);
          await _bloquearHorario(contextWithCubit, horaEscohida);
        },
        onHorarioSelecionado: (_) async {},
      ),
    );
  }

  Future<void> _bloquearHorario(
    BuildContext contextWithCubit,
    String horaStr,
  ) async {
    final String dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final String barberId = _barberId;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Bloquear Horário",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Deseja indisponibilizar o horário das $horaStr para os clientes?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Voltar",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Bloquear",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final servicos = await Supabase.instance.client
            .from('services')
            .select('id')
            .limit(1);
        if (servicos.isEmpty) {
          throw Exception("Cadastre pelo menos um serviço antes de bloquear.");
        }
        final String serviceIdDefault = servicos[0]['id'] as String;

        final repository = SupabaseAppointmentRepository();
        await repository.blockTimeSlot(
          barberId: barberId,
          date: dateStr,
          time: horaStr.length == 5 ? "$horaStr:00" : horaStr,
          serviceId: serviceIdDefault,
        );

        if (mounted) {
          contextWithCubit.read<AppointmentCubit>().fetchBarberAgenda(
            barberId: barberId,
            date: _formatDate(_selectedDate),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Horário bloqueado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao bloquear: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDisplayDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScaleFactorOf(context);
    final String formattedQueryDate = _formatDate(_selectedDate);

    return BlocProvider(
      create: (context) =>
          AppointmentCubit(SupabaseAppointmentRepository())
            ..fetchBarberAgenda(barberId: _barberId, date: formattedQueryDate),
      child: Builder(
        builder: (contextInterno) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D0D0D),
            appBar: AppBar(
              backgroundColor: const Color(0xFF141414),
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Minha Agenda",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDisplayDate(_selectedDate),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              elevation: 0,
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.today_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await BarberDatePicker.show(
                          context: context,
                          initialDate: _selectedDate,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          if (context.mounted) {
                            context.read<AppointmentCubit>().fetchBarberAgenda(
                              barberId: _barberId,
                              date: _formatDate(picked),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            ),
            body: BlocConsumer<AppointmentCubit, AppointmentState>(
              listener: (context, state) {
                if (state is AppointmentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AppointmentAgendaLoading ||
                    state is AppointmentActionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is AppointmentAgendaLoaded) {
                  final agendaItems = state.agendaItems;

                  if (agendaItems.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum agendamento para este dia.",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: agendaItems.length,
                    itemBuilder: (context, index) {
                      final item = agendaItems[index];
                      final String currentHour =
                          (item["appointment_time"] as String).substring(0, 5);
                      final String status = item["status"] ?? "scheduled";
                      final bool isCanceled = status == "canceled";
                      final bool isBlocked = status == "blocked";

                      final clientData = item["users"] as Map<String, dynamic>?;
                      final serviceData =
                          item["services"] as Map<String, dynamic>?;

                      final String clientName =
                          clientData?["name"] ?? "Cliente Desconhecido";
                      final String serviceName =
                          serviceData?["name"] ?? "Serviço Geral";
                      final int duration =
                          serviceData?["duration_minutes"] ?? 0;
                      final double price =
                          (serviceData?["price"] as num?)?.toDouble() ?? 0.0;

                      if (isBlocked) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.02,
                            ), // Mais discreto
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                currentHour,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "🔒 Horário Bloqueado",
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Indisponível para os clientes",
                                      style: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                onPressed: () {
                                  context
                                      .read<AppointmentCubit>()
                                      .cancelAppointment(
                                        appointmentId: item["id"] as String,
                                        barberId: _barberId,
                                        date: formattedQueryDate,
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCanceled
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              currentHour,
                              style: TextStyle(
                                color: isCanceled
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCanceled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$serviceName - $clientName",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCanceled
                                          ? Colors.white38
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: (14.0 / textScale).clamp(
                                        12.0,
                                        16.0,
                                      ),
                                      decoration: isCanceled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isCanceled
                                        ? "Cancelado"
                                        : "Duração: $duration min • R\$ ${price.toStringAsFixed(2)}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCanceled
                                          ? Colors.redAccent.withOpacity(0.6)
                                          : Colors.white54,
                                      fontSize: (12.0 / textScale).clamp(
                                        10.0,
                                        14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isCanceled)
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                onPressed: () {
                                  context
                                      .read<AppointmentCubit>()
                                      .cancelAppointment(
                                        appointmentId: item["id"] as String,
                                        barberId: _barberId,
                                        date: formattedQueryDate,
                                      );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text(
                    "Nenhum dado disponível.",
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              icon: const Icon(Icons.lock_person_outlined, color: Colors.black),
              label: const Text(
                "Bloquear Horário",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _abrirModalBloqueio(contextInterno, formattedQueryDate);
              },
            ),
          );
        },
      ),
    );
  }
}
