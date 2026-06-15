import 'package:barbearia_pacheco/core/services/data/supabase_service_repository.dart';
import 'package:barbearia_pacheco/features/barber/controllers/service_cubit.dart';
import 'package:barbearia_pacheco/features/barber/controllers/service_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/modal_add_service.dart';

class ServiceBarber extends StatefulWidget {
  const ServiceBarber({super.key});

  @override
  State<ServiceBarber> createState() => _ServiceBarberState();
}

class _ServiceBarberState extends State<ServiceBarber> {
  void openServiceModal(
    BuildContext contextWithCubit, {
    Map<String, dynamic>? existingService,
    int? index,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: BlocProvider.of<ServiceCubit>(contextWithCubit),
        child: ModalAddService(
          servicoExistente: existingService,
          onSalvar: (name, time, value) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScaleFactorOf(context);

    return BlocProvider(
      create: (context) =>
          ServiceCubit(SupabaseServiceRepository())..fetchServices(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF141414),
          automaticallyImplyLeading: false,
          title: const Text(
            "Serviços",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
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
        body: BlocConsumer<ServiceCubit, ServiceState>(
          listener: (context, state) {
            if (state is ServiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ServiceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is ServiceLoaded) {
              final services = state.services;

              if (services.isEmpty) {
                return const Center(
                  child: Text(
                    "Nenhum serviço cadastrado.",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final currentItem = services[index];

                  final Map<String, dynamic> legacyMap = {
                    "id": currentItem.id,
                    "nome": currentItem.name,
                    "tempo": currentItem.durationMinutes,
                    "valor": currentItem.price,
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      title: Text(
                        currentItem.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: (16.0 / textScale).clamp(14.0, 18.0),
                        ),
                      ),
                      subtitle: Text(
                        "${currentItem.durationMinutes} min • R\$ ${currentItem.price.toStringAsFixed(2)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: (14.0 / textScale).clamp(12.0, 16.0),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onTap: () => openServiceModal(
                        context,
                        existingService: legacyMap,
                        index: index,
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text(
                "Toque no botão + para adicionar um serviço.",
                style: TextStyle(color: Colors.white38),
              ),
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (fabContext) {
            return FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.add),
              onPressed: () => openServiceModal(fabContext),
            );
          },
        ),
      ),
    );
  }
}
