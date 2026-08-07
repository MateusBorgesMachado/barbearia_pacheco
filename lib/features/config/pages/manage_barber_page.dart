import 'dart:io';

import 'package:flutter/material.dart';

class ManageBarberScreen extends StatefulWidget {
  const ManageBarberScreen({super.key});

  @override
  State<ManageBarberScreen> createState() => _ManageBarberScreenState();
}

class _ManageBarberScreenState extends State<ManageBarberScreen> {
  File? _logoImage;

  final List<Map<String, String>> mockBarbers = [
    {"name": "João Pacheco", "role": "Barbeiro Chefe"},
    {"name": "Carlos Silva", "role": "Barbeiro"},
  ];

  void openAddBarberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Adicionar Barbeiro",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome do Barbeiro',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white10),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(modalContext),
                child: const Text(
                  "Salvar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScaleFactorOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Personalização",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImages(),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Equipe",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: (20.0 / textScale).clamp(18.0, 24.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildBarbersList(textScale),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.person_add_alt_1),
        onPressed: () => openAddBarberModal(context),
      ),
    );
  }

  Widget _buildHeaderImages() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            image: DecorationImage(
              image: AssetImage('assets/images/barbearia_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: -40,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D0D0D), width: 4),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF262626),
                  backgroundImage: AssetImage(
                    'assets/images/barbearia_logo.png',
                  ),
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, color: Colors.black, size: 16),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarbersList(double textScale) {
    if (mockBarbers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "Nenhum barbeiro cadastrado.",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockBarbers.length,
      itemBuilder: (context, index) {
        final barber = mockBarbers[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF262626),
              child: Icon(Icons.person, color: Colors.white54),
            ),
            title: Text(
              barber["name"]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: (16.0 / textScale).clamp(14.0, 18.0),
              ),
            ),
            subtitle: Text(
              barber["role"]!,
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
            onTap: () {
              openAddBarberModal(context);
            },
          ),
        );
      },
    );
  }
}
