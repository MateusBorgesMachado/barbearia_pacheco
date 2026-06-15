import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final supabase = Supabase.instance.client;
    final Session? session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      try {
        final Map<String, dynamic> userData = await supabase
            .from('users')
            .select('role')
            .eq('id', session.user.id)
            .single();

        final String role = userData['role'] ?? 'client';

        if (!mounted) return;

        if (role == 'barber') {
          Navigator.pushReplacementNamed(context, '/barber');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (_) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(color: Colors.white)],
        ),
      ),
    );
  }
}
