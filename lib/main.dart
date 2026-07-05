import 'package:barbearia_pacheco/core/services/notification_service.dart';
import 'package:barbearia_pacheco/features/auth/pages/splash_page.dart';
import 'package:barbearia_pacheco/features/barber/pages/home_page.dart';
import 'package:barbearia_pacheco/features/client/pages/client_appointments_page.dart';
import 'package:barbearia_pacheco/features/client/pages/home_page.dart';
import 'package:barbearia_pacheco/features/client/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:barbearia_pacheco/features/auth/pages/login_page.dart';
import 'package:barbearia_pacheco/features/auth/pages/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cksavpwkozgguzowhpxc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrc2F2cHdrb3pnZ3V6b3docHhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3NDEzNjksImV4cCI6MjA5NTMxNzM2OX0.oNNjYEaf3L5Khg6nCUgpCS6RT_GKM5oxonxlSLdkcJ0',
  );
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbearia Sr Pacheco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        primarySwatch: Colors.amber,
      ),

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CadastroPage(),
        '/home': (context) => const HomePage(),
        '/barber': (context) => const BarberMainPage(),
        '/profile': (context) => const ProfilePage(),
        '/my_appointments': (context) => const ClientAppointmentsPage(),
      },
    );
  }
}
