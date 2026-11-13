import 'package:barbearia_pacheco/core/widgets/custom_button_login.dart';
import 'package:barbearia_pacheco/core/widgets/custom_input_login.dart';
import 'package:barbearia_pacheco/features/auth/controllers/login_cubit.dart';
import 'package:barbearia_pacheco/features/auth/controllers/login_state.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showForgotPasswordDialog(BuildContext cubitContext) async {
    final email = await showDialog<String>(
      context: cubitContext,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
      ),
    );

    if (email != null && email.isNotEmpty && cubitContext.mounted) {
      cubitContext.read<LoginCubit>().sendPasswordReset(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double logoHeight = (screenHeight * 0.28).clamp(120.0, 220.0);
    final double topSpacing = (screenHeight * 0.05).clamp(16.0, 40.0);
    final double elementSpacing = (screenHeight * 0.04).clamp(16.0, 40.0);

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginCubit(context.read<AuthRepository>()),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginPasswordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Se este e-mail estiver cadastrado, você receberá o link para redefinir a senha.",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is LoginSuccess) {
              if (state.user.role == 'barber') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/barber',
                  (route) => false,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              }
            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/barbearia_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.4, 0.8],
                    ),
                  ),
                ),

                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: topSpacing),
                              Image.asset(
                                'assets/images/barbearia_logo.png',
                                height: logoHeight,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Acesse sua conta",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 2,
                                width: 40,
                                color: Colors.white,
                              ),
                              SizedBox(height: elementSpacing),
                              CustomInput(
                                label: "Email",
                                icon: Icons.person_outline,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Por favor, insira seu e-mail";
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value.trim())) {
                                    return "Insira um e-mail válido";
                                  }
                                  return null;
                                },
                              ),
                              CustomInput(
                                label: "Senha",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Por favor, insira sua senha";
                                  }
                                  if (value.trim().length < 6) {
                                    return "A senha deve conter pelo menos 6 caracteres";
                                  }
                                  return null;
                                },
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showForgotPasswordDialog(
                                    context,
                                  ),
                                  child: const Text(
                                    "Esqueci minha senha",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              state is LoginLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : PrimaryButton(
                                      text: "Login",
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<LoginCubit>()
                                              .signInWithEmailAndPassword(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                        }
                                      },
                                    ),
                              SizedBox(height: elementSpacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Não tem uma conta? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: const Text(
                                      "Cadastre-se",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Recuperar senha",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: "E-mail da conta",
          labelStyle: TextStyle(color: Colors.white54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _emailController.text.trim()),
          child: const Text(
            "Enviar link",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
