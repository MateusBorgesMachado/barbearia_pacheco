import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModalBarbeiro extends StatelessWidget {
  final Function(String id, String name) onSelect;

  const ModalBarbeiro({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('users')
          .select('id, name')
          .eq('role', 'barber')
          .eq('is_active', true)
          .order('name', ascending: true),
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
                "Nenhum barbeiro disponível no momento.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        final barbers = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: barbers.map((barber) {
            final String id = barber["id"] as String;
            final String name = barber["name"] as String;

            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white30),
              onTap: () {
                onSelect(id, name);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
