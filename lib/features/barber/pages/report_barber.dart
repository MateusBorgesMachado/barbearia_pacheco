import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/appointments/data/supabase_appointment_repository.dart';

class ReportBarber extends StatefulWidget {
  const ReportBarber({super.key});

  @override
  State<ReportBarber> createState() => _ReportBarberState();
}

class _ReportBarberState extends State<ReportBarber> {
  final _repository = SupabaseAppointmentRepository();
  final String _barberId = Supabase.instance.client.auth.currentUser?.id ?? "";

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  double _totalRevenue = 0.0;
  int _completedServicesCount = 0;
  int _canceledServicesCount = 0;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _fetchFinancialData(agora, agora);
  }

  String _formatDisplayMonth(DateTime date) {
    final List<String> months = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro",
    ];
    return "${months[date.month - 1]} de ${date.year}";
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
        } else if (status != "blocked") {
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
        _totalRevenue = calculatedRevenue;
        _completedServicesCount = completedCount;
        _canceledServicesCount = canceledCount;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar relatório: ${error.toString()}"),
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
                initialDateRange: DateTimeRange(
                  start: _selectedDate,
                  end: _selectedDate,
                ),
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
                            return Colors.black; // Texto no fundo ambar
                          }
                          return Colors.white.withOpacity(
                            1.0,
                          ); // FORÇA OPACIDADE 100%
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
                        rangeSelectionBackgroundColor: Colors.amber.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (range != null) {
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
                      "Faturamento em: ${_formatDisplayMonth(_selectedDate)}",
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
                          Colors.redAccent.withOpacity(0.8),
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
