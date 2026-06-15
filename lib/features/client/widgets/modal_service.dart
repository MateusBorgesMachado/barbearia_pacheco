import 'package:flutter/material.dart';
import 'package:barbearia_pacheco/core/models/service_model.dart';
import 'package:barbearia_pacheco/core/services/data/supabase_service_repository.dart';

class ModalService extends StatelessWidget {
  final Function(ServiceModel service) onSelect;

  const ModalService({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final repository = SupabaseServiceRepository();

    return FutureBuilder<List<ServiceModel>>(
      future: repository.fetchServices(),
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
          children: services.map((service) {
            return ListTile(
              leading: const Icon(Icons.content_cut, color: Colors.white70),
              title: Text(
                service.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${service.durationMinutes} min • R\$ ${service.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white30),
              onTap: () {
                onSelect(service);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
