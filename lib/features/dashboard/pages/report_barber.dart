import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/utils/date_formatters.dart';
import 'package:barbearia_pacheco/core/utils/error_messages.dart';
import 'package:barbearia_pacheco/features/appointments/data/appointment_repository.dart';

class ReportBarber extends StatefulWidget {
  const ReportBarber({super.key});

  @override
  State<ReportBarber> createState() => _ReportBarberState();
}

class _ReportBarberState extends State<ReportBarber> {
  late final AppointmentRepository _repository;
  final String _barberId = Supabase.instance.client.auth.currentUser?.id ?? "";

  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  bool _isLoading = false;

  double _totalRevenue = 0.0;
  int _completedServicesCount = 0;
  int _canceledServicesCount = 0;

  @override
  void initState() {
    super.initState();
    _repository = context.read<AppointmentRepository>();
    final today = DateTime.now();
    _selectedRange = DateTimeRange(start: today, end: today);
    _fetchFinancialData(_selectedRange.start, _selectedRange.end);
  }

  bool _countsAsCompleted(Map<String, dynamic> item) {
    final String status = item["status"] ?? "scheduled";
    if (status == "canceled" || status == "blocked") return false;
    if (status == "completed") return true;

    final dateStr = item["appointment_date"] as String? ?? "";
    final timeStr = item["appointment_time"] as String? ?? "00:00:00";
    return DateFormatters.isInThePast(dateStr, timeStr);
  }

  Future<void> _fetchFinancialData(DateTime startDate, DateTime endDate) async {
    if (_barberId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _totalRevenue = 0.0;
      _completedServicesCount = 0;
      _canceledServicesCount = 0;
    });

    try {
      final List<Map<String, dynamic>> agendaData = await _repository
          .fetchRelatorioPeriodo(
            barberId: _barberId,
            startDate: startDate,
            endDate: endDate,
          );

      double calculatedRevenue = 0.0;
      int completedCount = 0;
      int canceledCount = 0;

      for (final item in agendaData) {
        final String status = item["status"] ?? "scheduled";

        if (status == "canceled") {
          canceledCount++;
        } else if (_countsAsCompleted(item)) {
          completedCount++;

          final apptServices =
              item["appointment_services"] as List<dynamic>? ?? [];

          for (var apptSvc in apptServices) {
            final serviceData = apptSvc["services"] as Map<String, dynamic>?;
            if (serviceData != null && serviceData["price"] != null) {
              calculatedRevenue += (serviceData["price"] as num).toDouble();
            }
          }
        }
      }

      setState(() {
        _selectedRange = DateTimeRange(start: startDate, end: endDate);
        _totalRevenue = calculatedRevenue;
        _completedServicesCount = completedCount;
        _canceledServicesCount = canceledCount;
      });
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScaleFactorOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        automaticallyImplyLeading: false,
        title: const Text(
          "Relatórios",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              final DateTimeRange? range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.amber,
                        onPrimary: Colors.black,
                        surface: Color(0xFF141414),
                        onSurface: Colors.white,
                      ),
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: const Color(0xFF141414),
                        headerBackgroundColor: const Color(0xFF141414),
                        headerForegroundColor: Colors.white,
                        dayForegroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.black;
                          }
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.white24;
                          }
                          return Colors.white;
                        }),
                        dayBackgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.amber;
                          }
                          return Colors.transparent;
                        }),
                        todayForegroundColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                        shadowColor: Colors.white,
                        todayBackgroundColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        rangePickerBackgroundColor: const Color(0xFF141414),
                        rangeSelectionBackgroundColor: Colors.amber.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (range != null) {
                if (!context.mounted) return;
                final int diferenca = range.end.difference(range.start).inDays;

                if (diferenca > 30) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "O período máximo para relatórios é de 30 dias.",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                _fetchFinancialData(range.start, range.end);
              }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Faturamento em: ${DateFormatters.displayRange(_selectedRange.start, _selectedRange.end)}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "R\$ ${_totalRevenue.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (32.0 / textScale).clamp(24.0, 36.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricCard(
                          "Serviços Feitos",
                          "$_completedServicesCount",
                          Icons.check_circle_outline,
                          textScale,
                          Colors.white,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          "Cancelamentos",
                          "$_canceledServicesCount",
                          Icons.cancel_outlined,
                          textScale,
                          Colors.redAccent.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    double textScale,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white54,
                fontSize: (12.0 / textScale).clamp(10.0, 14.0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: (20.0 / textScale).clamp(16.0, 24.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
