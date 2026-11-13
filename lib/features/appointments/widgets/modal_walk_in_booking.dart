import 'package:barbearia_pacheco/core/utils/date_formatters.dart';
import 'package:barbearia_pacheco/features/appointments/widgets/modal_date_time.dart';
import 'package:barbearia_pacheco/features/config/models/service_model.dart';
import 'package:barbearia_pacheco/features/config/widgets/modal_service.dart';
import 'package:barbearia_pacheco/features/dashboard/widgets/selection_card.dart';
import 'package:flutter/material.dart';

class ModalWalkInBooking extends StatefulWidget {
  final String barberId;
  final void Function({
    required String clientName,
    required List<ServiceModel> services,
    required String date,
    required String time,
  })
  onConfirm;

  const ModalWalkInBooking({
    super.key,
    required this.barberId,
    required this.onConfirm,
  });

  @override
  State<ModalWalkInBooking> createState() => _ModalWalkInBookingState();
}

class _ModalWalkInBookingState extends State<ModalWalkInBooking> {
  final _nameController = TextEditingController();
  List<ServiceModel> _selectedServices = [];
  String? _selectedDate;
  String? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openNestedSheet({required String title, required Widget content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final hasServices = _selectedServices.isNotEmpty;
    final serviceTitle = hasServices
        ? "${_selectedServices.map((s) => s.name).join(' + ')} (R\$ ${_selectedServices.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)})"
        : "Selecionar serviço";
    final dateTitle = (_selectedDate != null && _selectedTime != null)
        ? "${_selectedDate!.split('-').reversed.join('/')} às $_selectedTime"
        : "Selecionar data e hora";

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Marcar horário",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 2, width: 30, color: Colors.white24),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Nome do cliente",
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white10),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SelectionCard(
              icon: Icons.content_cut_outlined,
              title: serviceTitle,
              onTap: () => _openNestedSheet(
                title: "Escolha o Serviço",
                content: ModalService(
                  onSelect: (services) {
                    setState(() {
                      _selectedServices = services;
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SelectionCard(
              icon: Icons.calendar_today_outlined,
              title: dateTitle,
              enabled: hasServices,
              onTap: () {
                if (!hasServices) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Escolha o serviço antes da data."),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                  return;
                }
                _openNestedSheet(
                  title: "Data e Horário",
                  content: ModalDataHora(
                    selectedServices: _selectedServices,
                    selectedBarberId: widget.barberId,
                    barberId: widget.barberId,
                    onHorarioSelecionado: (_) async {},
                    onSelect: (date, time) {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = time;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty ||
                      _selectedServices.isEmpty ||
                      _selectedDate == null ||
                      _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Preencha o nome, o serviço e a data para marcar.",
                        ),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }

                  widget.onConfirm(
                    clientName: name,
                    services: _selectedServices,
                    date: _selectedDate!,
                    time: DateFormatters.displayTime(_selectedTime!),
                  );
                },
                child: const Text(
                  "Confirmar horário",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
