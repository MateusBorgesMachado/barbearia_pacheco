import 'package:barbearia_pacheco/core/config/supabase_config.dart';
import 'package:barbearia_pacheco/features/appointments/data/appointment_repository.dart';
import 'package:barbearia_pacheco/features/appointments/data/supabase_appointment_repository.dart';
import 'package:barbearia_pacheco/features/config/data/service_repository.dart';
import 'package:barbearia_pacheco/features/config/data/supabase_service_repository.dart';
import 'package:barbearia_pacheco/features/config/notification_service.dart';
import 'package:barbearia_pacheco/features/auth/controllers/auth_gate.dart';
import 'package:barbearia_pacheco/features/auth/controllers/login_cubit.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/data/supabase_auth_repository.dart';
import 'package:barbearia_pacheco/features/config/pages/manage_barber_page.dart';
import 'package:barbearia_pacheco/features/dashboard/pages/home_page_barber.dart';
import 'package:barbearia_pacheco/features/appointments/pages/client_appointments_page.dart';
import 'package:barbearia_pacheco/features/dashboard/pages/home_page.dart';
import 'package:barbearia_pacheco/features/config/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:barbearia_pacheco/features/auth/pages/login_page.dart';
import 'package:barbearia_pacheco/features/auth/pages/register_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => SupabaseAuthRepository(),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (context) => SupabaseAppointmentRepository(),
        ),
        RepositoryProvider<ServiceRepository>(
          create: (context) => SupabaseServiceRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => LoginCubit(context.read<AuthRepository>()),
        child: MaterialApp(
          title: 'Barbearia Pacheco',
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          initialRoute: '/auth',
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const CadastroPage(),
            '/home': (context) => const HomePage(),
            '/barber': (context) => const BarberMainPage(),
            '/profile': (context) => const ProfilePage(),
            '/my_appointments': (context) => const ClientAppointmentsPage(),
            '/auth': (context) => const AuthGate(),
            '/manager': (context) => const ManageBarberScreen(),
          },
        ),
      ),
    );
  }
}
