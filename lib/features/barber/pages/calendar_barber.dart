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
  bool _isActive = true;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  final String _barberId = Supabase.instance.client.auth.currentUser?.id ?? "";

  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);

    try {
      final newStatus = !_isActive;
      await Supabase.instance.client
          .from('users')
          .update({'is_active': newStatus})
          .eq('id', _barberId);

      setState(() {
        _isActive = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao atualizar status"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openBlockModal(
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
        selectedServices: [
          ServiceModel(
            id: '',
            name: 'Bloqueio',
            durationMinutes: 15,
            price: 0.0,
          ),
        ],
        selectedBarberId: _barberId,
        barberId: _barberId,

        onHorarioSelecionado: (_) async {},

        isMultiSelect: true,
        onMultiSelect: (selectDate, listaHoras) async {
          Navigator.pop(modalContext);
          await _bloquearHorario(contextWithCubit, selectDate, listaHoras);
        },
      ),
    );
  }

  Future<void> _bloquearHorario(
    BuildContext contextWithCubit,
    String dataEscolhidaStr,
    List<String> horasStr,
  ) async {
    if (horasStr.isEmpty) return;

    final String dateStr = dataEscolhidaStr;

    final DateTime dataEscolhida = DateTime.parse(dataEscolhidaStr);

    final String textoDialog = horasStr.length == 1
        ? "Deseja indisponibilizar o horário das ${horasStr.first} para os clientes?"
        : "Deseja indisponibilizar os ${horasStr.length} horários selecionados?";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Bloquear Horário",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          textoDialog,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              "Voltar",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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

    if (confirm != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Salvando bloqueio... aguarde."),
        backgroundColor: Colors.amber,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final repository = SupabaseAppointmentRepository();

      for (String hora in horasStr) {
        await repository.blockTimeSlot(
          barberId: _barberId,
          date: dateStr,
          time: hora.length == 5 ? "$hora:00" : hora,
          serviceIds: [],
        );
      }

      if (!mounted) return;

      setState(() {
        _selectedDate = dataEscolhida;
      });

      contextWithCubit.read<AppointmentCubit>().fetchBarberAgenda(
        barberId: _barberId,
        date: dateStr,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${horasStr.length} horários bloqueados com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar: $e"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 8),
        ),
      );
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
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                "Minha Agenda",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _toggleStatus,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: _isActive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isActive ? "Ativo" : "Inativo",
                                style: TextStyle(
                                  color: _isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _formatDisplayDate(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

                      final String clientName =
                          clientData?["name"] ?? "Cliente Desconhecido";
                      final appointmentServices =
                          item['appointment_services'] as List<dynamic>? ?? [];

                      double totalPrice = 0.0;
                      int totalDuration = 0;
                      String combinedNames = "Serviço Geral";

                      if (appointmentServices.isNotEmpty) {
                        final nomes = <String>[];
                        for (var apptService in appointmentServices) {
                          final s =
                              apptService['services'] as Map<String, dynamic>?;
                          if (s != null) {
                            if (s['name'] != null) nomes.add(s['name']);
                            if (s['price'] != null)
                              totalPrice += (s['price'] as num).toDouble();
                            if (s['duration_minutes'] != null)
                              totalDuration += (s['duration_minutes'] as num)
                                  .toInt();
                          }
                        }
                        if (nomes.isNotEmpty) combinedNames = nomes.join(' + ');
                      }

                      if (isBlocked) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
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
                                    "$combinedNames - $clientName",
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
                                        : "Duração: $totalDuration min • R\$ ${totalPrice.toStringAsFixed(2)}",
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
                _openBlockModal(contextInterno, formattedQueryDate);
              },
            ),
          );
        },
      ),
    );
  }
}
