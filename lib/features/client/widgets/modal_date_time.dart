import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/core/models/turno_horarios_model.dart';

class ModalDataHora extends StatefulWidget {
  final ServiceModel? selectedService;
  final String? selectedBarberId;
  final Function(String date, String time) onSelect;
  final String barberId;
  final ValueChanged<String> onHorarioSelecionado;

  const ModalDataHora({
    super.key,
    required this.selectedService,
    required this.selectedBarberId,
    required this.onSelect,
    required this.barberId,
    required this.onHorarioSelecionado,
  });

  @override
  State<ModalDataHora> createState() => _ModalDataHoraState();
}

class _ModalDataHoraState extends State<ModalDataHora> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<TurnoHorarios> turnos = [
    TurnoHorarios(titulo: "Manhã", horaInicio: 8, horaFim: 12),
    TurnoHorarios(titulo: "Tarde", horaInicio: 12, horaFim: 18),
    TurnoHorarios(titulo: "Noite", horaInicio: 18, horaFim: 22),
  ];

  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  int _turnoSelecionadoIndex = 0;
  String? _horarioSelecionado;
  int? _diaSelecionado;
  bool _exibindoHorarios = false;
  bool _isLoadingOccupied = false;

  List<String> _horariosOcupados = [];

  Future<void> _fetchOccupiedSlots(String date) async {
    if (widget.selectedBarberId == null) return;

    setState(() {
      _isLoadingOccupied = true;
      _horariosOcupados.clear();
    });

    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('appointments')
          .select('appointment_time, status, services(duration_minutes)')
          .eq('barber_id', widget.selectedBarberId!)
          .eq('appointment_date', date)
          .neq('status', 'canceled');

      List<String> slots = [];
      for (final appointment in response) {
        final String startTime = (appointment['appointment_time'] as String)
            .substring(0, 5);
        final serviceData = appointment['services'] as Map<String, dynamic>?;
        final int duration = serviceData?['duration_minutes'] as int? ?? 30;

        int totalBlocks = duration ~/ 15;
        int startHour = int.parse(startTime.split(':')[0]);
        int startMinute = int.parse(startTime.split(':')[1]);

        for (int i = 0; i < totalBlocks; i++) {
          final String h = startHour.toString().padLeft(2, '0');
          final String m = startMinute.toString().padLeft(2, '0');
          slots.add("$h:$m");

          startMinute += 15;
          if (startMinute >= 60) {
            startHour += 1;
            startMinute = 0;
          }
        }
      }

      setState(() {
        _horariosOcupados = slots;
      });
    } catch (_) {
    } finally {
      setState(() {
        _isLoadingOccupied = false;
      });
    }
  }

  bool _isSlotAvailable(String time, List<String> todosHorariosDoTurno) {
    if (_horariosOcupados.contains(time)) return false;

    final bool isBarberBlocking =
        widget.selectedService == null ||
        widget.selectedService!.name == 'Bloqueio';

    if (!isBarberBlocking && widget.selectedService == null) return false;

    final DateTime now = DateTime.now();

    if (_diaSelecionado == now.day &&
        _currentMonth == now.month &&
        _currentYear == now.year) {
      final List<String> timeParts = time.split(':');
      final int slotHour = int.parse(timeParts[0]);
      final int slotMinute = int.parse(timeParts[1]);

      if (slotHour < now.hour ||
          (slotHour == now.hour && slotMinute <= now.minute)) {
        return false;
      }
    }

    if (isBarberBlocking) return true;

    int requiredBlocks = widget.selectedService!.durationMinutes ~/ 15;
    int currentIndex = todosHorariosDoTurno.indexOf(time);

    for (int i = 0; i < requiredBlocks; i++) {
      int nextIndex = currentIndex + i;
      if (nextIndex >= todosHorariosDoTurno.length) return false;

      String nextTime = todosHorariosDoTurno[nextIndex];
      if (_horariosOcupados.contains(nextTime)) return false;
    }
    return true;
  }

  String _getMonthName(int month) {
    final months = [
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
    return months[month - 1];
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedService == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orangeAccent,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "Selecione um serviço primeiro",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Precisamos saber qual serviço você deseja para calcular a duração e os horários livres na agenda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final List<String> horariosDoTurno = turnos[_turnoSelecionadoIndex]
        .gerarIntervalos();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.60,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_exibindoHorarios)
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _exibindoHorarios = false),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Voltar para o calendário",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            )
          else
            const SizedBox(height: 20),
          const SizedBox(height: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _exibindoHorarios
                  ? _isLoadingOccupied
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _buildVisaoHorarios(horariosDoTurno)
                  : _buildVisaoCalendario(),
            ),
          ),
          if (_horarioSelecionado != null && _exibindoHorarios) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final String dateStr =
                      "$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${_diaSelecionado!.toString().padLeft(2, '0')}";
                  widget.onSelect(dateStr, _horarioSelecionado!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Selecionar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisaoCalendario() {
    final int totalDays = _getDaysInMonth(_currentYear, _currentMonth);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return Column(
      key: const ValueKey('calendario'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                final DateTime targetMonth = DateTime(
                  _currentYear,
                  _currentMonth - 1,
                  1,
                );
                if (targetMonth.isBefore(
                  DateTime(today.year, today.month, 1),
                )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Não é possível agendar em meses passados.",
                      ),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                  return;
                }
                setState(() {
                  if (_currentMonth == 1) {
                    _currentMonth = 12;
                    _currentYear--;
                  } else {
                    _currentMonth--;
                  }
                });
              },
            ),
            Text(
              "${_getMonthName(_currentMonth)} $_currentYear",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () => setState(() {
                if (_currentMonth == 12) {
                  _currentMonth = 1;
                  _currentYear++;
                } else {
                  _currentMonth++;
                }
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Seg", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Ter", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Qua", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Qui", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Sex", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Sáb", style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text("Dom", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              int dia = index + 1;
              bool isSelected = _diaSelecionado == dia;

              final DateTime cellDate = DateTime(
                _currentYear,
                _currentMonth,
                dia,
              );

              final bool isPastDay = cellDate.isBefore(today);

              return InkWell(
                onTap: isPastDay
                    ? null
                    : () {
                        setState(() {
                          _diaSelecionado = dia;
                          final dateStr =
                              "$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}";
                          _fetchOccupiedSlots(dateStr).then((_) {
                            setState(() => _exibindoHorarios = true);
                          });
                        });
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$dia",
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : isPastDay
                          ? Colors.white10
                          : Colors.white70,
                      decoration: isPastDay ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisaoHorarios(List<String> horariosDoTurno) {
    return Column(
      key: const ValueKey('horarios'),
      children: [
        Row(
          children: List.generate(turnos.length, (index) {
            bool isSelected = _turnoSelecionadoIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _turnoSelecionadoIndex = index),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white10,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    turnos[index].titulo,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: horariosDoTurno.length,
            itemBuilder: (context, index) {
              String horaStr = horariosDoTurno[index];

              bool isAvailable = _isSlotAvailable(
                horaStr,
                horariosDoTurno.cast<String>(),
              );
              bool isSelected = _horarioSelecionado == horaStr;

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() => _horarioSelecionado = horaStr);

                        final String dataFormatada =
                            "${_currentYear}-${_currentMonth.toString().padLeft(2, '0')}-${_diaSelecionado.toString().padLeft(2, '0')}";

                        widget.onSelect(dataFormatada, horaStr);
                      }
                    : null,

                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.transparent
                        : isAvailable
                        ? Colors.black
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                          ? Colors.white10
                          : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    horaStr,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                          ? Colors.white70
                          : Colors.white10,
                      decoration: isAvailable
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
