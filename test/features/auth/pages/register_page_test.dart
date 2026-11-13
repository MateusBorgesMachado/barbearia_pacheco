import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';
import '../../../support/widget_harness.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
  });

  Future<void> openRegister(WidgetTester tester) async {
    await prepareFrame(tester);
    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: repository,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CadastroPage(),
                      ),
                    );
                  },
                  child: const Text('abrir'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(fieldWithLabel('Nome'), 'Ana Costa');
    await tester.enterText(fieldWithLabel('Email'), 'ana@example.com');
    await tester.enterText(fieldWithLabel('Senha'), '123456');
    await tester.enterText(fieldWithLabel('Confirmar Senha'), '123456');
  }

  testWidgets('valida nome, e-mail e senha', (tester) async {
    await openRegister(tester);

    await tester.enterText(fieldWithLabel('Nome'), 'Ana');
    await tester.enterText(fieldWithLabel('Email'), 'ana');
    await tester.enterText(fieldWithLabel('Senha'), '123');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Por favor, insira nome e sobrenome'), findsOneWidget);
    expect(find.text('Digite um e-mail válido'), findsOneWidget);
    expect(find.text('A senha deve ter no mínimo 6 dígitos'), findsOneWidget);
    expect(repository.lastSignUpEmail, isNull);
  });

  testWidgets('exige nome e avisa quando as senhas diferem', (tester) async {
    await openRegister(tester);

    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    expect(find.text('Informe seu nome completo'), findsOneWidget);

    await fillValid(tester);
    await tester.enterText(fieldWithLabel('Confirmar Senha'), '123457');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(repository.lastSignUpEmail, isNull);
    await settleSnackBars(tester);
  });

  testWidgets('cadastra cliente e volta para a tela anterior', (tester) async {
    await openRegister(tester);
    await fillValid(tester);
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.pump();

    expect(repository.lastSignUpName, 'Ana Costa');
    expect(repository.lastSignUpEmail, 'ana@example.com');
    expect(repository.lastSignUpPassword, '123456');
    expect(repository.lastSignUpRole, 'client');
    expect(find.text('Conta criada com sucesso! Faça login.'), findsOneWidget);
    expect(find.text('abrir'), findsOneWidget);
    await settleSnackBars(tester);
  });

  testWidgets('mostra erro de cadastro', (tester) async {
    repository.signUpError = Exception('AuthException: user not found');
    await openRegister(tester);
    await fillValid(tester);
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Nenhuma conta encontrada com este e-mail.'),
      findsOneWidget,
    );
    await settleSnackBars(tester);
  });

  testWidgets('Faça Login volta para a tela anterior', (tester) async {
    await openRegister(tester);
    await tester.tap(find.text('Faça Login'));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
  });
}
