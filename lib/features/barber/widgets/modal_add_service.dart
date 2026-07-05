import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/features/barber/controllers/service_cubit.dart';
import 'package:barbearia_pacheco/core/utils/currency_formatter.dart';

class ModalAddService extends StatefulWidget {
  final Map<String, dynamic>? servicoExistente;
  final Function(String name, int time, double value) onSalvar;

  const ModalAddService({
    super.key,
    this.servicoExistente,
    required this.onSalvar,
  });

  @override
  State<ModalAddService> createState() => _ModalAddServiceState();
}

class _ModalAddServiceState extends State<ModalAddService> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  final List<int> _timeOptions = [15, 30, 45, 60, 75, 90, 105, 120];
  int _selectedTime = 30;

  @override
  void initState() {
    super.initState();
    if (widget.servicoExistente != null) {
      _nameController.text = widget.servicoExistente!["nome"] ?? "";
      _selectedTime = widget.servicoExistente!["tempo"] ?? 30;

      final double precoOriginal = widget.servicoExistente!["valor"] ?? 0.0;
      _valueController.text =
          "R\$ ${precoOriginal.toStringAsFixed(2).replaceAll('.', ',')}";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.servicoExistente == null
                  ? "Novo Serviço"
                  : "Editar Serviço",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Nome do serviço",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Informe o nome"
                  : null,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              dropdownColor: const Color(0xFF141414),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tempo de duração",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
              ),
              items: _timeOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value minutos"),
                );
              }).toList(),
              onChanged: (newTime) {
                if (newTime != null) {
                  setState(() => _selectedTime = newTime);
                }
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _valueController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: "Preço do serviço",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Informe o valor do serviço";
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final String serviceName = _nameController.text.trim();

                    String cleanPrice = _valueController.text
                        .replaceAll('R\$', '')
                        .replaceAll(' ', '')
                        .replaceAll('.', '')
                        .replaceAll(',', '.')
                        .trim();

                    final double servicePrice = double.parse(cleanPrice);

                    final ServiceModel serviceData = ServiceModel(
                      id: widget.servicoExistente?["id"],
                      name: serviceName,
                      durationMinutes: _selectedTime,
                      price: servicePrice,
                    );

                    if (widget.servicoExistente != null) {
                      context.read<ServiceCubit>().updateService(serviceData);
                    } else {
                      context.read<ServiceCubit>().createService(serviceData);
                    }

                    Navigator.pop(context);
                  }
                },

                child: const Text(
                  "Salvar Alterações",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
