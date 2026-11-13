import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/utils/date_formatters.dart';
import 'package:barbearia_pacheco/core/utils/error_messages.dart';
import 'package:barbearia_pacheco/features/appointments/data/appointment_repository.dart';
import 'package:barbearia_pacheco/features/config/notification_service.dart';

class ClientAppointmentsPage extends StatefulWidget {
  const ClientAppointmentsPage({super.key});

  @override
  State<ClientAppointmentsPage> createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  final _supabase = Supabase.instance.client;
  bool _isActionLoading = false;
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Map<String, dynamic>>> _loadAppointments() {
    final clientId = _supabase.auth.currentUser?.id ?? "";
    final todayStr = DateFormatters.ymd(DateTime.now());

    return _supabase
        .from('appointments')
        .select('''
          id,
          client_id,
          barber_id,
          appointment_date,
          appointment_time,
          status,
          appointment_services (
            services (
              id, name, price, duration_minutes
            )
          )
        ''')
        .eq('client_id', clientId)
        .gte('appointment_date', todayStr)
        .order('appointment_date', ascending: true);
  }

  void _reload() {
    setState(() {
      _appointmentsFuture = _loadAppointments();
    });
  }

  bool _canCancel(String dateStr, String timeStr, String status) {
    if (status == 'canceled' || status == 'completed') return false;

    try {
      final DateTime? appointmentDateTime = DateFormatters.parseAppointment(
        dateStr,
        timeStr,
      );
      if (appointmentDateTime == null) return false;
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
      await context.read<AppointmentRepository>().cancelAppointment(
        appointmentId,
      );
      await NotificationService.cancelAppointmentNotification(
        DateFormatters.notificationId(appointmentId),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Agendamento cancelado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        _reload();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFacingError(error)),
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
    final DateTime now = DateTime.now();
    final String todayStr = DateFormatters.ymd(now);

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
              future: _appointmentsFuture,
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
                  final String status = item['status'] ?? 'scheduled';
                  if (status == 'completed') return false;

                  if (rawDate == todayStr) {
                    final String cleanedTime = DateFormatters.displayTime(
                      rawTime,
                    );
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

                    final appointmentServices =
                        item['appointment_services'] as List<dynamic>? ?? [];

                    String combinedNames = "Serviço";
                    double totalPrice = 0.0;

                    if (appointmentServices.isNotEmpty) {
                      final nomes = <String>[];
                      for (var apptService in appointmentServices) {
                        final s =
                            apptService['services'] as Map<String, dynamic>?;
                        if (s != null) {
                          if (s['name'] != null) nomes.add(s['name']);
                          if (s['price'] != null) {
                            totalPrice += (s['price'] as num).toDouble();
                          }
                        }
                      }
                      if (nomes.isNotEmpty) {
                        combinedNames = nomes.join(' + ');
                      }
                    }

                    final String appointmentId = item['id'] as String;
                    final String rawDate = item['appointment_date'] as String;
                    final String rawTime = item['appointment_time'] as String;
                    final String status = item['status'] ?? 'scheduled';
                    final bool isCanceled = status == 'canceled';

                    final String formattedDate = rawDate
                        .split('-')
                        .reversed
                        .join('/');
                    final String formattedTime = DateFormatters.displayTime(
                      rawTime,
                    );

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
                              ? Colors.redAccent.withValues(alpha: 0.2)
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
                                  combinedNames,
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
                                      : "Valor: R\$ ${totalPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isCanceled
                                        ? Colors.redAccent.withValues(
                                            alpha: 0.6,
                                          )
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
