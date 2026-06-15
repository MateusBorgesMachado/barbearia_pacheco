import 'package:barbearia_pacheco/features/barber/widgets/barber_date_picker.dart';
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
    _fetchFinancialData();
  }

  String _formatDateToQuery(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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

  Future<void> _fetchFinancialData() async {
    if (_barberId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _totalRevenue = 0.0;
      _completedServicesCount = 0;
      _canceledServicesCount = 0;
    });

    try {
      final String queryDate = _formatDateToQuery(_selectedDate);

      final List<Map<String, dynamic>> agendaData = await _repository
          .fetchBarberAgenda(_barberId, queryDate);

      double calculatedRevenue = 0.0;
      int completedCount = 0;
      int canceledCount = 0;

      for (final item in agendaData) {
        final String status = item["status"] ?? "scheduled";

        if (status == "canceled") {
          canceledCount++;
        } else {
          completedCount++;
          final serviceData = item["services"] as Map<String, dynamic>?;
          final double price =
              (serviceData?["price"] as num?)?.toDouble() ?? 0.0;
          calculatedRevenue += price;
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
            content: Text(
              "Erro ao calcular relatórios: ${error.toString().replaceAll("Exception: ", "")}",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              final DateTime? pickedDate = await BarberDatePicker.show(
                context: context,
                initialDate: _selectedDate,
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
                _fetchFinancialData();
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
