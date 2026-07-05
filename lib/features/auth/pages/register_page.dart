import 'package:barbearia_pacheco/core/widgets/custom_button_login.dart';
import 'package:barbearia_pacheco/core/widgets/custom_input_login.dart';
import 'package:barbearia_pacheco/features/auth/controllers/register_cubit.dart';
import 'package:barbearia_pacheco/features/auth/controllers/register_state.dart';
import 'package:barbearia_pacheco/features/auth/data/supabase_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double logoHeight = (screenHeight * 0.22).clamp(100.0, 180.0);
    final double topSpacing = (screenHeight * 0.04).clamp(16.0, 30.0);
    final double elementSpacing = (screenHeight * 0.04).clamp(16.0, 35.0);

    return Scaffold(
      body: BlocProvider(
        create: (context) => RegisterCubit(SupabaseAuthRepository()),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Conta criada com sucesso! Faça login."),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is RegisterError) {
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
                      image: AssetImage('assets/barbearia_bg.png'),
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
                                'assets/barbearia_logo.png',
                                height: logoHeight,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Crie sua conta",
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
                                label: "Nome",
                                icon: Icons.person_outline,
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Informe seu nome completo";
                                  }
                                  if (value.trim().split(' ').length < 2) {
                                    return "Por favor, insira nome e sobrenome";
                                  }
                                  return null;
                                },
                              ),
                              CustomInput(
                                label: "Email",
                                icon: Icons.mail_outline,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe seu e-mail';
                                  }
                                  final bool isEmailValido = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                  ).hasMatch(value);
                                  if (!isEmailValido) {
                                    return 'Digite um e-mail válido';
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
                                    return "Crie uma senha";
                                  }
                                  if (value.trim().length < 6) {
                                    return "A senha deve ter no mínimo 6 dígitos";
                                  }
                                  return null;
                                },
                              ),
                              CustomInput(
                                label: "Confirmar Senha",
                                icon: Icons.lock_clock_outlined,
                                isPassword: true,
                                controller: _confirmPasswordController,
                              ),
                              SizedBox(height: elementSpacing),
                              state is RegisterLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : PrimaryButton(
                                      text: "Cadastrar",
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (_passwordController.text !=
                                              _confirmPasswordController.text) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "As senhas não coincidem.",
                                                ),
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          context
                                              .read<RegisterCubit>()
                                              .registerNewUser(
                                                name: _nameController.text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                                role: 'client',
                                              );
                                        }
                                      },
                                    ),
                              SizedBox(height: elementSpacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Já tem uma conta? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Faça Login",
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
