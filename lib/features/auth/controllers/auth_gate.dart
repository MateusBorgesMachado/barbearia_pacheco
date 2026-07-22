import 'package:barbearia_pacheco/core/models/user_model.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/pages/login_page.dart';
import 'package:barbearia_pacheco/features/barber/pages/home_page.dart';
import 'package:barbearia_pacheco/features/client/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Widget _telaInicial = const LoginPage();

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
          if (user != null) {
            if (user.role == 'barber') {
              _telaInicial = const BarberMainPage();
            } else {
              _telaInicial = const HomePage();
            }
          } else {
            _telaInicial = const LoginPage();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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

    return _telaInicial;
  }
}
