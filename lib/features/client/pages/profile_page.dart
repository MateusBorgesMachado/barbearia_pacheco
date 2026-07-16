import 'package:barbearia_pacheco/features/auth/data/supabase_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/modal_edit_name.dart';
import 'package:barbearia_pacheco/core/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authRepository = SupabaseAuthRepository();

  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _authRepository.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (_) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _excluirConta(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Excluir Conta",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Tem certeza que deseja apagar sua conta? Todos os seus dados pessoais e histórico de agendamentos serão excluídos permanentemente. Esta ação não pode ser desfeita.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "SIM, EXCLUIR MINHA CONTA",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );

      try {
        await Supabase.instance.client.rpc('delete_user_account');

        await Supabase.instance.client.auth.signOut();

        if (mounted) {
          Navigator.pop(context);

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sua conta e dados foram excluídos com sucesso."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao excluir conta: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _openEditNameModal() {
    if (_currentUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModalEditName(
        currentName: _currentUser!.name,
        onSave: (newName) async {
          setState(() {
            _isLoading = true;
          });

          try {
            await _authRepository.updateName(
              userId: _currentUser!.id,
              newName: newName,
            );
          } catch (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }

          await _loadUserProfile();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Meu Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF141414),
              child: Icon(Icons.person, size: 50, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser?.name ?? "Carregando...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: (22.0 / textScale).clamp(18.0, 26.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentUser?.email ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: (14.0 / textScale).clamp(12.0, 16.0),
              ),
            ),
            const SizedBox(height: 40),
            _buildProfileItem(
              icon: Icons.edit_outlined,
              title: "Alterar nome",
              onTap: _openEditNameModal,
              textScale: textScale,
            ),
            const SizedBox(height: 12),
            if (_currentUser?.role != 'barber') ...[
              _buildProfileItem(
                icon: Icons.calendar_month_outlined,
                title: "Meus agendamentos",
                onTap: () {
                  Navigator.pushNamed(context, '/my_appointments');
                },
                textScale: textScale,
              ),
              const SizedBox(height: 12),
            ],
            _buildProfileItem(
              icon: Icons.logout,
              title: "Sair da conta",
              onTap: () async {
                // 🌟 DICA: Lembre-se de deslogar no Supabase antes de mudar a rota!
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home', // 🌟 Mudamos de '/login' para '/home' por causa do Modo Convidado
                    (route) => false,
                  );
                }
              },
              textScale: textScale,
              isDanger: true,
            ),
            const SizedBox(height: 12),
            _buildProfileItem(
              icon: Icons.delete_forever_outlined,
              title: "Excluir minha conta",
              onTap: () => _excluirConta(context),
              textScale: textScale,
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required double textScale,
  bool isDanger = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF141414),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white10),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDanger ? Colors.redAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: (16.0 / textScale).clamp(14.0, 18.0),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDanger ? Colors.redAccent.withOpacity(0.4) : Colors.white30,
        size: 20,
      ),
    ),
  );
}
