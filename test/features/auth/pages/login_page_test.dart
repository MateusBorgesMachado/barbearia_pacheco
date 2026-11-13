import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/pages/login_page.dart';
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

  Future<void> pumpLogin(WidgetTester tester) async {
    await prepareFrame(tester);
    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: repository,
        child: MaterialApp(
          routes: {
            '/home': (_) => const Scaffold(body: Text('home-cliente')),
            '/barber': (_) => const Scaffold(body: Text('home-barbeiro')),
            '/register': (_) => const Scaffold(body: Text('tela-cadastro')),
          },
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('recusa e-mail vazio, e-mail inválido e senha curta', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    expect(repository.lastSignInEmail, isNull);

    await tester.enterText(fieldWithLabel('Email'), 'ana');
    await tester.enterText(fieldWithLabel('Senha'), '123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Insira um e-mail válido'), findsOneWidget);
    expect(
      find.text('A senha deve conter pelo menos 6 caracteres'),
      findsOneWidget,
    );
    expect(repository.lastSignInEmail, isNull);
  });

  Future<void> signInAs(WidgetTester tester, String role, String destination) async {
    repository.user = sampleUser(role: role);
    await pumpLogin(tester);
    await tester.enterText(fieldWithLabel('Email'), '  ana@example.com ');
    await tester.enterText(fieldWithLabel('Senha'), '123456');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(repository.lastSignInEmail, 'ana@example.com');
    expect(repository.lastSignInPassword, '123456');
    expect(find.text(destination), findsOneWidget);
  }

  testWidgets('entra como cliente', (tester) async {
    await signInAs(tester, 'client', 'home-cliente');
  });

  testWidgets('entra como barbeiro', (tester) async {
    await signInAs(tester, 'barber', 'home-barbeiro');
  });

  testWidgets('mostra o erro de login', (tester) async {
    repository.signInError = Exception(
      'AuthException: invalid login credentials',
    );
    await pumpLogin(tester);
    await tester.enterText(fieldWithLabel('Email'), 'ana@example.com');
    await tester.enterText(fieldWithLabel('Senha'), '123456');
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('E-mail ou senha incorretos. Tente novamente.'),
      findsOneWidget,
    );
    await settleSnackBars(tester);
  });

  testWidgets('envia o link de recuperação e ignora e-mail vazio', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();
    expect(repository.lastResetEmail, isNull);

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'ana@example.com');
    await tester.tap(find.text('Enviar link'));
    await tester.pump();
    await tester.pump();

    expect(repository.lastResetEmail, 'ana@example.com');
    expect(
      find.text(
        'Se este e-mail estiver cadastrado, você receberá o link para redefinir a senha.',
      ),
      findsOneWidget,
    );
    await settleSnackBars(tester);
  });

  testWidgets('abre a tela de cadastro', (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();
    expect(find.text('tela-cadastro'), findsOneWidget);
  });
}
