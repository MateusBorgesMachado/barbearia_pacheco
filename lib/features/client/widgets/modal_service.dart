import 'package:barbearia_pacheco/core/services/data/supabase_service_repository.dart';
import 'package:flutter/material.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';

class ModalService extends StatefulWidget {
  final Function(List<ServiceModel>) onSelect;

  const ModalService({super.key, required this.onSelect});

  @override
  State<ModalService> createState() => _ModalServiceState();
}

class _ModalServiceState extends State<ModalService> {
  late Future<List<ServiceModel>> _servicesFuture;
  final List<ServiceModel> _servicosSelecionadosTemporarios = [];
  final repository = SupabaseServiceRepository();

  @override
  void initState() {
    super.initState();
    _servicesFuture = repository.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    final int duracaoTotal = _servicosSelecionadosTemporarios.fold(
      0,
      (soma, item) => soma + item.durationMinutes,
    );
    final double precoTotal = _servicosSelecionadosTemporarios.fold(
      0,
      (soma, item) => soma + item.price,
    );

    return FutureBuilder<List<ServiceModel>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Nenhum serviço disponível no momento.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        final services = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...services.map((service) {
              final bool isSelected = _servicosSelecionadosTemporarios.any(
                (s) => s.id == service.id,
              );

              return Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white54,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: CheckboxListTile(
                  activeColor: Colors.amber,
                  checkColor: Colors.black,
                  secondary: const Icon(
                    Icons.content_cut,
                    color: Colors.white70,
                  ),
                  title: Text(
                    service.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${service.durationMinutes} min • R\$ ${service.price.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                  value: isSelected,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        _servicosSelecionadosTemporarios.add(service);
                      } else {
                        _servicosSelecionadosTemporarios.remove(service);
                      }
                    });
                  },
                ),
              );
            }),

            if (_servicosSelecionadosTemporarios.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      widget.onSelect(_servicosSelecionadosTemporarios);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Confirmar ($duracaoTotal min - R\$ ${precoTotal.toStringAsFixed(2)})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
