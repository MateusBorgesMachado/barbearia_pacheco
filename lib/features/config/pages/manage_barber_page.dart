import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/models/user_model.dart';
import 'package:barbearia_pacheco/features/auth/widgets/modal_edit_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageBarberScreen extends StatefulWidget {
  const ManageBarberScreen({super.key});

  @override
  State<ManageBarberScreen> createState() => _ManageBarberScreenState();
}

class _ManageBarberScreenState extends State<ManageBarberScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await context.read<AuthRepository>().getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleActive(bool value) async {
    final user = _currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AuthRepository>().updateActiveStatus(
        userId: user.id,
        isActive: value,
      );
      if (mounted) {
        setState(() {
          _currentUser = user.copyWith(isActive: value);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar disponibilidade."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openEditNameModal() {
    final user = _currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModalEditName(
        currentName: user.name,
        onSave: (newName) async {
          try {
            await this.context.read<AuthRepository>().updateName(
              userId: user.id,
              newName: newName,
            );
            await _loadProfile();
          } catch (error) {
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
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
        automaticallyImplyLeading: false,
        title: const Text(
          "Configurações",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _currentUser == null
          ? const Center(
              child: Text(
                "Não foi possível carregar seu perfil.",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF141414),
                  backgroundImage: AssetImage(
                    'assets/images/barbearia_logo.png',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser!.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (22.0 / textScale).clamp(18.0, 26.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Disponível para agendamentos",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _currentUser!.isActive
                          ? "Clientes podem te escolher na agenda"
                          : "Você não aparece na lista de barbeiros",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    value: _currentUser!.isActive,
                    activeThumbColor: Colors.amber,
                    onChanged: _isSaving ? null : _toggleActive,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  tileColor: const Color(0xFF141414),
                  leading: const Icon(Icons.edit_outlined, color: Colors.white70),
                  title: const Text(
                    "Alterar nome",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white30,
                  ),
                  onTap: _openEditNameModal,
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  tileColor: const Color(0xFF141414),
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    "Meu perfil",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white30,
                  ),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
    );
  }
}
