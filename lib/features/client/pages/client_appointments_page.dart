import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/appointments/data/supabase_appointment_repository.dart';

class ClientAppointmentsPage extends StatefulWidget {
  const ClientAppointmentsPage({super.key});

  @override
  State<ClientAppointmentsPage> createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  final _repository = SupabaseAppointmentRepository();
  final _supabase = Supabase.instance.client;
  bool _isActionLoading = false;

  bool _canCancel(String dateStr, String timeStr, String status) {
    if (status == 'canceled') return false;

    try {
      final String cleanedTime = timeStr.length > 5
          ? timeStr.substring(0, 5)
          : timeStr;
      final DateTime appointmentDateTime = DateTime.parse(
        "$dateStr $cleanedTime:00",
      );
      final DateTime now = DateTime.now();

      if (appointmentDateTime.isBefore(now)) return false;

      final Duration difference = appointmentDateTime.difference(now);
      return difference.inHours >= 5;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleCancel(String appointmentId) async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      await _repository.cancelAppointment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Agendamento cancelado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erro ao cancelar: ${error.toString().replaceAll("Exception: ", "")}",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final clientId = _supabase.auth.currentUser?.id ?? "";

    final DateTime now = DateTime.now();
    final String todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Meus Agendamentos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isActionLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _supabase
                  .from('appointments')
                  .select(
                    'id, barber_id, appointment_date, appointment_time, status, services(name, price, duration_minutes)',
                  )
                  .eq('client_id', clientId)
                  .gte('appointment_date', todayStr)
                  .order('appointment_date', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Você não possui agendamentos futuros.",
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  );
                }

                final appointments = snapshot.data!;

                final listFutureAppointments = appointments.where((item) {
                  final String rawDate = item['appointment_date'] as String;
                  final String rawTime = item['appointment_time'] as String;

                  if (rawDate == todayStr) {
                    final String cleanedTime = rawTime.length > 5
                        ? rawTime.substring(0, 5)
                        : rawTime;
                    final int slotHour = int.parse(cleanedTime.split(':')[0]);
                    final int slotMinute = int.parse(cleanedTime.split(':')[1]);

                    if (slotHour < now.hour ||
                        (slotHour == now.hour && slotMinute < now.minute)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (listFutureAppointments.isEmpty) {
                  return const Center(
                    child: Text(
                      "Você não possui agendamentos futuros.",
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listFutureAppointments.length,
                  itemBuilder: (context, index) {
                    final item = listFutureAppointments[index];
                    final service = item['services'] as Map<String, dynamic>?;

                    final String appointmentId = item['id'] as String;
                    final String rawDate = item['appointment_date'] as String;
                    final String rawTime = item['appointment_time'] as String;
                    final String status = item['status'] ?? 'scheduled';
                    final bool isCanceled = status == 'canceled';

                    final String formattedDate = rawDate
                        .split('-')
                        .reversed
                        .join('/');
                    final String formattedTime = rawTime.substring(0, 5);

                    final bool allowCancellation = _canCancel(
                      rawDate,
                      rawTime,
                      status,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service?['name'] ?? "Serviço",
                                  style: TextStyle(
                                    color: isCanceled
                                        ? Colors.white38
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: (16.0 / textScale).clamp(
                                      14.0,
                                      18.0,
                                    ),
                                    decoration: isCanceled
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$formattedDate às $formattedTime",
                                  style: TextStyle(
                                    color: isCanceled
                                        ? Colors.white24
                                        : Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isCanceled
                                      ? "Cancelado"
                                      : "Valor: R\$ ${(service?['price'] as num?)?.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isCanceled
                                        ? Colors.redAccent.withOpacity(0.6)
                                        : Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (allowCancellation)
                            IconButton(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                              onPressed: () => _handleCancel(appointmentId),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
