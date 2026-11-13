import 'package:barbearia_pacheco/features/auth/models/user_model.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/pages/login_page.dart';
import 'package:barbearia_pacheco/features/dashboard/pages/home_page_barber.dart';
import 'package:barbearia_pacheco/features/dashboard/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Widget _telaInicial = const LoginPage();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    try {
      final authRepository = context.read<AuthRepository>();
      final UserModel? user = await authRepository.getCurrentUser();

      if (mounted) {
        setState(() {
          _errorMessage = null;
          if (user != null) {
            if (user.role == 'barber') {
              _telaInicial = const BarberMainPage();
            } else {
              _telaInicial = const HomePage();
            }
          } else {
            _telaInicial = const HomePage();
          }
          _isLoading = false;
        });
      }
    } on AuthProfileException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _telaInicial = const LoginPage();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Não foi possível verificar sua sessão. Tente entrar novamente.';
          _telaInicial = const LoginPage();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _errorMessage == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
        _errorMessage = null;
      });
    }

    return _telaInicial;
  }
}
