import 'dart:async';

import 'package:barbearia_pacheco/features/auth/controllers/auth_gate.dart';
import 'package:barbearia_pacheco/features/auth/data/auth_repository.dart';
import 'package:barbearia_pacheco/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';
import '../../../support/widget_harness.dart';

void main() {
  testWidgets('mostra o carregamento enquanto a sessão não responde', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      ..currentUserGate = Completer<UserModel?>();

    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: repository,
        child: const MaterialApp(home: AuthGate()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsNothing);
  });

  testWidgets('erro de perfil abre o login com a mensagem da exceção', (
    tester,
  ) async {
    await prepareFrame(tester);
    final repository = FakeAuthRepository()
      ..currentUserError = const AuthProfileException();

    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: repository,
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(
      find.text('Não foi possível carregar seu perfil. Tente novamente.'),
      findsOneWidget,
    );
    await settleSnackBars(tester);
  });

  testWidgets('falha genérica pede para entrar de novo', (tester) async {
    await prepareFrame(tester);
    final repository = FakeAuthRepository()
      ..currentUserError = Exception('rede');

    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: repository,
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Não foi possível verificar sua sessão. Tente entrar novamente.'),
      findsOneWidget,
    );
    await settleSnackBars(tester);
  });
}
